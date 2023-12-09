

CREATE PROCEDURE dbo.[RecordSklad2_DEL] @WriteToComman bit,@Ncod int,@Doc_nom varchar(10),
                                 @Doc_date datetime,@SCost money,@SPrice money,@op int,
                                 @our_id int,@comp varchar(16),
                                 @NewTov bit, @hitag int,@price money,@cost money,@morn int,
                                 @sert_id int,@minp int,@mpu int,@Dater datetime,@srokh datetime,
                                 @country varchar(15),@sklad int,
                                 @locked bit,@Ncountry int,@GTD varchar(23),@measId int,
                                 @NDS int,@Name varchar(90),@fName varchar(100),@ngrp int, 
                                 @netto decimal(18,3),@brutto decimal(18,3),@weight decimal(18,3),@flgWeigth bit,
                                 @skMan varchar(30),@grMan varchar(30), @BarCode varchar(20),
                                 @BarCodeMinP varchar(20),@Tara int,@Storage int,@Level int,
                                 @ind int,@Line int,@DEPTH int,@Volum float,
                                 @Ncom int OUTPUT,@hTag int OUTPUT
 ---ТЕСТОВАЯ ВЕРСИЯ
AS
BEGIN
Declare @id int,@Ncom2 int,@oldprice money,@BCode varchar(20),@AddTara int,@AddrId int

if @Ncom>0
begin
   if @WriteToComman='true' 
  begin
    Update Comman_ set summaprice=summaprice+@SPrice,
                       summacost=summacost+@SCost
    where Ncom=@Ncom
  end
  set @Ncom2=@Ncom
end
else -- Добавим приход
begin
  if @WriteToComman='true' 
  begin
    set @Ncom2=(select IsNull(max(Ncom),0)+1 from Comman_);
     insert into Comman_ (Ncom,Ncod,date,Time,summaprice,summacost,izmen,isprav,remove,
                         ostat,realiz,corr,plata,closdate,srok,op,our_id,doc_nom,doc_date,
                         comp,izmensc,errflag,copyexists,origdate,skMan,grMan)
    select @Ncom2,Ncod,CONVERT(varchar,getdate(),4),
             CONVERT(varchar,getdate(),8),@SPrice,@SCost,0,0,0,
             @SCost,0,0,0,null,srok,@op,@our_id,@Doc_nom,@Doc_date,@comp,
             0,0,0,null,@skMan,@grMan
    from Vendors
    where ncod=@Ncod
  end
end

-- Добавим новую номенкл. или обновим старую запись
if @NewTov='true'
begin
 -- set @hitag=0;
   EXECUTE GetHitagNomen @hitag output
 -- set @hitag=(select max(Hitag)+1 from Nomen_)
   Insert into Nomen_ (hitag,name,inactive,nds,price,cost,minp,
                     mpu,ngrp,fname,emk,krep,egrp,sert_id,prior,barcode,
                     barcodeMinP,MinW,Netto,Brutto,MinEXTRA,Closed,OnlyMinP,
                     MeasID,Weight_b,flgWeight,disab,VolMinP)
  values (@hitag,@Name,0,@NDS,@price,@cost,@minp,@mpu,@ngrp,@fName,null,null,NULL,@sert_id,
          null,@BarCode,@BarCodeMinP,0,@netto,@brutto,6,0,0,@measId,0,@flgWeigth,0,@Volum)
  set @hTag=@hitag
  
end
 else
  if @NewTov='false' 
  begin
    set @oldprice=(Select price from Nomen_ where hitag=@hitag)
    if abs(@oldprice-@price)>0.05
    begin
      delete BigPriceList_ where hitag=@hitag
    end;
    if (Len(@fName)>0) and (@fName is not null) and (@fName!='') 
    begin
      update Nomen_ set price=@price, cost=@cost, minp=@minp, Nds=@Nds, fname=@fName,
                        VolMinP=@Volum
      where hitag=@hitag
    end
    else
    begin
      update Nomen_ set price=@price, cost=@cost, minp=@minp, Nds=@Nds, VolMinP=@Volum
      where hitag=@hitag
    end;
     /* 
    set @BCode=(Select barcode from Nomen_ where hitag=@hitag)
    if  ((@BCode is NULL) or (@BCode='')) and (@BarCode is not null)
    begin
      update Nomen_ set barcode=@BarCode
      where hitag=@hitag
    end;
   
    set @BCode=(Select barcodeMinP from Nomen_ where hitag=@hitag)
    if  ((@BCode is NULL) or (@BCode='')) and (@BarCodeMinP is not null)
    begin
      update Nomen_ set barcodeMinP=@BarCodeMinP
      where hitag=@hitag
    end;*/
    
    set @hTag= -1
  end
 
  set @AddrId=(select IsNull(AddrID,0) 
                from AddrSpace
               where RStorage=@Storage and Level=@Level and [index]=@ind and 
                    NLine=@Line and DEPTH=@DEPTH)
 
  set @id= (select IsNull(max(Id),0)+1 from tdVi_)
  
  -- Добавим на склад 
  insert into tdVi_ (ND,ID,STARTID,NCOM,NCOD,DATEPOST,PRICE,START,STARTTHIS,HITAG,
                     SKLAD,COST,NALOG5,MINP,MPU,SERT_ID,RANG,MORN,SELL,ISPRAV,
                     REMOV,BAD,DATER,SROKH,COUNTRY,REZERV,UNITS,LOCKED,NCOUNTRY,
                     GTD,VITR,OUR_ID,WEIGHT,MeasId,OnlyMinP,AddrId)
  select CONVERT(varchar,getdate(),4),@id,@id,@Ncom2,@Ncod,CONVERT(varchar,getdate(),4),
         price,@morn,@morn,hitag,@Sklad,cost,null,minp,@mpu,sert_id,5,@morn,0,0,0,0,
         @Dater,@Srokh,@Country,0,'',@locked,@Ncountry,@GTD,0,@our_id,@weight,@measId,
         OnlyMinP,IsNull(@AddrId,0)
  from Nomen_
  where hitag=@hitag
  
  if @Tara>0 
  begin
    set @AddTara=(select Count(FishTag)
                from TaraCode2
                where fishTag=@hitag);
    if @AddTara=0 
    begin
      insert into TaraCode2 (TaraTag,TaraTip,TaraPrice,FishTag)
      select TaraTag,TaraTip,TaraPrice,@hitag
      from TaraCode
      where TaraTag=@Tara
      
      update TaraCode set FishTag=FishTag+','+cast(@hitag as varchar)
      where TaraTag=@Tara
    end;
  end; 
         
  -- Добавим в InpDet
   insert into InpDet_ (nd,ncom,id,hitag,price,cost,kol,sert_id,minp,
                      mpu,dater,srokh,nalog5,op,country,sklad,kol_b,
                      summacost,BasePrice)
  values (CONVERT(varchar,getdate(),4),@Ncom2,@id, @hitag,@price,
         @cost,@morn,@sert_id,@minp,@mpu,CONVERT(varchar,@Dater,4),CONVERT(varchar,@srokh,4),
         0,@op,@country,@sklad,0,@cost*@morn,0)

 set @Ncom=@Ncom2
END