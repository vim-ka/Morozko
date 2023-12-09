CREATE procedure dbo.SaveBackMaybeSale @OrigDatNom int, @OP int, @flgSale bit=0,
  @BackDatnom int=0 out, @NewDatNom int=0 out
as 
declare -- параметры накладной в целом:
  @KolError int, @dayshift int, @ND datetime, @TM char(8), @CompName varchar(30), 
  @B_ID int, @B_ID2 int, @Master int, @Fam varchar(35), @Srok int, @Extra decimal(6,2), 
  @Stfnom varchar(17), @stfdate datetime, @DocNom varchar(20),
  @Actn bit, @Stip smallint, @OrigRemark varchar(255),  @OrigRemarkOp varchar(255), @NcDCK int,
  @oldB_id2 INT,@ag_ID int, @OurID int, @gpOur_ID int, @TovChk bit, 
  @BoxQty decimal(9,2),  @NewSP decimal(12,2), @NewSC decimal(12,2),
  @DepID int, @Worker bit, 
  @tomorrow bit, @AddSP decimal(12,2), @StartDatNom int;
declare -- детализация накладной:
  @weight decimal(9,2),
  @Price decimal(15,5), @BasePrice decimal(15,5), @Cost decimal(15,5), @NewKol decimal(12,3),
  @TekId int, @Hitag int,   @Sklad int,
  @tip tinyint, @Meas tinyint, @DelivCancel bit,
  @UpWeight bit, @flgWeight bit , @Done bit
  
begin
  set @KolError=0;
  set @NewDatNom=0;
  set @ND=dbo.today();
  set @TM=convert(char(8), getdate(),108);
  set @CompName=HOST_NAME();

  select @B_ID=B_ID, @B_id2=B_ID2, @Fam=Fam, @Srok=Srok, @Extra=Extra, 
    @Stfnom=Stfnom, @stfdate=stfdate, @DocNom=DocNom,
    @Actn=Actn,@Stip=Stip, @OrigRemark=Remark, @OrigRemarkOp=RemarkOp, @NcDCK=DCK,  
    -- нет, это возьмем из договоров: @ag_ID=AG_ID, @OurID=OurID, 
    @gpOur_ID=gpOur_ID, @TovChk=Tovchk, @StartDatNom=StartDatNom
  from NC where Datnom=@OrigDatnom;
  if @stfdate<'20100101' set @StfDate=null;

  select @Master=iif(master>0, master, pin), @Worker=Worker from Def where Pin=@B_ID;

  if @NcDCK=0 set @NcDCK=(select isnull(max(DC.DCK),0) from DefContract DC 
  				          where DC.ContrTip=2 and DC.pin=@B_ID and DC.ContrMain=1);

  select @OURID=Our_Id, @ag_ID=Ag_ID from DefContract where DCK=@NcDCK;
  set @TovChk=(select TovChk from Def where Tip=1 and pin=@B_ID);

  -- Вроде это не надо? Возвращаем всегда в сегодняшний день, и продаем тут же:
  -- if @dayshift=0 set @tomorrow=0; else set @tomorrow=1;
  set @dayshift=0;


  -- ***********************************************************************
  -- **   Вычисление флага DONE для новой накладной при необходимости     **
  -- ***********************************************************************
  if @Done=0 and @Actn=1 set @Done=1;
  if @Done=0 begin
    if @Master>0 and exists(select * from DefExclude where ExcludeType=1 and Pin=@Master) 
      set @Done=1;
    else begin
      set @DepID=(select depid from Agentlist where ag_id=@ag_id);
      set @AddSP=ISNULL((select sum(zakaz*price) from nvzakaz where datnom=@OrigDatnom and Done=0),0);
      if @NewSP+@AddSP>=1500 or @NewSP<0 or @DepID=3 or @DepID=26 or @DepID=43 or @worker=1 set @Done=1;
    end;
  end;  
  
  begin try
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
  begin transaction
    -- Заголовок возвратной накладной. Суммы рассчитаем потом:
    set @backdatnom=1+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));
PRINT('@BACKDATNOM = '+cast(@BackDatnom as varchar));
    insert into NC (ND,datnom,B_ID,B_ID2,Fam,Tm,OP,SP,SC,
       Extra,Srok,OurID,Pko,Man_ID, 
       BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
       Remark,Printed,Marsh,BoxQty,WEIGHT,Actn,CK,Tara,
       RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift, Comp, DCK, Stip,gpOur_iD,StartDatNom)
    values (@ND,@backdatnom,@B_ID, @B_ID2,  @Fam,@TM,@OP,-1,-1, -- это вместо сумм
       @Extra,@Srok,@OurID, 0, 0, 
       0,@TovChk, 0, @ag_id, @stfnom,@stfdate,0,0,
       @OrigRemark,0,0,-1,-1, @actn,0,0,       
       @OrigDatNom,0,0, 1, 0.0, @OrigRemarkOp, 0, @CompName, @NcDCK, @Stip,@gpOur_iD,@StartDatNom);
    if @@Error<>0 set @KolError=@KolError | 1;
PRINT('Вставка в NC выполнена, @KolError='+cast(@KolError as varchar));
  
    -- Заголовок новой расходной накладной, если она нужна:
    if @KolError=0 and @flgSale=1 begin
       set @newdatnom=1+@backdatnom;
       insert into NC (ND,datnom,B_ID,b_id2,Fam,Tm,OP,SP,SC,
         Extra,Srok,OurID,Pko,Man_ID, 
         BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
         Remark,Printed,Marsh,BoxQty,WEIGHT,Actn,CK,Tara,
         RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift, Comp, DCK, Stip, gpOur_iD,DocNom,StartDatNom)
       values (@ND,@newdatnom,@B_ID, @B_ID2,@Fam,@TM,@OP,1.0,1.0, -- суммы пока фиктивные
         @Extra,@Srok,@OurID, 0, 0, 
         0,@TovChk, 0, @ag_id, @stfnom,@stfdate,@tomorrow,0,
         @OrigRemark,0,0,@BoxQty,@WEIGHT, @Actn,0,0,       
         0,0,0, @Done, 0.0, @OrigRemarkOp, @DayShift, @CompName, @NcDCK, @Stip, @gpOur_iD,@DocNom,@StartDatNom);
       if @@Error<>0 set @KolError=@KolError + 1;
    end;        
     
    
    if @KolError=0 and @flgSale=1 update sertiflog set DatNom=@NewDatnom where Datnom=@OrigDatnom;
      
PRINT('Объявление курсора CurBack');
    declare CurBack cursor fast_forward for 
      select nv.Tekid,nv.Hitag,nv.Price,nv.Cost,nv.Kol-nv.Kol_B as NewKol,
       nv.Sklad,nv.BasePrice,nv.tip,nv.Meas,nv.DelivCancel, s.UpWeight, nm.flgWeight
      from 
        NV 
        inner join skladlist s on nv.Sklad=s.skladno
        inner join nomen nm on nv.hitag=nm.hitag
      where nv.Datnom=@OrigDatnom  and nv.kol>nv.kol_b;
PRINT('Открытие курсора CurBack');
    open CurBack; 
PRINT('Открыт курсор CurBack');
    fetch next from CurBack into @Tekid, @Hitag, @Price, @Cost, @NewKol,
        @Sklad, @BasePrice, @Tip, @Meas, @DelivCancel, @UpWeight, @flgWeight;
PRINT('Данные получены');
    WHILE (@@FETCH_STATUS=0) BEGIN
        insert into NV(DatNom, tekid, hitag, price, cost, kol, kol_b, sklad, baseprice, tip, Meas,DelivCancel)
        values(@BackDatNom, @tekid, @hitag, @price, @cost, -@newkol, 0, @sklad, @baseprice, @tip, @Meas,@DelivCancel)
PRINT('Вставка в NV сделана');

        if not exists(select * from tdvi where id=@tekid) begin
          -- новый вариант, 10.10.16:
PRINT('Потребуется вставка в TDVI');
          SET IDENTITY_INSERT tdvi ON; -- отключаю автоинкремент.
          insert into tdvi(Nd,id,startid,ncom,ncod,datepost,price,start,startthis,
            hitag,sklad,cost,minp,mpu,sert_id,rang,morn,sell,isprav,remov,Bad,
            dater,srokh,country,rezerv,units,locked,Ncountry,Gtd,Vitr,Our_ID,
            WEIGHT,SaveDate,MeasID,OnlyMinP, DCK, ProducerID, CountryID, pin)
  	      select @Nd as ND,id,startid,ncom,ncod,datepost,price,start,0 as StartThis,
            hitag,sklad,cost,minp,mpu,sert_id,rang,0 as morn,0 as sell,0 as isprav,0 as remov,0 as Bad,
            dater,srokh,country,0 as rezerv,units,1 as locked,Ncountry,Gtd,0 as Vitr,Our_ID,
            WEIGHT,@ND as SaveDate,MeasID,0 as OnlyMinP, DCK, ProducerID, CountryID, pin
          from Visual where id=@tekid;
          -- новый вариант, 10.10.16:
          SET IDENTITY_INSERT tdvi OFF; -- включаю автоинкремент.
PRINT('Вставка в TDVI сделана');
        end;
else PRINT('Не требуется вставка в TDVI');

        -- if (@UpWeight=0 ) - проверка заблокирована 21.06.2016. 
        -- следующая проверка вставлена 28.06.2016 во избежание дублирования:
--        if not exists(select * from nvzakaz where datnom=@OrigDatNom and id=@tekid)
--          insert into NV(DatNom, tekid, hitag, price, cost, kol, kol_b, sklad, baseprice, tip, Meas,DelivCancel)
--          values(@NewDatNom, @tekid, @hitag, @price, @cost, @newkol, 0, @sklad, @baseprice, @tip, @Meas,@DelivCancel);
        -- else
        update tdvi set sell=sell-@newkol where id=@tekid;
 

      fetch next from CurBack into @Tekid, @Hitag, @Price, @Cost, @NewKol,
        @Sklad, @BasePrice, @Tip, @Meas, @DelivCancel, @UpWeight, @flgWeight;
    end; -- WHILE
    close CurBack;
    deallocate CurBack;  
print('Курсор закрыт');

    if @flgSale=1 and @KolError=0 and isnull(@NewDatnom,0)<>0 begin
      insert into NVzakaz (datnom,hitag,zakaz,done, price, cost, comp,tm,tmEnd,curWeight,tekWeight,dt,dtEnd,skladNo, id, remark,Op,AuthorOP,Spk)
      select @NewDatnom,hitag,zakaz,0,price,cost,@CompName,convert(VARCHAR,@nd,108),'',0,0,convert(VARCHAR,@nd,104),null,skladNo, 0,'',0,AuthorOP,0
      from nvZakaz v 
      where v.datnom=@OrigDatNom

      update nvzakaz set NewDatnom=@NewDatnom where datnom=@origdatnom;
    end;

    
    if @KolError=0 begin
      update NV set Kol_B=Kol where Datnom=@OrigDatNom and Kol>Kol_B;
      Exec RecalcNCSumm @BackDatnom;
      if @flgSale=1 and isnull(@NewDatnom,0)<>0 Exec RecalcNCSumm @NewDatnom;
      set @NewSP=(select SP from Nc where datnom=@Backdatnom);
    end;
   

    -- Вот здесь кое-что новое, добавлено 23.12.2010:
    -- Записываю выплаты в исходную и возвратную накладные, если это не акция:
    if (@KolError=0) and (@Actn=0) begin
  	  insert into Kassa1(Nd,TM,
        Oper,Act,SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
        remark, RashFlag,LostFlag,LastFlag,
        Op,Bank_ID,Our_ID,BankDay,Actn,Ck, ForPrint, SourDatNom, DCK)
	  values(
	    @ND, @TM,
	    -2,'ВО', dbo.DatNomInDate(@OrigDatNom), dbo.innnak(@OrigDatNom),@NewSP, @Fam, 0, @B_ID,0,0,
        'Возврат. См. накладную '+cast(dbo.inNnak(@backdatnom) as varchar(4))+' от '+convert(char(8), getdate(),4),
        0,1,0, @Op,0,@OurID,@ND,0,0, 0, @OrigDatNom, @NcDCK);
      if @@Error<>0 set @KolError=@KolError + 1;
    end;

    if (@KolError=0) and (@Actn=0) begin
	    insert into Kassa1(Nd,TM,
        Oper,Act,SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
        remark, RashFlag,LostFlag,LastFlag,
        Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
        ForPrint, SourDatNom, DCK)
	    values(@ND, @TM,
  	    -2,'ВО', dbo.DatNomInDate(@backdatnom), dbo.innnak(@backdatnom),-@NewSP, @Fam, 0, @B_ID,0,0,
        'Возврат накладной #'+cast(dbo.inNnak(@OrigDatNom) as varchar(4))+' от '+convert(char(8), dbo.DatNomInDate(@OrigDatNom),4),
        0,1,0,
        @Op,0,@OurID,convert(char(10), getdate(),104),0,0,
        0, @backdatnom, @NcDCK);
      if @@Error<>0 set @KolError=@KolError + 1;
    end;
  
   	declare @dn int
    set @dn=dbo.InDatNom(0,@nd)
 
    update nc set done=iif(((select sum(sp) from nc where datnom>=@dn and b_id=@B_ID and sp>0)>=1500)or(sp<0),1,0)
    where b_id=@B_ID and datnom>=@dn and Done=0
    
    IF @KolError = 0 COMMIT ELSE ROLLBACK; 
    if @flgSale=1 select @newDatnom else select @Backdatnom;
  end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid)
  end catch   
end;