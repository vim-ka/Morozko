CREATE procedure dbo.AutoDivPlus
@Comp varchar(30), 
@SkList varchar(100), 
@Hitag int, 
@OP int, -- оператор
@KolError int out

-- Граничное условие: после автослияния не должен измениться суммарный остаток в килограммах и рублях.
-- Нет! Это условие отменено 22.11.2017.
-- Новый подход: стоимость 1 кг весового товара должна совпадать с последней ценой, взятой из прихода,
-- и (возможно) скорректированной операцией переоценки Reassessment.

as
declare @TranName varchar(11), @Cnt int, @DateR datetime,  @Ncod int,  @Sklad int, 
  @MaxWeight decimal(12,3),  @AvgPrice money, @AvgCost Money, @SumWeight decimal(12,3),
	@Ncom int, @NewID int, @SerialNom int, @DCK int, @our_id int, @TotalSP decimal(10,2), 
  @TotalSC decimal(12,5), @skl bit, @LastID int, 
  @LCost1kg decimal(15,5), @LPrice1kg decimal(12,2), @FirstIzmId int, @LastNcom int,
  @MinDateR datetime, @MinSrokH datetime;

begin
  set @KolError=0;
  set @TranName='AutoDivPlus';
  set @SerialNom=0;
  delete from ParamSklad where Comp=@Comp;
 	
	begin tran @TranName
  create table #SL(Sklad int);
  insert into #SL select * from dbo.Str2intarray(@SkList);

  set @skl=iif(exists(select 1 from SkladList s join #sl l on l.sklad=s.skladno and s.discard=1),1,0)

  
  if object_id('tempdb..#oper') is not null drop table #oper
  create table #oper (sklad int, dater datetime, ncod int, cnt int, dck int, our_id int)
  
  if @skl=0
    insert into #oper
    select 
      vi.sklad,  min(vi.dater) as DateR, vi.ncod, count(vi.hitag) as Cnt, max(vi.dck) DCK, vi.our_id
    from 
      tdvi vi
      inner join #SL on #SL.Sklad=Vi.Sklad
    where 
      vi.hitag=@Hitag
      and vi.locked=0 and vi.LockID=0
      and vi.morn-vi.sell+vi.isprav-vi.remov<>0
      and cast(vi.Weight as float)>0
      AND vi.id>0
      group BY vi.sklad, vi.ncod, vi.our_id
  else
    insert into #oper
    select 
      vi.sklad, null DateR,vi.ncod, count(vi.hitag) as Cnt, max(vi.dck) DCK, vi.our_id
    from 
      tdvi vi
      inner join #SL on #SL.Sklad=Vi.Sklad
    where 
      vi.hitag=@Hitag
      and vi.locked=0 and vi.LockID=0
      and vi.morn-vi.sell+vi.isprav-vi.remov<>0
      and cast(vi.Weight as float)>0
      AND vi.id>0
      group BY vi.sklad, vi.ncod, vi.our_id
      having count(hitag)>1 

  
PRINT('КОНТРОЛЬНАЯ ТОЧКА 1 ПРОЙДЕНА');  
  declare C1 cursor fast_forward for select * from #oper;

  delete from ParamSklad where Comp=@Comp;

  open C1;
PRINT('КОНТРОЛЬНАЯ ТОЧКА 2 ПРОЙДЕНА');  
  fetch next from C1 into @Sklad,@DateR,@Ncod, @Cnt,@DCK,@our_id;
  WHILE (@@FETCH_STATUS=0)
  begin  
PRINT('КОНТРОЛЬНАЯ ТОЧКА 3 ПРОЙДЕНА');  
    -- Подготовка исходных строк для слияния:
    delete from ParamSklad where Comp=@Comp;
    insert into ParamSklad (Comp, Act,Id,Hitag,Sklad,Weight,Price,Cost,Nomer,Qty,Ncom,Ncod) 
    select 	@Comp, 
						'Div-', 
						vi.id, 
						@Hitag, 
						@Sklad, 
						vi.weight, 
						vi.price, 
						vi.cost,
      			ROW_NUMBER() over (order by vi.id), 
						vi.morn-vi.sell+vi.isprav-vi.remov,
      			vi.ncom, vi.Ncod
    from
      tdvi vi
    where
      vi.sklad=@sklad 
			-- and isnull(vi.dater,'20010101')=iif(@skl=0,@dater,isnull(vi.dater,'20010101'))
			and vi.hitag=@hitag
      and vi.locked=0 
			and vi.LockID=0
      and vi.morn-vi.sell+vi.isprav-vi.remov<>0
      and cast(vi.weight as float)<>0
      and vi.id>0
      and vi.our_id=@our_id;     
PRINT('КОНТРОЛЬНАЯ ТОЧКА 4 ПРОЙДЕНА');  
    
		-- Подготовка новой строки, куда попадет полная сумма:
    set @MaxWeight=(select max(Weight) from ParamSklad where Comp=@Comp);
    
    set @Ncom=(select max(Ncom) from ParamSklad where Comp=@Comp);


    /*************************************************************************        
     *    -- ЗДЕСЬ, ВИКТОР!  Согласовано с Карнушиным 13.06.2016.            *
     *  Будем исходить из следующих соображений: стоимость остатка товара    *
     *  на складе не должна измениться по результатам операции слияния, ни   *
     *  в ценах прихода, ни в ценах продажи. Тогда не пострадает ни склад,   *
     *  ни сальдо поставщика. Вес тоже не изменится!                         *
     *====================================================================== *
     *     -- Здесь, Виктор! Согласовано с Карнушиным 22.11.2017.            *
     *  Новая постановка задачи: цена прихода 1 кг товара после операции     *
     *  слияния должна совпасть с исходной (т.е. в момент прихода) ценой 1 кг*
     *  возможно, скорректированной по результату переоценки с комментарием  *
     *  Reassessment. И брать последнюю по времени цену прихода.             *
     *====================================================================== *
     *     -- Здесь, Виктор! Согласовано с Карнушиным 28.03.2018.            *
     *  Уточнение задачи: требуется сливать в одну кучу товары даже и с      *
     *  разными датами поставки и сроками хранения. И брать минимальные.     *
     *************************************************************************/
     select 
        @SumWeight=sum(qty*weight), @TotalSP=sum(Price*qty), @TotalSC=sum(Cost*qty)
     from ParamSklad 
     where Comp=@Comp;
PRINT('КОНТРОЛЬНАЯ ТОЧКА 5 ПРОЙДЕНА');  
    -- Какая была последняя поставка товара в inpdet? 
    set @LastID = (select max(i.ID) from inpdet i inner join Comman C on C.Ncom=i.Ncom where i.Hitag=@Hitag and c.Ncod=@Ncod);

    -- Цена 1 кг в момент прихода, возможно, null, если вес не был указан:
    set @LCost1kg=NULL; -- вот эта инициализация нужна, ибо SELECT ведь может и не сработать.
    set @LPrice1kg=NULL; 
    select @LCost1kg=Cost/weight, @LPrice1kg=Price/weight from Inpdet where ID=@LastID and isnull(weight,0)>0;
    
    -- Ищем первую переоценку:
    set @FirstIzmId=(select izmid from izmen where ID=@LastID and remark='reassessment' and isnull(weight,0)>0); 
    if @FirstIzmId is not null -- Была переоценка?
      select @LCost1kg=NewCost/weight, @LPrice1kg=NewPrice/Weight from Izmen where Izmid=@FirstIzmId;
    
    -- Если не удалось найти последнюю цену, действуем по-старому, с сохранением общей суммы:
    if @LCost1kg is null
      insert into ParamSklad(Comp, Act,Id,Hitag,Sklad,Weight,Price,Cost,Nomer,Qty,Ncom) 
      values(@Comp,'Div+',null,@Hitag,@Sklad,@SumWeight,@TotalSP,@TotalSC,0,1,@Ncom);
    else -- а если удалось, используем найденные цены за единицу веса:
      insert into ParamSklad(Comp, Act,Id,Hitag,Sklad,Weight,Price,Cost,Nomer,Qty,Ncom) 
      values(@Comp,'Div+',null,@Hitag,@Sklad,@SumWeight,@LPrice1kg*@SumWeight,@LCost1kg*@SumWeight,0,1,@Ncom);

PRINT('КОНТРОЛЬНАЯ ТОЧКА 6 ПРОЙДЕНА');  
    exec ProcessSklad 'Div+', -- act
      null, null, null,  -- id, newHitag,newSklad
      0,0,0, 			 -- newPrice,newCost,Delta
      @OP,@Comp,null,  -- Op,Comp,IrID
      0, 1, -- ServiceFlag, divFlag 
      0, 0, -- TrancmDec,TransmAdd
      @Ncod, 'autoDivPlus', @NewID, @SerialNom, 
      @KolError, @DCK, 0, @SumWeight; -- KolError, DCK,  junk, NewWeight
    if @NewID>0 begin
      select 
        @MinDater=min(v.dater), @MinSrokh=min(v.srokh) 
        from ParamSklad P inner join TDVI V on V.ID=P.Id where P.Comp=@Comp and P.Act='Div-';
      update TDVI set DateR=@MinDateR, Srokh=@MinSrokh where ID=@NewID;
    end;

      /*  Аргументы ProcessSklad:
          @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint, 
          @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, 
          @Op int, @Comp varchar(30), @irId int, 
          @ServiceFlag bit=0, @DivFlag bit=0, 
          @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran"
          @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
          @remark varchar(40), @Newid int out, 
          @SerialNom int=0 out,  -- Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
          @kolError int out, @Dck INT=0, @Junk int=0, 
          @NewWEIGHT decimal(12, 3)=0 -- это входной параметр для операции "Tran"
      */    
    
    fetch next from C1 into @Sklad,@DateR,@Ncod, @Cnt,@DCK,@our_id;
  end;
  close c1;
  deallocate c1;
  
	if @KolError=0 
		commit tran @tranname 
	else 
		rollback tran @tranname;
  
  --	delete from ParamSklad where Comp=@Comp;
  if object_id('tempdb..#oper') is not null drop table #oper
END