CREATE PROCEDURE dbo.NaklTomorrow @kolError int=0 out
AS
declare @ND datetime
declare @NDPred datetime
declare @DatNom bigint, @newDatNom bigint, @b_id INT, @dck INT
declare @Fam varchar(200)
declare @fact money 
declare @mhID int
BEGIN  
 
  set @KolError = 0;

  --SET TRANSACTION ISOLATION LEVEL SERIALIZABLE 
  begin transaction T1;
  create table #TempTable (DatNom bigint, b_id int, fam varchar(200),fact money, dck int, mhid int)
  
  set @ND=dbo.today()
  set @NDPred=dbo.today()-1
          
  --обнуляем флаг tomorrow (Нет! Вместо него Dayshift) для накладных пробитых позавчера и ранее - их перемещать нельзя(они уже попали в 1С)!!!
  update nc set dayshift=0 where DatNom<dbo.InDatNom(0,@NDPred) and dayshift<>0;
                         
  insert into #TempTable (DatNom, b_id, fam, fact, dck, mhid) 
    select DatNom, b_id,fam, fact, dck, mhid  
    from NC
    where dayshift<>0 and DatNom>dbo.InDatNom(0,@NDPred) and DatNom<dbo.InDatNom(0,@ND);
  

	DECLARE cur CURSOR FAST_FORWARD LOCAL FOR
   	SELECT DatNom, b_id, fam, fact, dck, mhid FROM #TempTable;

  OPEN cur;
   
  FETCH NEXT FROM cur INTO @DatNom, @B_ID, @Fam, @fact, @dck, @mhid;

  WHILE @@FETCH_STATUS = 0 BEGIN
    set @newdatnom = 1 + isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));
    -- Новая строка для исходной накладной:
    INSERT INTO dbo.NC(DatNom,ND,B_ID,B_ID2,Fam,TM,Op,SP,SC,Extra,Srok, -- ЗДЕСЬ, ВИКТОР!
      Fact,OurID,Frizer,Ag_Id,StfNom,StfDate,Remark,Printed,BoxQty,[Weight],
      Actn,CK,Tara,RefDatnom,Izmen,Done,RemarkOp,Marsh2,Ready,DelivCancel,
      DayShift,PrintedNak,SertifDoc,TimeArrival,BruttoWeight,TranspRashod,
      Comp,DCK,NeedDover,[State],DocNom,DocDate,SertNo,SertND,STip,gpOur_ID_old,
      gpOur_ID,mhID,DoverM2,StartDatnom,Nom)
    SELECT 
      @NewDatnom,@ND,B_ID,B_ID2,Fam,dbo.time(),Op,SP,SC,Extra,Srok,
      0.0 AS Fact, OurID,Frizer,Ag_Id,StfNom,StfDate,Remark,0 AS Printed,BoxQty,[Weight],
      Actn,CK,Tara,RefDatnom,Izmen,Done,substring('w.'+RemarkOp,1,50),Marsh2,Ready,DelivCancel,
      DayShift,PrintedNak,SertifDoc,TimeArrival,BruttoWeight,TranspRashod,
      Comp,DCK,NeedDover,[State],DocNom,DocDate,SertNo,SertND,STip,gpOur_ID_old,
      gpOur_ID,mhID,DoverM2,StartDatnom,Nom
    FROM NC where nc.datnom=@Datnom;   

    
    if @@Error<>0 set @KolError=@KolError | 1 
    
    --обновление в ближней логистике
    if @mhid>0
    if not exists(select * from nearlogistic.marshrequests where ReqID=@newDatNom and reqtype=0)
    begin	
      --alter table NearLogistic.MarshRequests disable trigger trg_MarshRequests_u 
      update nearlogistic.marshrequests set dt=getdate(), reqid=@newdatnom, comp=host_name(), DelivCancel=0 where reqid=@datnom and reqtype=0
      if @@error<>0 set @KolError=@KolError | 256
      --alter table NearLogistic.MarshRequests enable trigger trg_MarshRequests_u 
    end;
    
    set @Fam=left(cast(@b_id as varchar(8)) +' (ПЕРЕМЕЩЕНА)'+@Fam, 35)
		
    update SertifLog set DatNom=@NewDatNom where DatNom=@Datnom
	
    update NC 
    set Fam=@Fam, SP=0,SC=0,mhid=0,-- marsh=0 - этого поля больше нет, начиная с 22.08.2018
      Remark='-->'+convert(char(12), @nd,104)+' №'+cast(dbo.InNnak(@NewDatNom) as varchar(4))
    where datnom=@Datnom;
    
    if @@Error<>0 set @KolError=@KolError | 2
    
    if @@Error = 0  begin

      -- Кое-что новое: в поле param4 таблицы Log вписывается информация о новой накладной
      -- для операции 'datsh':
      update LOG set param4=cast(@NewDatNom as CHAR(11)) where Tip='datsh' and Param1=cast(@datnom as char(11));
      
      if @@Error<>0 set @KolError=@KolError | 4
          
      update NV set datnom=@newDatNom where datnom=@DatNom;
      
      -- Возврат на склад:
      update tdvi set Morn=Morn+nv.kol 
        from tdvi inner join nv on nv.tekid=tdvi.ID
        where nv.datnom=@newDatnom and nv.tekid in (select id from nvzakaz where datnom=@datnom);      
      
      
      --очищаем весь товар по складам с терминалом
      delete from nv where datnom=@newDatnom and tekid in (select id from nvzakaz where datnom=@datnom);
      update dbo.nvzakaz set datnom=@newDatNom, Done=0,id=0,remark='',curWeight=0,tekWeight=0, nd=dbo.today() where datnom=@DatNom
      
      if @@Error<>0 set @KolError=@KolError | 8
      
      update TaraDet set datnom=@NewDatNom, Nnak=dbo.InNnak(@newDatnom), selldate=@ND,Tm=convert(char(8), getdate(),108)
      where DatNom=@DatNom and act='ТП'  
      if @@Error<>0 set @KolError=@KolError | 16
      
      exec MovePlataTomorrow @datnom, @newdatnom     
      if @@Error<>0 set @KolError=@KolError | 32
      
        
      update NC_ExiteInfo set datnom=@newdatnom where datnom=@datnom
      if @@Error<>0 set @KolError=@KolError | 64
     
      Declare @ID INT, @KOL decimal(10,3)

        
          
       DECLARE VICURSOR CURSOR FAST_FORWARD LOCAL FOR
       	SELECT TekID,Kol FROM NV where datnom=@newDatnom
       
       OPEN VICURSOR
       
       FETCH NEXT FROM VICURSOR INTO @ID, @KOL
       
       WHILE @@FETCH_STATUS = 0 BEGIN
          update tdVi set morn=morn+@KOL, sell=sell+@KOL where ID=@ID
          if @@Error<>0 set @KolError=@KolError | 128
       
        	FETCH NEXT FROM VICURSOR INTO @ID, @KOL
       END
       CLOSE VICURSOR
       DEALLOCATE VICURSOR            
    end 
        
    FETCH NEXT FROM cur INTO @DatNom, @B_ID, @Fam, @fact, @dck, @mhid
  end;
  CLOSE cur
  deallocate cur

  -- Ошибку обновления nearlogistic.marshrequests игнорируем, остальны - нет. - Виктор, 29.01.2017:
  IF (@KolError & 255) = 0 COMMIT transaction T1;
  ELSE ROLLBACK transaction T1;

  select @KolError as KodError;
END