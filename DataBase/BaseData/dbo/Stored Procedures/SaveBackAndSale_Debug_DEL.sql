

CREATE procedure dbo.SaveBackAndSale_Debug_DEL
  @OrigDatNom int, @OldB_ID int, @OldFam varchar(35),
  @NewB_ID int, @NewFam varchar(35),
  @OP smallint, @CompName varchar(30), @Srok int,
  @DayShift tinyint, @Extra decimal(6,2), @Stfnom varchar(17), @stfdate datetime,
  @BoxQty decimal(9,2),  @weight decimal(9,2), @NewSP money, @NewSC money,
  @BackDatnom int=0 out, @NewDatNom int=0 out, @Actn bit=0,
  @OrigRemark varchar(50)='',
  @OrigRemarkOp varchar(50)='',
  @NcDCK int=0
as 
declare @ND datetime, @Stip int, @TM char(8), @oldB_id2 INT,
  @Price decimal(12,2), @BasePrice decimal(12,2), @Cost money, @NewKol decimal(12,3),
  @ag_ID int, @TekId int, @Hitag int, @Our_ID int, @gpOur_ID int, @Sklad int,
  @Old_our_id int,  @old_tovchk bit, @old_ag_id int, @KolError int,
  @tomorrow bit, @TovChk bit, @tip tinyint, @Meas tinyint, @DelivCancel bit,
  @UpWeight bit, @flgWeight bit , @Done bit, @Master int, @DepID int, @Worker bit, 
  @AddSP money, @DocNom varchar(20);

begin
  begin try
  if @NcDCK=0 set @NcDCK=(select isnull(max(DC.DCK),0) from DefContract DC 
  				          where DC.ContrTip=2 and DC.pin=@OldB_ID and DC.ContrMain=1);
  set @ND=dbo.today();
  set @TM=convert(char(8), getdate(),108);
  
  select @OUR_ID=Our_Id,
         @ag_ID=Ag_ID 
  from DefContract where DCK=@NcDCK;
  
  set @TovChk=(select TovChk from Def where Tip=1 and pin=@NewB_ID);

  set @Old_OUR_ID=@OUR_ID; -- (select Our_Id from Def where Tip=1 and pin=@OldB_ID);
  set @Old_TovChk=@TovChk; -- (select TovChk from Def where Tip=1 and pin=@OldB_ID);
  set @Old_ag_ID=@Ag_ID;   -- (select brAg_ID from Def where Tip=1 and pin=@OldB_ID);

  if @dayshift=0 set @tomorrow=0; else set @tomorrow=1;
  if @stfdate<'20100101' set @StfDate=null;

  Set @KolError=0;
  select @Stip=stip, @oldB_id2=b_id2, @Actn=Actn, @Done=Done, @DocNom=DocNom, @gpOur_ID=gpOur_ID
  from NC where Datnom=@OrigDatNom;
  
  
  
  -- ***********************************************************************
  -- **   Вычисление флага DONE для новой накладной при необходимости     **
  -- ***********************************************************************
  if @Done=0 and @Actn=1 set @Done=1;
  if @Done=0 begin
    select @Master=iif(master>0, master, pin), @Worker=Worker from Def where Pin=@NewB_ID
    if @Master>0 and exists(select * from DefExclude where ExcludeType=1 and Pin=@Master) 
      set @Done=1;
    else begin
      set @DepID=(select depid from Agentlist where ag_id=@ag_id);
      set @AddSP=ISNULL((select sum(zakaz*price) from nvzakaz where datnom=@OrigDatnom and Done=0),0);
      if @NewSP+@AddSP>=1500 or @NewSP<0 or @DepID=3 or @DepID=43 or @worker=1 set @Done=1;
    end;
  end;  
  
  
  
 SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
 begin transaction
     -- Заголовок возвратной накладной:
     set @backdatnom=1+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));
     
     insert into NC (ND,datnom,B_ID,B_ID2,Fam,Tm,OP,SP,SC,
       Extra,Srok,OurID,Pko,Man_ID, 
       BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
       Remark,Printed,Marsh,BoxQty,WEIGHT,Actn,CK,Tara,
       RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift, Comp, DCK, Stip,gpOur_iD)
     values (@ND,@backdatnom,@OldB_ID, @OldB_ID2,  @OldFam,@TM,@OP,-@NewSP,-@NewSC,
       @Extra,@Srok,@Our_ID, 0, 0, 
       0,@TovChk, 0, @ag_id, @stfnom,@stfdate,0,0,
       '',0,0,-@BoxQty,-@WEIGHT, @actn,0,0,       
       @OrigDatNom,0,0, 1, 0.0, '', 0, @CompName, @NcDCK, @Stip,@gpOur_iD);
     if @@Error<>0 set @KolError=@KolError + 1;
  
     if (@KolError=0) begin
       -- Заголовок новой расходной накладной:
       set @newdatnom=1+@backdatnom;
  
       insert into NC (ND,datnom,B_ID,b_id2,Fam,Tm,OP,SP,SC,
         Extra,Srok,OurID,Pko,Man_ID, 
         BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
         Remark,Printed,Marsh,BoxQty,WEIGHT,Actn,CK,Tara,
         RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift, Comp, DCK, Stip, gpOur_iD,DocNom)
       values (@ND,@newdatnom,@NewB_ID, @oldB_ID2,@NewFam,@TM,@OP,@NewSP,@NewSC,
         @Extra,@Srok,@Our_ID, 0, 0, 
         0,@TovChk, 0, @ag_id, @stfnom,@stfdate,@tomorrow,0,
         @OrigRemark,0,0,@BoxQty,@WEIGHT, @Actn,0,0,       
         0,0,0, @Done, 0.0, @OrigRemarkOp, @DayShift, @CompName, @NcDCK, @Stip, @gpOur_iD,@DocNom);
     end;        
     if @@Error<>0 set @KolError=@KolError + 1;
     
    
    if @KolError=0 begin
      update sertiflog set DatNom=@NewDatnom where Datnom=@OrigDatnom;
      
      declare CurBack cursor fast_forward  
       for select nv.Tekid,nv.Hitag,nv.Price,nv.Cost,nv.Kol-nv.Kol_B as NewKol,
       nv.Sklad,nv.BasePrice,nv.tip,nv.Meas,nv.DelivCancel, s.UpWeight, nm.flgWeight
       from NV inner join skladlist s on nv.Sklad=s.skladno
               inner join nomen nm on nv.hitag=nm.hitag
       where Datnom=@OrigDatnom  and nv.kol>nv.kol_b;
      open CurBack; 
      fetch next from CurBack into @Tekid, @Hitag, @Price, @Cost, @NewKol,
        @Sklad, @BasePrice, @Tip, @Meas, @DelivCancel, @UpWeight, @flgWeight;
      WHILE (@@FETCH_STATUS=0) BEGIN
     
        insert into NV(DatNom, tekid, hitag, price, cost, kol, kol_b, sklad, baseprice, tip, Meas,DelivCancel)
        values(@BackDatNom, @tekid, @hitag, @price, @cost, -@newkol, 0, @sklad, @baseprice, @tip, @Meas,@DelivCancel)

        if not exists(select * from tdvi where id=@tekid)
          insert into tdvi(Nd,id,startid,ncom,ncod,datepost,price,start,startthis,
            hitag,sklad,cost,minp,mpu,sert_id,rang,morn,sell,isprav,remov,Bad,
            dater,srokh,country,rezerv,units,locked,Ncountry,Gtd,Vitr,Our_ID,
            WEIGHT,SaveDate,MeasID,OnlyMinP, DCK)
  	      select @Nd as ND,id,startid,ncom,ncod,datepost,price,start,0 as StartThis,
            hitag,sklad,cost,minp,mpu,sert_id,rang,0 as morn,0 as sell,0 as isprav,0 as remov,0 as Bad,
            dater,srokh,country,0 as rezerv,units,0 as locked,Ncountry,Gtd,0 as Vitr,Our_ID,
            WEIGHT,@ND as SaveDate,MeasID,0 as OnlyMinP, DCK
          from Visual where id=@tekid;

        -- if (@UpWeight=0 ) - проверка заблокирована 21.06.2016
          insert into NV(DatNom, tekid, hitag, price, cost, kol, kol_b, sklad, baseprice, tip, Meas,DelivCancel)
          values(@NewDatNom, @tekid, @hitag, @price, @cost, @newkol, 0, @sklad, @baseprice, @tip, @Meas,@DelivCancel)
        -- else
        -- begin
        --   update tdvi set sell=sell-@newkol where id=@tekid
        -- end
        

      fetch next from CurBack into @Tekid, @Hitag, @Price, @Cost, @NewKol,
        @Sklad, @BasePrice, @Tip, @Meas, @DelivCancel, @UpWeight, @flgWeight;
      end;
      close CurBack;
      deallocate CurBack;  

             
      insert into NVzakaz (datnom,hitag,zakaz,done, price, cost, comp,tm,tmEnd,curWeight,tekWeight,dt,dtEnd,skladNo, id, remark,Op,AuthorOP,Spk)
      select @NewDatnom, hitag,zakaz,done, price, cost, comp,tm,tmEnd,curWeight,tekWeight,dt,dtEnd,skladNo, id, remark,Op,AuthorOP,Spk
      from nvZakaz v 
      where v.datnom=@OrigDatNom 

      update nvzakaz set NewDatnom=@NewDatnom where datnom=@origdatnom;
      
    end;

    
    update NV set Kol_B=Kol where Datnom=@OrigDatNom and Kol>Kol_B;
   


    -- Вот здесь кое-что новое, добавлено 23.12.2010:
    -- Записываю выплаты в исходную и возвратную накладные, если это не акция:
    if (@KolError=0) and (@Actn=0) begin
  	  insert into Kassa1(Nd,TM,
        Oper,Act,SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
        remark, RashFlag,LostFlag,LastFlag,
        Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
        ForPrint, SourDatNom, DCK)
	  values(
	    dbo.today(), convert(char(8), getdate(),108),
	    -2,'ВО', dbo.DatNomInDate(@OrigDatNom), dbo.innnak(@OrigDatNom),@NewSP, @OldFam, 0, @OldB_ID,0,0,
        'Возврат. См. накладную '+cast(dbo.inNnak(@backdatnom) as varchar(4))+' от '+convert(char(8), getdate(),4),
        0,1,0,
        @Op,0,@Our_ID,convert(char(10), getdate(),104),0,0,
        0, @OrigDatNom, @NcDCK);
      if @@Error<>0 set @KolError=@KolError + 1;
    end;

    if (@KolError=0) and (@Actn=0) begin
	  insert into Kassa1(Nd,TM,
        Oper,Act,SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
        remark, RashFlag,LostFlag,LastFlag,
        Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
        ForPrint, SourDatNom, DCK)
	  values(
	    convert(char(10), getdate(),104), convert(char(8), getdate(),108),
	    -2,'ВО', dbo.DatNomInDate(@backdatnom), dbo.innnak(@backdatnom),-@NewSP, @OldFam, 0, @OldB_ID,0,0,
        'Возврат накладной #'+cast(dbo.inNnak(@OrigDatNom) as varchar(4))+' от '+convert(char(8), dbo.DatNomInDate(@OrigDatNom),4),
        0,1,0,
        @Op,0,@Our_ID,convert(char(10), getdate(),104),0,0,
        0, @backdatnom, @NcDCK);
      if @@Error<>0 set @KolError=@KolError + 1;
    end;
  
 	declare @dn int
  set @dn=dbo.InDatNom(0,@nd)
 
  update nc set done=iif(((select sum(sp) from nc where datnom>=@dn and b_id=@NewB_ID and sp>0)>=1500)or(sp<0),1,0)
  where b_id=@NewB_ID
  			and datnom>=@dn

  
  IF @KolError = 0 COMMIT ELSE ROLLBACK; 
  select @newDatnom;
  
  end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid)
  end catch   
end;