﻿CREATE procedure RetroB.BasReassesment @Ncom INT, @op INT, @comp VARCHAR(64), @kolError INT out, @serialnom INT=0 out
-- Код ошибки @KolError: 1-ошибка при переоценке, 2-выплате постащику, 4-наполнении фондов, 8-отсутствуют корзинки.
-- Отсутствие корзинок не считается сеьезной ошибкой, может, так и было задумано.

AS
declare @prid int, @id int, @startid int, @hitag int, @ncod int, @rest int,
  @price decimal(12,2), @cost decimal(15,5), @basecost decimal(15,5),
  @flgWeight bit, @Weight decimal(10,3), @sklad INT, @dck INT, @DeltaSC decimal(11,2), @Delta1 decimal(11,2),
  @SourDate datetime, @Fam varchar(30), @Our_ID smallint, @Pin int, @ksid int, @Count int,
  @ND datetime, @btid int, @P_ID int, @PersFam varchar(100),  @total decimal(11,2),  @RemarkPlat varchar(20),
  @finalcost decimal(16, 6), @bpmid int, @Nds decimal(6,2), @SumNDS decimal(14,4), @AvgNds decimal(8,4), @Tek decimal(15,5)
BEGIN

  begin TRANSACTION T;

  create table #t(id int, BPMid int, DeltaSC decimal(14,4));

  set @AvgNds = 18.00;
  set @kolError = 0;
  set @serialnom = 0;
  set @DeltaSC  = 0.0;
  set @SumNDS = 0.00;
  set @ND = dbo.today();
  select @SourDate=Comman.[date], @Pin=def.pin, @fam=left(def.brname,30) from def inner join Comman on def.ncod=comman.Ncod where comman.ncom=@Ncom;


  DECLARE C1 CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
    select bi.prid, v.id,v.startid,v.hitag, v.ncod, round(v.morn-v.sell+v.ISPRAV-v.REMOV,0) as REST, v.price,v.cost, 
      bi.BaseCost*(case when bp.flgWeight=1 and v.weight>0 then v.weight
                        when bp.flgWeight=1 and nm.netto>0 then nm.netto
                        else 1 end) as BaseCost,
      bp.flgWeight, v.Weight, v.SKLAD,v.dck, bp.BPMid, nm.Nds
    from 
      tdvi v 
      inner join retrob.BasInpdet bi on bi.StartId=v.startid
      inner join retrob.BasPrices bp on bp.prid=bi.prid
      inner join dbo.nomen nm on v.hitag=nm.hitag
    where 
      v.ncom = @Ncom
      and v.morn-v.sell+v.ISPRAV-v.REMOV>0;  

  -- Прогоняем цикл переоценок по всем товарам данной поставки:
  OPEN C1;  
  FETCH NEXT FROM C1 INTO @Prid, @Id, @StartID, @Hitag, @Ncod, @Rest, @Price, @Cost, @BaseCost, @FlgWeight,@Weight, @sklad, @dck, @bpmid, @Nds
  WHILE @@FETCH_STATUS = 0 BEGIN
    set @Tek = @Rest*(@BaseCost-@Cost);
    if abs(@Tek)>=0.05 begin -- суммарной переоценкой по строке меньшей чем 5 копеек пренебрегаем.
      insert into #t(id, BPMid, DeltaSC) values(@ID, @BPMID, @Tek);
      set @DeltaSC = @DeltaSC + @Tek;
      set @SumNDS = @SumNDS + @Tek*@Nds/(100.0+@Nds)
      EXEC dbo.ProcessSklad 'ИзмЦ', @id, @Hitag, @Sklad, @Price, @BaseCost, 0, @Op, @Comp, null, 1, 0, 0, 0, 0, 'reassessment', @id, @serialnom, @kolError, @Dck, 0, @Weight
      if @@Error<>0 set @KolError=@KolError | 1;
    end;
    FETCH NEXT FROM C1 INTO @Prid, @Id, @StartID, @Hitag, @Ncod, @Rest, @Price, @Cost, @BaseCost, @FlgWeight,@Weight, @sklad, @dck, @bpmid, @Nds
  END
  CLOSE c1;
  DEALLOCATE c1;

PRINT('Полная сумма переоценок @DeltaSC=' + cast(@DeltaSC as varchar)+',  в т.ч. сумма НДС='+cast(@SumNDS as varchar)); -- ДЛЯ ОТЛАДКИ


  -- По результатам переоценки мы задолжали поставщику. Выплачиваем этот долг:
  if isnull(@DeltaSC,0)<>0 BEGIN
    set @AvgNds = 100.0*@SumNds/(@DeltaSC - @SumNDS);
    EXEC dbo.KassaAdd -1, 'ВЫ', @SourDate, @Ncom, @DeltaSC, @Fam, 0, 
      0, 0, @Ncod, 'reassessment', 1, 0, 0, @Op, 
      0, @Our_ID, @ND, 0, 0, 0, '', 0, 
      0, @Ncom, 0, 0, 0, null, 
      0, @AvgNds, null, @pin, 0, 0, @DCK, null,0, @ksid ;
  end;


  select @SourDate=C.[date], @Our_ID=C.our_id, @Dck=C.Dck from Comman C where C.Ncom=@Ncom;
  select @Fam=left(brname,30), @Pin=Pin from def where ncod=@Ncod;
  set @Total=0.00;
  set @ksid=0;
  set @Count=0;
  declare @stnom int;
  
  -- Теперь произведем обратную операцию - эти деньги мы как бы перегнали из фонда в кассу, из одной или нескольких корзинок:
  DECLARE c2 CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
    select brd.btid, bt.p_id, p.fio, round(sum(#t.DeltaSC*0.01*brd.perc),2) as Delta1
    from 
      #t 
      inner join retrob.BasRuleDistr brd on brd.bpmid=#t.bpmid
      inner join retrob.BasTarget bt on bt.btID=brd.btid
      left join Person P on P.P_ID=bt.p_id
    group by brd.btid, bt.p_id, p.fio;

  OPEN c2
  FETCH NEXT FROM c2 INTO @btid, @P_ID, @PersFam, @Delta1
  WHILE @@FETCH_STATUS = 0 BEGIN
    print('Попытка записи в KASS1');
    set @PersFam=left(@PersFam,30); -- ширина поля Person.Fio 100 символов, а Kassa1.Fam всего 30.
    set @RemarkPlat='btid='+cast(@btid as varchar); -- во второй коммент запишем номер корзинки.
    
    if @p_id>0 set @stnom=100*@P_ID+11; else set @stnom=0;

    EXEC dbo.KassaAdd 10, 'ВЫ', @SourDate, 0, @Delta1, @PersFam, 
        @P_ID,  0, 0, 0, 
        'reassessment', 0, 0, 0, @Op, 
        0, @Our_ID, @ND, 0, 0, 0, 
        '', -- thrfam
        0,  -- docnom
        0,  -- forprint 
        @Ncom, -- номер поставки будет записан в поле OrigRecn.
        0, @stnom, 0, null, 
        0, @AvgNds, @RemarkPlat, 0, 0, 0, 0, null,0, @ksid ;

    set @count=@Count+1
    if @@Error<>0 set @KolError=@KolError | 4;
    set @total=@total+@delta1;
    FETCH NEXT FROM c2 INTO @btid, @P_ID, @PersFam, @Delta1
  END
  CLOSE c2
  DEALLOCATE c2

  if @count=0 set @KolError=@KolError | 8;

  -- Возможные набежавшие расхождения записываем отдельной выплатой:
  set @Delta1=round(@DeltaSC-@total,2);
  if abs(@Delta1)>0.005
  EXEC dbo.KassaAdd 10, 'ВЫ', @SourDate, 0, @Delta1, 'коррекция расхождений', 
      -1,  0, 0, 0, 
      'reassessment', 0, 0, 0, @Op, 
      0, @Our_ID, @ND, 0, 0, 0, '', 0, 
      0, @Ncom, 0, 0, 0, null, 
      0, @AvgNds, '', 0, 0, 0, 0, null,0, @ksid ;

  if (@KolError & 7)=0 commit transaction T; -- Отсутствие корзинок не считается ошибкой!
  else ROLLBACK TRANSACTION T;
end;