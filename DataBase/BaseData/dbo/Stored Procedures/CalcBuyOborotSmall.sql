CREATE PROCEDURE dbo.CalcBuyOborotSmall @b_idIn int,@master int, @date1 datetime, @date2 datetime
AS DECLARE @saldo money
BEGIN
  create table #TempTable (ND datetime,B_Id int ,TM varchar(8), DatNumber int,Actn bit,
       Srok int,SP money,SC money,Extra float,OurId int,Sum money,IzmSum money, Remark varchar(80), Back money);
  if @master=0 
  begin
      insert into  #TempTable (ND,B_Id ,TM, DatNumber,Actn,Srok,SP,SC,Extra,OurId,Sum,IzmSum, Remark, Back)

      select nc.ND,nc.B_Id ,nc.TM,cast(RIGHT(nc.DatNom,4) as int)as DatNumber,IsNull(nc.Actn,0),
           nc.Srok, nc.SP, nc.SC,nc.Extra, nc.OurId,null ,null,'',Sum(IsNull(A.Back,0))as Back
      from NC  
      left join
      (select Sum(Sp) as Back, refDatNom as DNom from NC
      group by refDatNom )A on A.DNom=nc.DatNom
      where B_Id=@b_idIn
      and nd>=@date1 and nd<=@date2 and (nc.RefDatnom=0 or nc.RefDatnom is null) and Tara=0 and Frizer=0
      group by nc.ND,nc.B_Id ,nc.TM,nc.Actn,nc.DatNom,
               nc.Srok, nc.SP, nc.SC,nc.Extra, nc.OurId,nc.Back 
    union 
      select ks.Nd,min(B_Id),min(ks.Tm),null,IsNull(ks.Actn,0),null,null,null,null,null,
      case 
        when ks.Act='ВЫ' then SUM(ks.Plata)
        else null
      end,null, null, null
      from Kassa1 ks
      left JOIN
      (select Isnull(Frizer,0)as Friz, DatNom from NC)a on a.DatNom=ks.SourDatNom
      where B_Id=@b_idIn 
       and nd>=@date1 and nd<=@date2 and oper=-2 and (ks.Act='ВЫ')  and (a.Friz=0 or a.Friz is null)
      group by ks.Nd,ks.Actn,ks.Act 
      having SUM(ks.Plata)!=0 
    union
      select izm.Nd,min(izm.B_Id),min(izm.TM),null,0,null,null,null,null,null,
             NULL,SUM(izm.Izmen),izm.Remark, null
      from NCIzmen izm
      where B_Id=@b_idIn
        and nd>=@date1 and nd<=@date2
      group by izm.Nd,izm.Remark
      order by  ND,Tm;
  end
  begin
      insert into  #TempTable (ND,B_Id ,TM, DatNumber,Actn,Srok,SP,SC,Extra,OurId,Sum,IzmSum, Remark, Back)

      select nc.ND,nc.B_Id ,nc.TM,cast(RIGHT(nc.DatNom,4) as int)as DatNumber,IsNull(nc.Actn,0),
           nc.Srok, nc.SP, nc.SC,nc.Extra, nc.OurId,null ,null,'',Sum(IsNull(A.Back,0))as Back
      from NC  
      left join
      (select Sum(Sp) as Back, refDatNom as DNom from NC
      group by refDatNom )A on A.DNom=nc.DatNom
      where  B_Id in (select pin from Def where master=@b_idIn)
      and nd>=@date1 and nd<=@date2 and (nc.RefDatnom=0 or nc.RefDatnom is null)
      and Tara=0 and Frizer=0
      group by nc.ND,nc.B_Id ,nc.TM,nc.Actn,nc.DatNom,
               nc.Srok, nc.SP, nc.SC,nc.Extra, nc.OurId,nc.Back 
    union 
      select ks.Nd,min(B_Id),min(ks.Tm),null,IsNull(ks.Actn,0),null,null,null,null,null,
      case 
        when ks.Act='ВЫ' then SUM(ks.Plata)
        else null
      end,null, null, null
      from Kassa1 ks
      left JOIN
      (select Isnull(Frizer,0)as Friz, DatNom from NC)a on a.DatNom=ks.SourDatNom
      where B_Id in (select pin from Def where master=@b_idIn)and nd>=@date1 and nd<=@date2
        and (ks.Act='ВЫ') and oper=-2 and (a.Friz=0 or a.Friz is null)
      group by ks.Nd,ks.Actn,ks.Act 
      having SUM(ks.Plata)!=0 
    union
      select izm.Nd,min(izm.B_Id),min(izm.TM),null,0,null,null,null,null,null,
             NULL,SUM(izm.Izmen),izm.Remark, null
      from NCIzmen izm
      where B_Id in (select pin from Def where master=@b_idIn)and nd>=@date1 and nd<=@date2
      group by izm.Nd,izm.Remark
      order by  ND,Tm;
  end
  
 if @master=0
  BEGIN
    set @saldo=(select IsNull(sum(IsNull(nc.Sp,0)),0)-IsNull(Sum(IsNull(Ks.Sum,0)),0)
                                +IsNull(Sum(IsNull(Iz.Sum,0)),0) as Balance
                from NC-- nc
                Left JOIN
                (select sum(Plata) as Sum, ks.B_Id,ks.SourDatNom 
                from Kassa1 ks
                where nd<@date1 and (ks.Act='ВЫ' or ks.Act='ВО')  and oper=-2 
                group by ks.B_Id,ks.SourDatNom )Ks on ks.B_id=nc.B_Id and ks.SourDatNom=nc.DatNom
                Left JOIN
                (select sum(Izmen) as Sum,B_ID,DatNom
                from NCIzmen iz
                where iz.Datnom>501010000 and  iz.nd<@date1
                group by iz.B_Id,DatNom)IZ on iz.B_id=nc.B_Id and iz.DatNom=nc.DatNom
                where nc.B_Id=@b_idIn
                     and  nc.nd<@date1 and Tara!=1 and Frizer!=1 and Actn!=1
                group by nc.B_Id )
    if @saldo is null  set @saldo=0
  END
  else
  BEGIN
    set @saldo=(select IsNull(sum(IsNull(nc.Sp,0)),0)-IsNull(Sum(IsNull(Ks.Sum,0)),0)+
                       (select IsNull(sum(IsNull(Izmen,0)),0) as Sum from NCIzmen iz
                        where   iz.nd<@date1 and iz.Datnom>501010000
                               and B_Id in (select pin from Def where master=@b_idIn)) as Balance
                        from NC-- nc
                        Left JOIN
                        (select sum(Plata) as Sum, SourDatNom 
                        from Kassa1 ks
                        where nd<@date1 and (ks.Act='ВЫ' or ks.Act='ВО')  and oper=-2 and
                                          B_Id in (select pin from Def where master=@b_idIn) 
                        group by SourDatNom )Ks on ks.SourDatNom=nc.DatNom
                        where nc.B_Id in (select pin from Def where master=@b_idIn) 
                              and  nc.nd<@date1 and Tara!=1 and Frizer!=1 and Actn!=1)
    if @saldo is null  set @saldo=0
  END
                  
  create table #Table2 (ND datetime,B_Id int ,TM varchar(8), DatNumber int,Actn bit,
       Srok int,SP money,SC money,Extra float,OurId int,Sum money,IzmSum money,
       Remark varchar(80), Back money,saldo1 money, saldo2 money)              
  
   
  
  DECLARE @ND datetime,@B_Id int ,@TM varchar(8), @DatNumber int,@Actn bit,
       @Srok int,@SP money,@SC money,@Extra float,@OurId int,@Sum money,@IzmSum money,
       @Remark varchar(80),@Back money, @saldo1 money, @saldo2 money;
       
 /*Объявляем курсор*/
  DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR SELECT * FROM #TempTable
  /*Открываем курсор*/
  OPEN @CURSOR
  /*Выбираем первую строку*/
  FETCH NEXT FROM @CURSOR INTO @ND,@B_Id,@TM, @DatNumber,@Actn,@Srok,@SP,@SC,@Extra,@OurId,@Sum,
                  @IzmSum,@Remark,@Back
  set @saldo1=@saldo   
  
  
  if (@Actn=0)
  begin               
    if (@SP is not null) 
    begin
      set @saldo2=@saldo1+@SP
      if (@Back is not null)
        set @saldo2=@saldo2+@Back
    end
    else if (@Sum is not null) set @saldo2=@saldo1-@Sum            
    else if (@IzmSum is not null) set @saldo2=@saldo1+@IzmSum
  end
  else 
    set @saldo2=@saldo1
               

  
  
   /*Выполняем в цикле перебор строк*/
  WHILE @@FETCH_STATUS = 0
  BEGIN
 
    INSERT INTO #Table2 (ND,B_Id,TM, DatNumber,Actn,
       Srok,SP,SC,Extra,OurId,Sum,IzmSum,
       Remark,Back, saldo1, saldo2)
       VALUES (@ND,@B_Id,@TM, @DatNumber,@Actn,
       @Srok,@SP,@SC,@Extra,@OurId,@Sum,@IzmSum,
       @Remark,@Back, @saldo1, @saldo2)
  
    FETCH NEXT FROM @CURSOR INTO @ND,@B_Id,@TM, @DatNumber,@Actn,@Srok,@SP,@SC,@Extra,@OurId,@Sum,
                    @IzmSum,@Remark,@Back
    set @saldo1=@saldo2  
    if (@Actn=0)
    begin                                   
      if (@SP is not null) 
      begin
        set @saldo2=@saldo1+@SP
        if (@Back is not null)
          set @saldo2=@saldo2+@Back
      end
      else if (@Sum is not null) set @saldo2=@saldo1-@Sum            
      else if (@IzmSum is not null) set @saldo2=@saldo1+@IzmSum 
    end
    else 
      set @saldo2=@saldo1 
  END
  
  CLOSE @CURSOR
  
  declare @ourName varchar(100)
  set @ourName=(select ourName from FirmsConfig
                where our_id=(select our_id from Def where tip=1 and pin=@b_idIn))
  if IsNull(@ourName,'')=''
    set @ourName='ООО "Торговый дом "Морозко"';
  
  select *,@ourName as ourName from #Table2       
  
  
END