CREATE PROCEDURE dbo.[NaklTomorrow_OLD]
AS
declare @ND datetime
declare @NDPred datetime
declare @DatNom int, @newDatNom int, @b_id INT, @dck INT
declare @Fam varchar(200)
declare @fact money 
BEGIN  
  declare @KolError int
  set @KolError = 0
  
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE 
  begin TRANSACTION;                            
  create table #TempTable (DatNom int, b_id int, fam varchar(200),fact money, dck int)
  
  set @ND=dateadd(dd, datediff(dd, 0, getdate())+0, 0) -- это правильнее, чем convert(char(10), getdate(),104);
  set @NDPred=dateadd(dd, datediff(dd, 0, getdate())-1, 0) -- это правильнее, чем convert(char(10), getdate(),104);
          
  --обнуляем флаг tomorrow для накладных пробитых позавчера и ранее - их перемещать нельзя(они уже попали в 1С)!!!
  update nc set tomorrow=0 where DatNom<dbo.InDatNom(0,@NDPred) and tomorrow=1 
                         
  insert into #TempTable (DatNom, b_id, fam, fact, dck) 
    select DatNom, b_id,fam, fact, dck  
    from NC
    where tomorrow=1 and DatNom>dbo.InDatNom(0,@NDPred) and DatNom<dbo.InDatNom(0,@ND);
  
 
  DECLARE @CURSOR CURSOR 
  
  SET @CURSOR  = CURSOR SCROLL FOR SELECT DatNom, b_id, fam, fact, dck FROM #TempTable

  OPEN @CURSOR 

  FETCH NEXT FROM @CURSOR INTO @DatNom, @B_ID, @Fam, @fact, @dck
  
  WHILE @@FETCH_STATUS = 0 BEGIN  
    set @newdatnom = 1 + isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));
  
    -- Новая строка для исходной накладной:
    insert into NC(DatNom, ND,  B_ID,  Fam,  TM,  Op,  SP,  SC,  Extra,  Srok,  Fact,  OurID,
      Pko,  man_id,  BankId,  Tovchk,  Frizer,  Ag_Id,  StfNom,  StfDate,  Qtyfriz,
      Remark,  Printed,  Marsh,  BoxQty,  [Weight],  Actn,  CK,  Tara,  RefDatnom,
      MarshDay,  Sk50prn,  SPice,  SCice,  Izmen,  Back,  SpPF,  ScPF,  SpOther,
      ScOther,  Done,  Tomorrow,  RemarkOp,  Marsh2,  Ready,  DelivCancel,  DayShift,
      PrintedNak,  NeedCK,  SertifDoc,  SPE,  DeltaSpecSC,  TimeArrival,  BruttoWeight,
      TranspRashod,  Comp,  SertND,  SertNo,  Sk50present,  DCK,  B_Id2,
      NeedDover,  XMLDocs,  LastIzm,  [State],  DocNom,  DocDate,  STip,  
      gpOur_ID_old,  gpOur_ID)
    SELECT 
      @NewDatNom, @ND,  B_ID,  Fam,  convert(char(8), getdate(),108),  Op,  SP,  SC,  Extra,  Srok,  0,  OurID,
      Pko,  man_id,  BankId,  Tovchk,  Frizer,  Ag_Id,  StfNom,  StfDate,  Qtyfriz,
      Remark,  0,  Marsh,  BoxQty,  [Weight],  Actn,  CK,  Tara,  RefDatnom,
      MarshDay,  Sk50prn,  SPice,  SCice,  Izmen,  Back,  SpPF,  ScPF,  SpOther,
      ScOther,  Done,  0,  substring('w.'+RemarkOp,1,50),  Marsh2,  Ready,  DelivCancel,  DayShift,
      PrintedNak,  NeedCK,  SertifDoc,  SPE,  DeltaSpecSC,  TimeArrival,  BruttoWeight,
      TranspRashod,  Comp,  SertND,  SertNo,  Sk50present,  DCK,  B_Id2,
      NeedDover,  XMLDocs,  LastIzm,  [State],  DocNom,  DocDate,  STip,  
      gpOur_ID_old,  gpOur_ID
    FROM NC 
    where nc.datnom=@Datnom;
      
    if @@Error<>0 set @KolError=@KolError + 1 
    
    set @Fam=left(cast(@b_id as varchar(8)) +' (ПЕРЕМЕЩЕНА)'+@Fam, 35)
		
    update SertifLog set DatNom=@NewDatNom where DatNom=@Datnom
	
    update NC 
    set Fam=@Fam, SP=0,SC=0,
      Remark='-->'+convert(char(12), @nd,104)+' №'+cast(dbo.InNnak(@NewDatNom) as varchar(4))
    where datnom=@Datnom;
    
    if @@Error<>0 set @KolError=@KolError + 1 
    
    if @@Error = 0  begin

      -- Кое-что новое: в поле param4 таблицы Log вписывается информация о новой накладной
      -- для операции 'datsh':
      update LOG set param4=cast(@NewDatNom as CHAR(10)) where Tip='datsh' and Param1=cast(@datnom as char(10));
      
      if @@Error<>0 set @KolError=@KolError + 1 
          
      update NV set datnom=@newDatNom where datnom=@DatNom;
      
      -- Возврат на склад:
      update tdvi set Sell=Sell-nv.kol 
        from tdvi inner join nv on nv.tekid=tdvi.ID
        where nv.datnom=@newDatnom and nv.tekid in (select id from nvzakaz where datnom=@datnom);      
      
      
      --очищаем весь товар по складам с терминалом
      delete from nv where datnom=@newDatnom and tekid in (select id from nvzakaz where datnom=@datnom);
      update NVzakaz set datnom=@newDatNom, Done=0,id=0,remark='',curWeight=0,tekWeight=0 where datnom=@DatNom
      
      if @@Error<>0 set @KolError=@KolError + 1 
      
      update TaraDet set datnom=@NewDatNom, Nnak=dbo.InNnak(@newDatnom), selldate=@ND,Tm=convert(char(8), getdate(),108)
      where DatNom=@DatNom and act='ТП'  
      if @@Error<>0 set @KolError=@KolError + 1 
      
      exec MovePlataTomorrow @datnom, @newdatnom     
      if @@Error<>0 set @KolError=@KolError + 1 
      
        
      update NC_ExiteInfo set datnom=@newdatnom where datnom=@datnom
      if @@Error<>0 set @KolError=@KolError + 1 
     
      Declare @ID INT, @KOL decimal(10,3)
    
      DECLARE @VICURSOR CURSOR 
      SET @VICURSOR  = CURSOR SCROLL
      FOR SELECT TekID,Kol FROM NV where datnom=@newDatnom
      OPEN @VICURSOR 
      FETCH NEXT FROM @VICURSOR INTO @ID, @KOL
      WHILE @@FETCH_STATUS = 0
      BEGIN  
         update tdVi set morn=morn+@KOL, sell=sell+@KOL where ID=@ID
         if @@Error<>0 set @KolError=@KolError + 1 
         FETCH NEXT FROM @VICURSOR INTO  @ID, @KOL
      END
      CLOSE @VICURSOR
      DEALLOCATE @VICURSOR     
    end 
    FETCH NEXT FROM @CURSOR INTO @DatNom, @B_ID, @Fam, @fact, @dck
  END
  
  CLOSE @CURSOR 
  deallocate @CURSOR
  IF @KolError = 0 COMMIT ELSE ROLLBACK;
END