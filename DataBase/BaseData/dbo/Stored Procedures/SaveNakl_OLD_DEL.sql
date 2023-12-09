

CREATE procedure dbo.SaveNakl_OLD_DEL
  @CompName varchar(30), @B_ID int, @Fam varchar(30),
  @Our_ID smallint=null, @Ag_ID smallint=null, @OP smallint,  @Srok int=null, 
  @Pko bit,  @Man_ID int, @tovchk bit=null,  @remark varchar(50),  @Actn bit, 
  @Ck bit, @Tomorrow bit, @RefDatNom int=0, @Frizer bit=0, @DatNom int=0 out, 
  @DayShift tinyint=0,  @RemarkOp varchar(50)='',  @OrderDate  datetime=null, 
  @OrderDocNumber varchar(35)='', @DCK int=0, @B_ID2 int=0, @NeedDover bit=0, 
  @Stip tinyint=0, @Tara bit=0, @flgRezerv bit=0, @KolError int=0 out
as 
 declare @DelivGroup INT,  @Box int, @TekId int, @RefTekId int, @NewTekId int, @Nds int
 declare @Extra decimal(7,2), @RetExtra decimal(7,2)
 declare @ND datetime, @SourDate datetime, @TM char(8), @Stfdate datetime, @DocDate datetime
 declare @StfNom varchar(17), @DocNom varchar(20), @SourNnak int
 declare @Qty decimal(10,3), @BoxQty decimal(9,2), @Weight decimal(9,2), @SP decimal(10,2), @SC decimal(10,2), @price decimal(14,4)
 declare @TaraAct char(2), @SerialNom int
 declare @Nnak int, @ContrTip smallint
 declare @KolErrorSklad int
 declare @Marsh int, @Sklad int
 declare @Sk50present bit, @EffWeight float, @Cost money
 declare @RemarkKassa varchar(50), @RemarkKassa2 varchar(20)
 declare @gpOur_ID int, @Ncod int
 declare @TekDay datetime, @DatnomOffset int, @NaklCount int, @NewNcId int
 declare @Done bit, @SPsm decimal(10,2), @worker bit, @gpName varchar(255), @DepID int 
 declare @dn0 int, @dn1 int, @master int, @flgExclude bit
begin
  set @KolError = 0 
  set @dn0 = dbo.InDatNom(0001, dbo.today())
  set @dn1 = dbo.InDatNom(9999, dbo.today())  

  begin try
  if @b_id2 is null set @b_id2=0;
  
  --Fam перечитать из Def
  
  set @ND=convert(char(10), getdate(),104);
  set @TM=convert(char(8), getdate(),108);
 
  set @SPsm=0;
  
  select @b_id=dc.pin, @ag_id=dc.ag_id, @Our_ID=dc.Our_id, @Srok=dc.srok, @ContrTip=dc.ContrTip, @gpOur_id=dc.gpOur_ID 
  from defcontract dc where dc.DCK=@dck;-- and dc.ContrTip=2;

  if @RefDatNom>0 
    select @stip=c.stip, @dck=c.dck, @RetExtra=c.extra from nc c where c.datnom=@RefDatNom;
  else 
    set @SPsm=isnull((select sum(sp) from nc where datnom >= @dn0 and datnom <= @dn1 and sp>0 and b_id=@b_id),0); 

  if (@stfdate=0) or (@StfDate='18991230') or (@StfDate<'19900101') set @stfdate=null;

  if @ContrTip=7 set @stip=4;
  if @stip=4 begin
    /*set @Ncod=(select max(tdvi.ncod) from tdvi inner join Zakaz Z on tdVi.id=z.tekid where z.CompName=@CompName);
    set @gpOur_ID=(select max(dc.dck) from defcontract DC inner join Def on dc.dck=Def.pin where Def.Ncod=@ncod );*/
    set @gpOur_ID=(select max(tdvi.DCK) from tdvi inner join Zakaz Z on tdVi.id=z.tekid where z.CompName=@CompName)
  end;

  set @Actn=(select Actn from NC_ShippingType where stip=@stip);
  set @DepID=(select DepID from agentlist where ag_id=@ag_id);

  select @gpName=d.gpName, @tovchk=d.tovchk, @worker=d.worker, @master=iif(d.master>0, d.master, d.pin) 
  from def d where d.pin=@b_id 
  
  if exists(select * from DefExclude where ExcludeType=1 and Pin=@Master) set @flgExclude=1;
  else set @flgExclude=0;
  
  if @stip>0 or @Our_ID=10 or @Our_ID=18 set @flgExclude=1;
  
  --select @gpName=d.gpName, @tovchk=d.tovchk, @worker=d.worker from def d where d.pin=@b_id 
  
  if @b_id=3434 or @b_id=7500 
       set @Fam=@gpName+' '+@Fam;
  else set @Fam=@gpName

  if (@Remarkop='') or (@Remarkop like '%}%') set @Remarkop=right(@remark, len(@remark)-CHARINDEX('}', @remark));
  
  if @RefDatNom is null or @Refdatnom=0 set @TaraAct='ТП'; else set @TaraAct='ТВ';
  if @Tomorrow=0 set @DayShift=0; else if @Tomorrow=1 and @DayShift=0 set @DayShift=1;
  
  if (@worker=1 or @stip=5) set @Marsh=99; else set @Marsh=0;
   
  -- Заказ содержится в табл. ZAKAZ, естественно. 
  
  
  if EXISTS(select * from Zakaz where CompName=@CompName) begin
--    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED
    begin transaction SaveNewNakls; 
      
      --здесь курсор по Zakaz.tekid=-1 - вставка в tdVI c weight=EffWeight и update tekid в Zakaz:
      declare CurBack cursor fast_forward
        for select reftekid,qty,price,Sklad,EffWeight,cost
        from Zakaz where CompName=@CompName and tekid=-1 order by reftekid;
      open CurBack;
      fetch next from CurBack into @reftekid, @qty, @price, @Sklad, @EffWeight, @Cost;
      WHILE (@@FETCH_STATUS=0)
      begin
        set @NewTekId=1+(select max(id) from tdVi);
        if EXISTS(select * from tdVi where id=@reftekid) 
          insert into tdvi(nd,id,startid, ncom, ncod, datepost, price, [start], startthis, hitag, 
             sklad, cost, minp, mpu, sert_id, rang, 
             morn, sell, isprav, remov, bad, dater, srokh, [country], rezerv, units, locked, ncountry, gtd, vitr, our_id,
             [weight], SaveDate, measid, OnlyMinP, AddrID, DCK, ProducerID, CountryID)
          select v.datepost as nd,@newTekId as id, v.startid, v.ncom, v.ncod, v.datepost, iif(n.flgWeight=1 and @Effweight<>0, round(@price*@Effweight,2), @price), v.start, 0, v.hitag,
             @sklad sklad, iif(n.flgWeight=1 and @Effweight<>0, round(@cost*@Effweight,2), @cost), v.minp, v.mpu, v.sert_id, v.rang, 
             0, 0, 0, 0, 0, v.dater, v.srokh, v.country, 0, v.units, 0, v.ncountry, v.gtd, 0, v.our_id,
             @Effweight, v.datepost as savedate, v.measid, v.OnlyMinP, v.AddrID, v.DCK, v.ProducerID, v.CountryID
          from tdvi v join nomen n on v.hitag=n.hitag where v.id=@reftekid;
        else
          insert into tdvi(nd,id,startid, ncom, ncod, datepost, price, [start], startthis, hitag, 
             sklad, cost, minp, mpu, sert_id, rang, 
             morn, sell, isprav, remov, bad, dater, srokh, [country], rezerv, units, locked, ncountry, gtd, vitr, our_id,
             [weight], SaveDate, measid, OnlyMinP, AddrID, DCK, ProducerID, CountryID)
          select v.datepost as nd,@newTekId as id, v.startid, v.ncom, v.ncod, v.datepost, iif(n.flgWeight=1 and @Effweight<>0, round(@price*@Effweight,2), @price), v.start, 0, v.hitag,
             @sklad sklad, iif(n.flgWeight=1 and @Effweight<>0, round(@cost*@Effweight,2), @cost), v.minp, v.mpu, v.sert_id, v.rang, 
             0, 0, 0, 0, 0, v.dater, v.srokh, v.country, 0, v.units, 0, v.ncountry, v.gtd, 0, v.our_id,
             @Effweight, v.datepost as savedate, v.measid, 0, null, v.DCK, v.ProducerID, v.CountryID
          from Visual v join nomen n on v.hitag=n.hitag where v.id=@reftekid;
        update Zakaz set tekid=@NewTekId where tekid=-1 and CompName=@CompName and RefTekId=@RefTekId;
        fetch next from CurBack into @reftekid, @qty, @price, @Sklad, @EffWeight, @Cost;
      end;
      close CurBack;
      deallocate CurBack;      
       
      -- Если в TDVI нет нужных строчек, придется выдернуть ее из VISUAL:	   
      insert into tdvi(nd,id,startid, ncom, ncod, datepost, price, [start], startthis, hitag, sklad, cost, minp, mpu, sert_id, rang, 
         morn, sell, isprav, remov, bad, dater, srokh, [country], rezerv, units, locked, ncountry, gtd, vitr, our_id,
         [weight], SaveDate, measid, OnlyMinP, AddrID, DCK, ProducerID, CountryID)
      select distinct v.datepost as nd,v.id,v.startid, v.ncom, v.ncod, v.datepost, v.price, v.start, 0, v.hitag,
         case when isnull(z.sklad,0)=0 then v.sklad else z.sklad end as sklad, v.cost, v.minp, v.mpu, v.sert_id, v.rang, 
         0, 0, 0, 0, 0, v.dater, v.srokh, v.country, 0, v.units, 0, v.ncountry, v.gtd, 0, v.our_id,
         v.weight, v.datepost as savedate, v.measid, 0, null, v.DCK, v.ProducerID, v.CountryID
      from visual v inner join Zakaz z on v.id=z.tekid 
      where z.CompName=@CompName and z.tekid not in (select id from tdvi);
    
         
         
         
      --insert into Log_temp(mess) VALUES(convert(char(10), getdate(),104));	
      -- Внутри табл. Zakaz могут быть данные сразу нескольких накладных, различаются по полю DelivGroup:
      if @RefDatNom > 0 update Zakaz set MainExtra=@RetExtra where CompName=@CompName;
      
      declare CurDeliv cursor fast_forward  
      for select distinct DelivGroup,MainExtra,StfDate, Stfnom, DocNom, DocDate from Zakaz where Compname=@CompName order by DelivGroup;
      open CurDeliv; 
      fetch next from CurDeliv into @DelivGroup,@Extra,@StfDate,@StfNom, @DocNom, @DocDate;
      WHILE (@@FETCH_STATUS=0)  BEGIN
        --insert into Log_temp(mess,DatNom) VALUES('DelivGroup=',@DelivGroup);	
        -- Проход по списку накладных:   
                   
        select  @BoxQty=sum(z.Qty/VI.minp/vi.mpu),
                @Weight=sum(z.Qty*z.effWeight),
                @SP=(1.0+isnull(@Extra,0)/100.0)*sum(z.Price*z.Qty),          
                @SC=sum(z.Cost*z.Qty)
        from Zakaz z inner join tdVi vi on vi.id=z.tekid 
        where z.CompName=@CompName and z.DelivGroup=@DelivGroup 
              and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom;        
        
/*        set @BoxQty=(SELECT(sum(z.Qty/VI.minp/vi.mpu)) BoxQty 
            from Zakaz z inner join tdVi vi on vi.id=z.tekid 
            where z.CompName=@CompName and z.DelivGroup=@DelivGroup 
            and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom);
        set @Weight=(SELECT(sum(Qty*effWeight)) from Zakaz 
             where CompName=@CompName and DelivGroup=@DelivGroup 
             and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom);
        set @SP=(1.0+isnull(@Extra,0)/100.0)*(select sum(Price*Qty) from Zakaz 
            where CompName=@CompName and DelivGroup=@DelivGroup
            and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom);
        set @SC=(select sum(z.Cost*z.Qty) from Zakaz z 
           where z.CompName=@CompName and z.DelivGroup=@DelivGroup
            and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom);
        */    
        
  		/*if exists(select * from Zakaz where sklad=50 and CompName=@CompName and DelivGroup=@DelivGroup 
             and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom) set @sk50present=1; 
		else set @sk50present=0;  */
            
		set @datnom=round(10000+90000*RAND(),0)+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));
        
        -- set @datnom=isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND))+1
        
        set @sk50present=0;
        
        -- Может, это холодильник или ларь?
        if exists(select z.hitag from Zakaz Z inner join Nomen N on N.hitag=Z.hitag 
                  where N.Ngrp in (19,21) and z.CompName=@CompName and z.DelivGroup=@DelivGroup 
                  and isnull(mainextra,0)=isnull(@extra,0) and z.stfnom=@stfnom)
        set @Frizer=1; else set @Frizer=0;

		-- Какое смещение нумерации сегодня?  
        select @TekDay=cast(val as datetime),  @DatnomOffset=cast(Comment as int) from Config where Param='DatnomOffset'
        if cast(@TekDay as datetime)<>dbo.today() 
        begin
            set @NaklCount=(select count(*) from nc where ND=dbo.today())
--		    set @NaklCount=(select count(*) from nc where datnom>=@dn0 and datnom <=@dn1)
            if @Naklcount=0
              set @DatnomOffset = dbo.fnDatNom(dbo.today(),1) - (select max(ncid) from nc);
            else 
              set @DatnomOffset = (select top 1 datnom-ncid from nc order by datnom desc);
            update Config set val=convert(varchar, dbo.today(), 104), Comment=@DatnomOffset where Param='DatnomOffset';
        end

        --Изменение срока консигнации
        if (@DelivGroup=1 and @Srok>7) set @Srok=7;
        
        -- Заголовок накладной:
        
        insert into NC (ND,datnom,B_ID,Fam,Tm,OP,SP,SC,
                       Extra,Srok,OurID,Pko,Man_ID, 
                       BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
    	               Remark,Printed,Marsh,BoxQty,WEIGHT,Actn,CK,Tara,
                       RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift,
                       Comp, Sk50present, DCK, B_ID2, NeedDover, DocNom, DocDate, STip, gpOur_ID)
         values (@ND,@datnom,@B_ID,@Fam,convert(char(8), getdate(),108),@OP,@SP,@SC,
	             @Extra,@Srok,@Our_ID,@Pko,@Man_ID, 
	             0,@TovChk,@Frizer,@ag_id,@stfnom,@stfdate,@tomorrow,@Tara,
	             @Remark,0,@Marsh,@BoxQty,@WEIGHT,@Actn,@CK,0,
                 @RefDatNom,0,0, 0, 0.0, @remarkop,
                 @DayShift, @CompName, @Sk50present, @DCK, @B_ID2, @NeedDover, @DocNom, @DocDate, @Stip, @gpOur_ID);
         if @@Error<>0 set @KolError=@KolError + 1     
         set @NewNCID = scope_identity();

         update NC set Datnom=@NewNCID+@DatnomOffset where NCID=@NewNCID;
         if @@Error<>0 set @KolError=@KolError + 1     

         set @Datnom=@NewNCID+@DatnomOffset;
     
         insert into NVzakaz (datnom,hitag,zakaz,done, price, cost, SkladNo)
         select @datnom, z.hitag, sum(z.qty), 0, max(z.price), max(z.cost), vi.sklad         
            from Zakaz z 
              inner join tdVI vi on vi.id=z.tekid
              inner join SkladList SL on SL.SkladNo=vi.Sklad
              inner join nomen n on z.hitag=n.hitag
            where
              z.qty>0 and 
              z.CompName=@CompName and z.DelivGroup=@DelivGroup
              and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom and docnom=@docnom
              and SL.UpWeight=1 --and n.flgWeight=1
              and isnull(z.ForcedIntegerSell,0)=0
         group by z.hitag, vi.sklad     
         
         insert into NV (hitag,datnom,tekid,price,cost,Kol,sklad,kol_b,baseprice)
                select z.hitag, @datnom, z.tekid,
                       iif(n.flgWeight=1 and vi.weight<>0, round(z.price*vi.weight,2), z.price),
                       iif(n.flgWeight=1 and vi.weight<>0, round(z.cost*vi.weight,2), z.cost),
                       z.qty, vi.sklad,0,vi.price as BasePrice
                from 
                  Zakaz z 
                  inner join tdVI vi on vi.id=z.tekid
                  inner join SkladList SL on SL.SkladNo=vi.Sklad
                  inner join nomen n on z.hitag=n.hitag
                where z.CompName=@CompName and z.DelivGroup=@DelivGroup
                and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom and docnom=@docnom
           		  and (SL.UpWeight=0 or z.qty<0 or z.ForcedIntegerSell=1)
                
         if @@Error<>0 set @KolError=@KolError + 1       

         -- Что именно удалось воткнуть в NV?
         create table #F(tekid int, Kol int, Cost decimal(13,5), Price decimal(12,2));
         
         insert into #F(tekid, Kol,Cost,Price) select tekid, kol,Cost,Price 
         from nv where datnom=@datnom;

          -- И на всякий случай пересчитаем суммы по накладной:
            select @SP=round(sum(kol*price*(1.0+@Extra/100.0)),2), @SC=sum(kol*cost) from #F;
		  /*          select @SP=round(sum(kol*price*(1.0+@Extra/100.0)),2), @SC=sum(kol*cost) from NV where Datnom=@Datnom;*/
          
          set @SP=isnull(@sp,0);
          set @SPsm=isnull(@spsm,0);
          set @SC=isnull(@sc,0);
          
          set @Done=iif(((@SPsm+@SP>1500) or @SP<0 or @DepID=3 or @DepID=43 or @worker=1 or @flgExclude=1),1,0);
          update nc set SP=@SP, SC=@SC, Done=@Done where datnom=@datnom;
                
         insert into NV_ADD (datnom,tekid,refdatnom,reftekid,WEIGHT,kol, price, cost)
                select @datnom, z.tekid, @RefDatNom, z.RefTekId,z.EffWeight, z.qty, z.price, z.cost
                from Zakaz z 
                where z.CompName=@CompName and z.DelivGroup=@DelivGroup
                and isnull(z.mainextra,0)=isnull(@extra,0) and z.stfnom=@stfnom and z.docnom=@docnom and z.tekid<>z.RefTekId
                and @RefDatNom<>0;      
                
                
         if @@Error<>0 set @KolError=@KolError + 1
         
         -- Информация о заказе Exite, если есть:
         if @OrderDocNumber<>'' 
           insert into NC_ExiteInfo(DatNom, OrderDate, OrderDocNumber)
           values(@Datnom, @OrderDate, @OrderDocNumber);
         
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
                 and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom
                 group by t.taratip, t.taraprice;
          else -- возврат тары:
            insert into TaraDet(nd,tm,b_id,nnak,sellDate,datNom,act,taraTip,kol,price,op,nakTip,tarId,remark,RealDatNom)
                 select @ND, @TM, @B_ID, dbo.InNnak(@RefDatnom), dbo.DatNomInDate(@RefDatNom), @RefDatNom, @TaraAct, 
                 t.taratip, sum(z.Qty) as Qty, t.taraprice as Price, @Op as op,
                 0, 0, null as remark, @DatNom
                 from Zakaz z inner join Taracode2 T on T.FishTag=z.hitag
                 where z.CompName=@CompName and z.DelivGroup=@DelivGroup
                 and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom
                 group by t.taratip, t.taraprice;
                 
          if @@Error<>0 set @KolError=@KolError + 1
          
           -- Если накладная возвратная и не акция, то надо закрыть ее и исходную тоже:
          if (@RefDatNom>0) and (@Actn=0)
          begin
            set @SourDate=dbo.DatNomInDate(@RefDatNom); -- дата исходной накладной
            set @SourNnak=dbo.InNnak(@RefDatNom); -- номер исходной накладной
            
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
			      @RemarkKassa+'См. накладную №'+cast(dbo.InNnak(@datnom) as varchar(4))+' от '+convert(char(8), dbo.DatNomInDate(@datnom), 4),
                  0,1,0, @Op,0,@Our_ID,@ND,@Actn,0, null,null,null,'ВО', 0, @RefDatNom, null, @DCK);       
                  
            if @@Error<>0 set @KolError=@KolError + 1
        
            insert into Kassa1(Nd,TM, Oper,SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
                   remark, RashFlag,LostFlag,LastFlag,  Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
                   Thr,ThrFam,DocNom,Act, ForPrint, SourDatNom, StNom, DCK)
            values(@ND, @TM, -2, @ND,dbo.InNnak(@DatNom),@SP, @Fam, 0, @B_ID,0,0,
                  @RemarkKassa2+cast(dbo.InNnak(@RefDatNom) as varchar(4))+' от '+convert(char(8), dbo.DatNomInDate(@refDatNom), 4),
                  0,1,0, @Op,0,@Our_ID,@ND,@Actn,0, null,null,null,'ВО', 0, @DatNom, null, @DCK);       
                  
            if @@Error<>0 set @KolError=@KolError + 1
          end;
      
      
        -- Переход к следующей накладной в списке:
      fetch next from CurDeliv into @DelivGroup,@Extra,@StfDate,@StfNom, @DocNom, @DocDate;
    end;
    close CurDeliv;
    deallocate CurDeliv;      
    
    -- Коррекция склада, а именно поля Sell и, возможно, поля Rezerv:
   -- declare CurSell cursor fast_forward for select Tekid, Qty from Zakaz where Compname=@CompName;
    declare CurSell cursor fast_forward for select Tekid, kol as Qty from NV where datnom=@datnom;
    open CurSell;
    fetch next from CurSell into @TekId,@Qty;
    
    WHILE (@@FETCH_STATUS=0)  BEGIN
      if @flgRezerv=1 
        update tdVi set 
          Sell=isnull(sell,0)+@Qty,
          Rezerv=case when rezerv-@Qty<0 then 0 else rezerv-@Qty end
        where id=@Tekid;        
      else update tdVi set Sell=isnull(sell,0)+@Qty where id=@Tekid;
    
      if @@Error<>0 set @KolError=@KolError + 1
    
      fetch next from CurSell into @TekId,@Qty;
    end;
    
    close CurSell;
    deallocate CurSell;      
    
    -- Коррекция исходной накладной, если это возврат:
    if @RefDatNom>0 begin
	    declare CurSell cursor fast_forward for select Zakaz.RefTekid, #f.Kol 
	    from Zakaz join #f on Zakaz.tekid=#f.tekid -- ДОБАВЛЕНО 28.05.2015
        where Compname=@CompName and #f.Kol<>0 and RefTekId>0;
        
	    open CurSell;
	    fetch next from CurSell into @RefTekId,@Qty;
	    WHILE (@@FETCH_STATUS=0)  BEGIN
        if exists(select * from nv where DatNom=@RefDatNom and tekid=@RefTekid) begin
  	      update NV set Kol_B=isnull(Kol_B,0)-@Qty where DatNom=@RefDatNom and tekid=@RefTekid;
  	      if @@Error<>0 set @KolError=@KolError + 1
        end;
        else begin
          set @KolError=5000;
          declare @ss varchar(20);
          set @ss='RefDatnom='+cast(@refDatNom as varchar(10));
          exec dbo.SendNotifyMail 'it@tdmorozko.ru;sargon5000@yandex.ru','Error on SaveNakl procedure',@ss, 0, ''
        end;
  	    fetch next from CurSell into @RefTekId,@Qty;
	    end;
	    close CurSell;
	    deallocate CurSell;      
    end;    
    
   set @KolErrorSklad=0 
    -- Перемещение на склад возврата при необходимости:
   if (isnull(@Remark,'') <> '') and (@RefDatNom>0)
   begin
     set @SerialNom=0
     declare CurDiff cursor fast_forward for
      select z.tekid, z.sklad, -#f.kol as Qty
      from zakaz z inner join tdvi v on v.id=z.tekid 
                   inner join #f on z.tekid=#f.tekid   
      where z.Compname=@CompName and #f.kol<0 and v.SKLAD<>z.Sklad
     open CurDiff;
     fetch next from CurDiff into @tekid, @Sklad, @Qty;
     WHILE (@@FETCH_STATUS=0)
     BEGIN
     
     --  exec SaveRestMove @tekid,@Qty,0,@Op,@Sklad,'Перемещение по возврату',
     --    1, @CompName, @NewTekid;
         
       exec ProcessSklad 'Скла', @TekId, null, @Sklad,
         null, null, @Qty, @OP, @CompName,
         0, 0, 0,
         0, 0,
         null, 
         'Перемещение по возврату ()', @NewTekid,
         @SerialNom,
         @KolErrorSklad, null, null,
		 null
      -- Аргументы ProcessSklad: 
      --  @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint, 
      --  @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, @Op int, @Comp varchar(30),
      --  @irId int, @ServiceFlag bit=0, @DivFlag bit=0, 
      --  @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran"
      --  @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
      --  @remark varchar(40), @Newid int out, 
      --  @SerialNom int=0 out,  -- Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
      --  @kolError int out, @Dck INT=0, @Junk int=0, 
      --  @NewWEIGHT decimal(12, 3)=0 -- это входной параметр для операции "Tran"
         
         
       fetch next from CurDiff into @tekid, @Sklad, @Qty;
     end;
     close CurDiff;
     deallocate CurDiff;  
   
   end;   
   
   set @KolError=@KolError+@KolErrorSklad ;
   IF @KolError  = 0 begin
     COMMIT 
     select @Datnom;
   end
   ELSE begin
     ROLLBACK; 
     set @Datnom=0
     select 0;
   end;
  end; -- TRY
  
  -- Очистка заказа:
  if (@Done=1 and @SPsm>0 and @SP>0 /*and @KolError + @KolErrorSklad=0*/) 
    update nc set Done=1 where datnom >= @dn0 and datnom <= @dn1 and b_id=@b_id
    delete from Zakaz where Compname=@CompName;     
  select @Datnom

  end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
  end catch  
end;