CREATE procedure dbo.SaveNakl_copy
  @CompName varchar(30), @B_ID int, @Fam varchar(30)='',
  @Our_ID smallint=0, @Ag_ID smallint=null, @OP smallint,  @Srok int=null, 
  @Pko bit,  @Man_ID int, @tovchk bit=0,  @remark varchar(255),  @Actn bit=0, 
  @Ck bit, @Tomorrow bit, @RefDatNom bigint=0, @Frizer bit=0, @DatNom bigint=0 out, 
  @DayShift tinyint=0,  @RemarkOp varchar(50)='',  @OrderDate  datetime=null, 
  @OrderDocNumber varchar(35)='', @DCK int=0, @B_ID2 int=0, @NeedDover bit=0, 
  @Stip tinyint=0, @Tara bit=0, @flgRezerv bit=0, @KolError int=0 out, @NeedDover2 smallint=0,
  @QtyNakl int=0 out, @Startdatnom bigint=0, @Rk int=0, @VendDCK int=0
as 
 declare @ids varchar(max);
 declare @inMarsh99 bit, @DelivGroup INT,  @Box int, @TekId int, @RefTekId int, @NewTekId int, @Nds int
 declare @Extra decimal(7,2), @RetExtra decimal(7,2)
 declare @ND datetime, @SourDate datetime, @TM char(8), @Stfdate datetime, @DocDate datetime
 declare @StfNom varchar(17), @DocNom varchar(20), @SourNnak int
 declare @Qty decimal(10,3), @BoxQty decimal(10,2), @Weight decimal(10,2), @SP decimal(10,2), @SC decimal(10,2), @price decimal(14,4)
 declare @TaraAct char(2), @SerialNom int
 declare @Nnak int, @ContrTip smallint
 declare @KolErrorSklad int
 declare @Marsh int, @Sklad int
 declare @Sk50present bit, @EffWeight float, @Cost money
 declare @RemarkKassa varchar(50), @RemarkKassa2 varchar(20)
 declare @gpOur_ID int, @Ncod int, @mhid int
 declare @TekDay datetime, @DatnomOffset bigint, @NaklCount int, @NewNcId int
 declare @Done bit, @SPsm decimal(10,2), @worker bit, @gpName varchar(255), @DepID int 
 declare @dn0 bigint, @dn1 bigint, @master int, @flgExclude bit, @flgExclSausage bit, @DocType smallint
 declare @stfnom_upd varchar(17), @num_except bit, @PricePrecision smallint, @CountZK int
begin
--  set transaction isolation level snapshot

  print '[SaveNakl]: СТАРТ'

  set @inMarsh99=@tovchk
  set @KolError = 0 
  set @dn0 = dbo.InDatNom(00001, dbo.today())
  set @dn1 = dbo.InDatNom(99999, dbo.today())  
  set @ND=convert(char(10), getdate(),104);
  set @TM=convert(char(8), getdate(),108);
 
  set @SPsm=0;

  create table #F(tekid int, Kol int, Cost decimal(13,5), Price decimal(12,2), datnom bigint);
  if @b_id2 is null set @b_id2=0;
   
  select @b_id=dc.pin, @ContrTip=dc.ContrTip, @PricePrecision=dc.PricePrecision from defcontract dc where dc.DCK=@dck;

  if (@stfdate=0) or (@StfDate='18991230') or (@StfDate<'19900101') set @stfdate=null;

  if @ContrTip=7 set @stip=4;
  
  if @stip=4 and @ContrTip<>7 set @KolError = @KolError | 2048;
  
  set @Actn=(select Actn from NC_ShippingType where stip=@stip);

  select @gpName=d.gpName, @tovchk=d.tovchk, @worker=d.worker, @master=iif(d.master>0, d.master, d.pin) 
  from def d where d.pin=@b_id 
  
  --проверка на исключение по номеру документа
  if @master in (37008,41782,42547,43363)
    set @num_except=1 
    else set @num_except=0 
  
  if exists(select * from DefExclude where ExcludeType=1 and Pin=@Master) set @flgExclude=1;
  else set @flgExclude=0;
  
  if exists(select * from DefExclude where ExcludeType=2 and Pin=@Master) set @flgExclSausage=1;
  else set @flgExclSausage=0; 
  
  if @b_id=3434 or @b_id=7500 
       set @Fam=@gpName+' '+@Fam;
  else set @Fam=@gpName

  if (@Remarkop='') or (@Remarkop like '%}%') set @Remarkop=left(right(@remark, len(@remark)-CHARINDEX('}', @remark)),50);
  
  --  if @RefDatNom is null or @Refdatnom=0 set @TaraAct='ТП'; else set @TaraAct='ТВ';
  if @Tomorrow=0 set @DayShift=0; else if @Tomorrow=1 and @DayShift=0 set @DayShift=1;
  
     
  -- Заказ содержится в табл. ZAKAZ, естественно. 
  set @CountZK=isnull((select Count(*) from Zakaz where CompName=@CompName),0)
  print '[SaveNakl]: Строк в ZAKAZ: '+cast(@CountZK as varchar)
  
  if EXISTS(select * from Zakaz where CompName=@CompName) 
  BEGIN
    print '[SaveNakl]: Данные обнаружены '
  
    --    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
    --    SET TRANSACTION ISOLATION LEVEL READ COMMITTED
    BEGIN TRANSACTION SaveNewNakls; 
      
      --здесь курсор по Zakaz.tekid=-1 - вставка в tdVI c weight=EffWeight и update tekid в Zakaz:
      declare CurBack cursor local fast_forward
        for select reftekid,qty,price,Sklad,EffWeight,cost,RefDatnom
        from Zakaz where CompName=@CompName and tekid=-1 order by reftekid;
      open CurBack;
      fetch next from CurBack into @reftekid, @qty, @price, @Sklad, @EffWeight, @Cost, @Refdatnom;
      WHILE (@@FETCH_STATUS=0)
      begin

        if EXISTS(select * from tdVi where id=@reftekid) 
          insert into tdvi(nd,startid, ncom, ncod, datepost, price, [start], startthis, hitag, 
             sklad, cost, minp, mpu, sert_id, rang, 
             morn, sell, isprav, remov, bad, dater, srokh, [country], rezerv, units, locked, ncountry, gtd, vitr, our_id,
             [weight], SaveDate, measid, OnlyMinP, AddrID, DCK, ProducerID, CountryID, pin)
          select v.datepost as nd, v.startid, v.ncom, v.ncod, v.datepost, iif(n.flgWeight=1 and @Effweight<>0, round(@price*@Effweight,2), @price), v.start, 0, v.hitag,
             @sklad sklad, iif(n.flgWeight=1 and @Effweight<>0, round(@cost*@Effweight,2), @cost), v.minp, v.mpu, v.sert_id, v.rang, 
             0, 0, 0, 0, 0, v.dater, v.srokh, v.country, 0, v.units, 0, v.ncountry, v.gtd, 0, v.our_id,
             @Effweight, v.datepost as savedate, v.measid, v.OnlyMinP, v.AddrID, v.DCK, v.ProducerID, v.CountryID, v.pin
          from tdvi v join nomen n on v.hitag=n.hitag where v.id=@reftekid;
        else
          insert into tdvi(nd,startid, ncom, ncod, datepost, price, [start], startthis, hitag, 
             sklad, cost, minp, mpu, sert_id, rang, 
             morn, sell, isprav, remov, bad, dater, srokh, [country], rezerv, units, locked, ncountry, gtd, vitr, our_id,
             [weight], SaveDate, measid, OnlyMinP, AddrID, DCK, ProducerID, CountryID, pin)
          select v.datepost as nd, v.startid, v.ncom, v.ncod, v.datepost, iif(n.flgWeight=1 and @Effweight<>0, round(@price*@Effweight,2), @price), v.start, 0, v.hitag,
             @sklad sklad, iif(n.flgWeight=1 and @Effweight<>0, round(@cost*@Effweight,2), @cost), v.minp, v.mpu, v.sert_id, v.rang, 
             0, 0, 0, 0, 0, v.dater, v.srokh, v.country, 0, v.units, 0, v.ncountry, v.gtd, 0, v.our_id,
             @Effweight, v.datepost as savedate, v.measid, 0, null, v.DCK, v.ProducerID, v.CountryID, v.pin
          from Visual v join nomen n on v.hitag=n.hitag where v.id=@reftekid;
          
        set @newTekId=SCOPE_IDENTITY();
-- create table nv_join (datnom int, refdatnom int, tekid int, reftekid int, weight decimal(10,3))
        update Zakaz set tekid=@NewTekId where tekid=-1 and CompName=@CompName and RefTekId=@RefTekId;
        
        insert into nv_join(datnom, refdatnom, tekid, reftekid, weight)
        values(null,@refdatnom,@NewTekId,@RefTekID,@Effweight); 
        
        fetch next from CurBack into @reftekid, @qty, @price, @Sklad, @EffWeight, @Cost, @Refdatnom;
      end;
      close CurBack;
      deallocate CurBack;      
       
      -- Если в TDVI нет нужных строчек, придется выдернуть ее из VISUAL:	 
      SET IDENTITY_INSERT tdvi ON; -- отключаю автоинкремент

      insert into tdvi(nd,id,startid, ncom, ncod, datepost, price, [start], startthis, hitag, sklad, cost, minp, mpu, sert_id, rang, 
         morn, sell, isprav, remov, bad, dater, srokh, [country], rezerv, units, locked, ncountry, gtd, vitr, our_id,
         [weight], SaveDate, measid, OnlyMinP, AddrID, DCK, ProducerID, CountryID, pin)
      select distinct v.datepost as nd,v.id,v.startid, v.ncom, v.ncod, v.datepost, v.price, v.start, 0, v.hitag,
         case when isnull(z.sklad,0)=0 then v.sklad else z.sklad end as sklad, v.cost, v.minp, v.mpu, v.sert_id, v.rang, 
         0, 0, 0, 0, 0, v.dater, v.srokh, v.country, 0, v.units, 0, v.ncountry, v.gtd, 0, v.our_id,
         v.weight, v.datepost as savedate, v.measid, 0, null, v.DCK, v.ProducerID, v.CountryID, v.pin
      from visual v inner join Zakaz z on v.id=z.tekid 
      where z.CompName=@CompName and z.tekid not in (select id from tdvi);
         
      SET IDENTITY_INSERT tdvi OFF; -- включаю автоинкремент
      --insert into Log_temp(mess) VALUES(convert(char(10), getdate(),104));	
      -- Внутри табл. Zakaz могут быть данные сразу нескольких накладных, различаются по полю DelivGroup:
      
      --if @RefDatNom > 0 update Zakaz set MainExtra=@RetExtra where CompName=@CompName;
      
      
      print '[SaveNakl]: Подготовка к созданию накладных...DCK='+Cast(@DCK as varchar);
      
      declare CurDeliv2 cursor local fast_forward  
      for select distinct iif(@flgExclSausage=1,0,DelivGroup) as DelivGroup, MainExtra, StfDate, Stfnom, DocNom, DocDate, RefDatnom, DCK
          from Zakaz where Compname=@CompName order by DelivGroup, RefDatnom;
      open CurDeliv2; 
      fetch next from CurDeliv2 into @DelivGroup,@Extra,@StfDate,@StfNom, @DocNom, @DocDate, @RefDatnom, @DCK;
      set @QtyNakl = 0; -- пока кол-во созданных накладных 0
      if @RefDatNom=0 set @DocType=0 /*Реализация*/
      else if exists(select * from zakaz where Compname=@CompName and qty>0) set @DocType=1 /*Добивка*/
      else set @DocType=2 /*Возврат или вычерк*/
       
      
/*=======================================================ЦИКЛ СОЗДАНИЯ НАКЛАДНЫХ====================================================================*/
      WHILE (@@FETCH_STATUS=0)
      BEGIN
        print '[SaveNakl]: Cursor CURDELIV2, @DelivGroup='+cast(@DelivGroup as varchar(8))
        -- insert into Log_temp(mess,DatNom) VALUES('DelivGroup=',@DelivGroup);	
        -- Проход по списку накладных:   
        
        select @Our_ID=dc.Our_id, @Srok=dc.srok, @ContrTip=dc.ContrTip, @gpOur_id=dc.gpOur_ID, @ag_id=dc.ag_id 
        from defcontract dc where dc.DCK=@dck;
        
        if @stip=4 begin
          -- set @Ncod=(select max(tdvi.ncod) from tdvi inner join Zakaz Z on tdVi.id=z.tekid where z.CompName=@CompName);
          -- set @gpOur_ID=(select max(dc.dck) from defcontract DC inner join Def on dc.dck=Def.pin where Def.Ncod=@ncod );

          set @gpOur_ID = isnull(@VendDCK,0)
          if @gpOur_ID = 0 
            set @gpOur_ID = (select max(tdvi.DCK) from tdvi inner join Zakaz Z on tdVi.id=z.tekid where z.CompName=@CompName)

          if not exists (select 1 from defcontract where contrtip=5 and dck=@gpOur_ID)
            set @KolError=@KolError | 1024
         
        end;
        
        set @DepID=(select DepID from agentlist where ag_id=@ag_id);
        
        if @stip>0 or @Our_ID=10 or @Our_ID=18 or @Our_ID=19 or @Our_ID=20 set @flgExclude=1;
        
        if @RefDatNom is null or @Refdatnom=0 set @TaraAct='ТП'; else set @TaraAct='ТВ';
        
        if @RefDatNom>0 
          select @stip=c.stip, @dck=c.dck, @RetExtra=c.extra, @Actn=c.Actn,
                 @Frizer=c.Frizer, @Tara=c.Tara from nc c where c.datnom=@RefDatNom;
        else
          set @SPsm=isnull((select sum(sp) from nc where datnom >= @dn0 and datnom <= @dn1 and sp>0 and b_id=@b_id),0); 
                   
        select  @BoxQty=sum(z.Qty/VI.minp/vi.mpu),
                @Weight=sum(z.Qty*z.effWeight),
                @SP=(1.0+isnull(@Extra,0)/100.0)*sum(z.Price*z.Qty),          
                @SC=sum(z.Cost*z.Qty)
        from Zakaz z inner join tdVi vi on vi.id=z.tekid 
        where z.CompName=@CompName and z.DelivGroup=@DelivGroup 
              and isnull(mainextra,0)=isnull(@extra,0) and isnull(stfnom,'')=isnull(@stfnom,'') and z.RefDatnom=@RefDatnom;        
            
       /*   
        set @BoxQty=isnull(@BoxQty,0);
        set @Weight=isnull(@Weight,0);
        set @SP=isnull(@SP,0);
        set @SC=isnull(@SC,0);
       */ 
      -- Временный фиктивный Datnom, нумерация в пределах текущего дня, в последних 10 тысячах номеров:
  		set @datnom=round(90000+10000*RAND(),0) + isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));
      print('Временный фиктивный @datnom = '+cast(@datnom as varchar))
        
        set @sk50present=0;
        
        -- Может, это холодильник или ларь?
        if exists(select z.hitag from Zakaz Z inner join Nomen N on N.hitag=Z.hitag 
                  where N.Ngrp in (19,21) and z.CompName=@CompName and z.DelivGroup=@DelivGroup 
                  and isnull(mainextra,0)=isnull(@extra,0) and z.stfnom=@stfnom)
        set @Frizer=1; else set @Frizer=0;

        -- Какое смещение нумерации сегодня?  
        select @TekDay=cast(val as datetime),  @DatnomOffset=cast(Comment as bigint) from Config where Param='DatnomOffset'
        if cast(@TekDay as datetime)<>dbo.today() 
        begin
          set @NaklCount=(select count(*) from nc where ND=dbo.today())
          if @Naklcount=0
            set @DatnomOffset = dbo.fnDatNom(dbo.today(),1) - (select max(ncid) from nc);
          else 
            set @DatnomOffset = (select top 1 datnom-ncid from nc order by datnom desc);
          update Config set val=convert(varchar, dbo.today(), 104), Comment=@DatnomOffset where Param='DatnomOffset';
        end

        --Изменение срока консигнации
        if (@DelivGroup=1 and @Srok>7) set @Srok=7;

        
		    set @Marsh=0;
        set @Mhid=0;	

        if @inMarsh99=1 or @worker=1 or @stip=5 begin
          set @mhid=-99;
          set @Marsh=99;
        end;
        else if @RefDatNom>0 and @SP>=0 begin
          select @Marsh=Marsh, @mhid=isnull(mhid,0) from nc where datnom=@RefDatnom;
          set @ids=cast(@datnom as varchar)+';1;0#';
          if @mhid<>0 --нужно ли вставлять в маршрут
          exec NearLogistic.MarshRequetOperations @ids,@mhid,@op,0;
        end;
        
        
        -- Заголовок накладной.
        -- поле StartDatnom используется начиная с 28.07.2017 - Виктор.
        
        print '[SaveNakl]: Вставка в NC, @DCK='+cast(@DCK as varchar)+' @Datnom='+cast(@datnom as varchar)+', @STIP='+cast(@Stip as varchar)
        
        insert into NC (ND,datnom,StartDatnom,B_ID,Fam,Tm,OP,SP,SC,
                       Extra,Srok,OurID,Pko,Man_ID, 
                       BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
    	               Remark,Printed,Marsh,BoxQty,WEIGHT1,Actn,CK,Tara,
                       RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift,
                       Comp, Sk50present, DCK, B_ID2, NeedDover, DoverM2, DocNom, DocDate, STip, gpOur_ID, mhid)
        values (@ND,@datnom,@Datnom,@B_ID,@Fam,convert(char(8), getdate(),108),@OP,@SP,@SC,
	             @Extra,@Srok,@Our_ID,@Pko,@Man_ID, 
	             0,@TovChk,@Frizer,@ag_id,@stfnom,@stfdate,@tomorrow,@Tara,
	             @Remark,0,@Marsh,@BoxQty,@WEIGHT,@Actn,@CK,0,
                 @RefDatNom,0,0, 0, 0.0, @remarkop,
                 @DayShift, @CompName, @Sk50present, @DCK, @B_ID2, @NeedDover,@NeedDover2, @DocNom, @DocDate, @Stip, @gpOur_ID, @mhid);
        if @@Error<>0 set @KolError=@KolError | 1     
        set @NewNCID = scope_identity();

        if @num_except=1 
        set @stfnom_upd = cast(@NewNCID+@DatnomOffset as varchar(18))
        else
        set @stfnom_upd = @stfnom

        update NC 
        set 
        	Datnom=@NewNCID+@DatnomOffset, 
            -- так было до 13.04.2018 - StartDatnom=iif(isnull(@RefDatNom,0)=0, @NewNCID+@DatnomOffset, @RefDatNom),
            StartDatnom = case 
                when @Startdatnom>0 then @startdatnom
                when isnull(@RefDatNom,0)=0 then @NewNCID+@DatnomOffset
                else @Refdatnom
	        end,
            stfnom=@stfnom_upd 
        where NCID=@NewNCID;
        
        if @@Error<>0 set @KolError=@KolError | 2

        set @Datnom=@NewNCID+@DatnomOffset;
        update Nv_Join set Datnom=@Datnom where Refdatnom=@Refdatnom and Datnom is null;
        
		-- Добавлено 09.01.2017 - Виктор:
       /* if isnull(@Marsh,0)=0 update NC set MHID=0 where datnom=@Datnom;
        else update NC set MHID=(select m.mhid from Marsh m where m.nd=dbo.today() 
          and m.marsh=@marsh) where Datnom=@Datnom; 
       */ 
        insert into NVzakaz (datnom,hitag,zakaz,done, price, cost, SkladNo, AuthorOp)
        select @datnom, z.hitag, sum(z.qty), 0, max(z.price), max(z.cost), vi.sklad, @OP         
        from Zakaz z inner join tdVI vi on vi.id=z.tekid
                     inner join SkladList SL on SL.SkladNo=vi.Sklad
                     inner join nomen n on z.hitag=n.hitag
        where
              z.qty>0 and 
              z.CompName=@CompName and z.DelivGroup=@DelivGroup
              and isnull(mainextra,0)=isnull(@extra,0) and isnull(stfnom,'')=isnull(@stfnom,'') and docnom=@docnom
              and SL.UpWeight=1 --and n.flgWeight=1
              and isnull(z.ForcedIntegerSell,0)=0
              and z.RefDatnom=@Refdatnom
        group by z.hitag, vi.sklad     
         
        insert into NV (hitag,datnom,tekid,price,cost,Kol,sklad,kol_b,baseprice,ag_id)
        select z.hitag, @datnom, z.tekid,
                       iif(n.flgWeight=1 and vi.weight<>0, round(z.price*vi.weight,@PricePrecision), z.price),
                       iif(n.flgWeight=1 and vi.weight<>0, round(z.cost*vi.weight, @PricePrecision), z.cost),
                       z.qty, vi.sklad,0,vi.price as BasePrice,
                       iif(@DocType=2,z.Sklad,0)
        from  Zakaz z inner join tdVI vi on vi.id=z.tekid
                      inner join SkladList SL on SL.SkladNo=vi.Sklad
                      inner join nomen n on z.hitag=n.hitag
        where z.CompName=@CompName and z.DelivGroup=@DelivGroup
              and isnull(mainextra,0)=isnull(@extra,0) and isnull(stfnom,'')=isnull(@stfnom,'') and docnom=@docnom
              and (SL.UpWeight=0 or z.qty<0 or z.ForcedIntegerSell=1)
              and z.RefDatnom=@Refdatnom
                
        if @@Error<>0 set @KolError=@KolError | 4

         -- Что именно удалось воткнуть в NV?
        truncate table #F 
        insert into #F(tekid, Kol,Cost,Price, datnom) select tekid, kol,Cost,Price, @datnom 
                                                      from nv where datnom=@datnom;

          -- И на всякий случай пересчитаем суммы по накладной:
        select @SP=round(sum(kol*price*(1.0+@Extra/100.0)),2), @SC=sum(kol*cost) from #F where datnom=@datnom;
		  /*          select @SP=round(sum(kol*price*(1.0+@Extra/100.0)),2), @SC=sum(kol*cost) from NV where Datnom=@Datnom;*/
          
        set @SP=isnull(@sp,0);
        set @SPsm=isnull(@spsm,0);
        set @SC=isnull(@sc,0);
          
        set @Done=iif(((@SPsm+@SP>1500) or @SP<0 or @DepID=3 or @DepID=43 or @DepID=26 or @worker=1 or @flgExclude=1 or @RefDatNom>0),1,0);
        if @B_ID = 28015 set @Done = 0; --для тестовой точки Done=0 
        update nc set SP=@SP, SC=@SC, Done=@Done where datnom=@datnom;
                
        insert into NV_ADD (datnom,tekid,refdatnom,reftekid,WEIGHT,kol, price, cost)
        select @datnom, z.tekid, @RefDatNom, z.RefTekId,z.EffWeight, z.qty, z.price, z.cost
        from Zakaz z 
        where z.CompName=@CompName and z.DelivGroup=@DelivGroup
              and isnull(z.mainextra,0)=isnull(@extra,0) and isnull(z.stfnom,'')=isnull(@stfnom,'') and z.docnom=@docnom and z.tekid<>z.RefTekId
              and @RefDatNom<>0 and z.RefDatnom=@RefDatnom;      
                
        if @@Error<>0 set @KolError=@KolError | 8
         
        -- Информация о заказе Exite, если есть:
        /*if @OrderDocNumber<>'' 
            insert into NC_ExiteInfo(DatNom, OrderDate, OrderDocNumber)
            values(@Datnom, @OrderDate, rtrim(@OrderDocNumber));
        */ 
          -- Возможно, запись отгрузки соответствующей тары в TaraDet:
        set @nnak=dbo.InNnak(@DatNom);
          
          --   Продажа:
          -- В табл. TaraDet Nnak,Selldate,Datnom - это текущая накладная для продаж,
          -- поле RealDatNom пустое.
          --   Возврат:
          -- В табл. TaraDet Nnak,Selldate,Datnom - исходная накладная (из которой возврат происходит),
          -- поле RealDatNom - текущая возвратная накладная.
          
          
        if @TaraAct='ТП' -- отгрузка тары:
            insert into TaraDet(nd,tm,b_id,nnak,sellDate,datNom,act,taraTip,kol,price,op,nakTip,tarId,remark)
                 select @ND, @TM, @B_ID, @nnak, @Nd, @DatNom, @TaraAct, 
                 t.taratip, sum(z.Qty) as Qty, t.taraprice as Price, @Op as op,
                 0, 0, null as remark
                 from Zakaz z inner join Taracode2 T on T.FishTag=z.hitag
                 where z.CompName=@CompName and z.DelivGroup=@DelivGroup
                 and isnull(mainextra,0)=isnull(@extra,0) and isnull(stfnom,'')=isnull(@stfnom,'')
                 group by t.taratip, t.taraprice;
        else -- возврат тары:
            insert into TaraDet(nd,tm,b_id,nnak,sellDate,datNom,act,taraTip,kol,price,op,nakTip,tarId,remark,RealDatNom)
                 select @ND, @TM, @B_ID, dbo.InNnak(@RefDatnom), dbo.DatNomInDate(@RefDatNom), @RefDatNom, @TaraAct, 
                 t.taratip, sum(z.Qty) as Qty, t.taraprice as Price, @Op as op,
                 0, 0, null as remark, @DatNom
                 from Zakaz z inner join Taracode2 T on T.FishTag=z.hitag
                 where z.CompName=@CompName and z.DelivGroup=@DelivGroup
                 and isnull(mainextra,0)=isnull(@extra,0) and isnull(stfnom,'')=isnull(@stfnom,'')
                 group by t.taratip, t.taraprice;
                 
        if @@Error<>0 set @KolError=@KolError | 16
          
         -- Если накладная возвратная и не акция, то надо закрыть ее и исходную тоже:
        if (@RefDatNom>0) and (@Actn=0) and (@DocType=2)
        BEGIN
          set @SourDate=dbo.DatNomInDate(@RefDatNom); -- дата исходной накладной
          set @SourNnak=dbo.InNnak(@RefDatNom);       -- номер исходной накладной
            
          if isnull(@Remark,'') = '' 
          begin 
            set @RemarkKassa = 'Вычерк. '              
            set @RemarkKassa2 = 'Вычерк по накл. № '
          end
          else
          begin
            set @RemarkKassa = 'Возврат. '
            set @RemarkKassa2 = 'Возврат накл. № '                       
          end 
                  
	      insert into Kassa1(Nd,TM, Oper,SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
                        remark, RashFlag,LostFlag,LastFlag,  Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
                        Thr,ThrFam,DocNom,Act, ForPrint, SourDatNom, StNom, DCK)
          values (@ND, @TM, -2, @SourDate,@SourNnak,-@SP, @Fam, 0, @B_ID,0,0,
			      @RemarkKassa+'См. накладную №'+cast(dbo.InNnak(@datnom) as varchar(5))+' от '+convert(char(8), dbo.DatNomInDate(@datnom), 5),
                  0,1,0, @Op,0,@Our_ID,@ND,@Actn,0, null,null,null,'ВО', 0, @RefDatNom, null, @DCK);       
                  
          if @@Error<>0 set @KolError=@KolError | 32
        
          insert into Kassa1(Nd,TM, Oper,SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
                   remark, RashFlag,LostFlag,LastFlag,  Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
                   Thr,ThrFam,DocNom,Act, ForPrint, SourDatNom, StNom, DCK)
          values(@ND, @TM, -2, @ND,dbo.InNnak(@DatNom),@SP, @Fam, 0, @B_ID,0,0,
                  @RemarkKassa2+cast(dbo.InNnak(@RefDatNom) as varchar(5))+' от '+convert(char(8), dbo.DatNomInDate(@refDatNom), 5),
                  0,1,0, @Op,0,@Our_ID,@ND,@Actn,0, null,null,null,'ВО', 0, @DatNom, null, @DCK);       
                  
          if @@Error<>0 set @KolError=@KolError | 64
        END;
      

        -- Коррекция склада, а именно поля Sell и, возможно, поля Rezerv:
        -- declare CurSell cursor fast_forward for select Tekid, Qty from Zakaz where Compname=@CompName;
        declare CurSell cursor local fast_forward for select Tekid, kol as Qty from #f where datnom=@datnom;
        open CurSell;
        fetch next from CurSell into @TekId,@Qty;
      
        WHILE (@@FETCH_STATUS=0)
        BEGIN
          print '[SaveNakl]: CurSell, @Datnom='+cast(@datnom as varchar(11));
          if @flgRezerv=1 
          update tdVi set Sell=isnull(sell,0)+@Qty,
                      Rezerv=case when rezerv-@Qty<0 then 0 else rezerv-@Qty end
          where id=@Tekid;        
          else update tdVi set Sell=isnull(sell,0)+@Qty where id=@Tekid;
      
          if @@Error<>0 set @KolError=@KolError | 128
      
          fetch next from CurSell into @TekId,@Qty;
        END;
      
        close CurSell;
        deallocate CurSell;      
      
        -- Коррекция исходной накладной, если это возврат:
        if (@RefDatNom>0) and (@DocType=2)
        BEGIN
        
          if isnull(@Rk,0)<>0
            insert into dbo.ReqReturnNCLink (rk, datnom) 
            values (@Rk,  @Datnom);
        
          print '[SaveNakl]: Корр. исх. накл. @Datnom='+cast(@Refdatnom as varchar(11))+' возвратн. накладная №'+cast(@datnom as varchar);
          update RemToRtrn set Datnom=@Datnom where SourDatnom=@RefDatnom and isnull(Datnom,0)=0
          
          declare CurSell cursor fast_forward 
          for select Zakaz.RefTekid, #f.Kol 
          from Zakaz join #f on Zakaz.tekid=#f.tekid -- ДОБАВЛЕНО 28.05.2015
          where Compname=@CompName 
          and #f.Kol<>0 
          and isnull(zakaz.RefTekId,0)>0 
          and isnull(zakaz.reftekid,0)=isnull(zakaz.tekid,0)
          and RefDatnom=@RefDatNom;
      
          open CurSell;
          fetch next from CurSell into @RefTekId,@Qty;
          WHILE (@@FETCH_STATUS=0)
          BEGIN
            if exists(select * from nv where DatNom=@RefDatNom and tekid=@RefTekid)
            begin
              print '[SaveNakl]: Обновляю NV @Reftekid='+cast(@Reftekid as varchar(10));
              update NV set Kol_B=isnull(Kol_B,0)-@Qty where DatNom=@RefDatNom and tekid=@RefTekid;
              if @@Error<>0 set @KolError=@KolError | 256
            end;
            else begin
              set @KolError=5000;
--              declare @ss varchar(20);
--              set @ss='RefDatnom='+cast(@refDatNom as varchar(11));
--              exec dbo.SendNotifyMail 'it@tdmorozko.ru;sargon5000@yandex.ru','Error on SaveNakl procedure',@ss, 0, ''
--              exec dbo.SendNotifyMail 'it_info@tdmorozko.ru','Error on SaveNakl procedure',@ss, 0, ''
            end;
            fetch next from CurSell into @RefTekId,@Qty;
          END;
          close CurSell;
	      deallocate CurSell;      
        END;    
    
        set @KolErrorSklad=0 
        -- Перемещение на склад возврата при необходимости:
        if (isnull(@Remark,'') <> '') and (@RefDatNom>0) and (@DocType=2)
        BEGIN
          set @SerialNom=0
          declare CurDiff cursor fast_forward for
          select z.tekid, z.sklad, -#f.kol as Qty
          from zakaz z inner join tdvi v on v.id=z.tekid 
                       inner join #f on z.tekid=#f.tekid   
          where z.Compname=@CompName and #f.kol<0 and v.SKLAD<>z.Sklad and z.RefDatnom=@RefDatnom
          open CurDiff;
          fetch next from CurDiff into @tekid, @Sklad, @Qty;
          WHILE (@@FETCH_STATUS=0)
          BEGIN
            exec ProcessSklad 'Скла', @TekId, null, @Sklad,
                 null, null, @Qty, @OP, @CompName,
                 0, 0, 0,
                 0, 0,
                 null, 
                 'Перемещение по возврату ()', 
                 @NewTekid,
                 @SerialNom,
                 @KolErrorSklad, null, null, null
            fetch next from CurDiff into @tekid, @Sklad, @Qty;
            if @KolErrorSklad > 0 set @KolError=4096;
          END;
          close CurDiff;
          deallocate CurDiff;  
        END;  
      -- Переход к следующей накладной в списке:
      set @QtyNakl = @QtyNakl + 1;
      fetch next from CurDeliv2 into @DelivGroup,@Extra,@StfDate,@StfNom, @DocNom, @DocDate, @Refdatnom, @DCK;
    END;
    
    close CurDeliv2;
    deallocate CurDeliv2;      
/*=====================================================КОНЕЦ ЦИКЛА СОЗДАНИЯ НАКЛАДНЫХ======================================================================*/
  
   --set @KolError=@KolError+@KolErrorSklad ;
    
   if @KolError=0 BEGIN
     set @SPsm=isnull((select sum(sp) from nc where datnom >= @dn0 and datnom <= @dn1 and sp>0 and b_id=@b_id),0); 
     if @SpSM>1500 
       update nc set Done=1 where datnom >= @dn0 and datnom <= @dn1 and b_id=@b_id;
   end;
         
   if @KolError  = 0 begin
     COMMIT -- WITH (DELAYED_DURABILITY = OFF)
     --select @Datnom;
     print '[SaveNakl]: Ошибки нет. Datnom ' + Cast(@datnom as varchar)
   end
   else begin
     print '[SaveNakl]: Ошибка процедуры SaveNakl. Datnom ' + Cast(@datnom as varchar)
     set @QtyNakl=0;  
     ROLLBACK; 
     insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid),@KolError        
     set @Datnom=0;
     set @QtyNakl=0;
     select 0;
   end;
  
   drop table #f;
 end; -- EXIST
  
  -- Очистка заказа:
  if (@Done=1 and @SPsm>0 and @SP>0 /*and @KolError + @KolErrorSklad=0*/) 
    update nc set Done=1 where datnom >= @dn0 and datnom <= @dn1 and b_id=@b_id
    delete from Zakaz where Compname=@CompName;     
  --select @Datnom

--  end try
--    begin catch
--      insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
--    end catch  
end;