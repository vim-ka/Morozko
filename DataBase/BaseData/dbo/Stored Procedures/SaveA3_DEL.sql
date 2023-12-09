

CREATE procedure SaveA3_DEL @a3id int
as
declare @NewNcom int 
declare @Our_ID smallint
declare @Ncod int
declare @ND datetime
declare @TekID int
declare @Srok int
declare @op int

DECLARE @hitag int
DECLARE @price decimal(10,2)
DECLARE @cost decimal(12,5)
declare @kol int
DECLARE @sert_id int 
DECLARE @minp int
DECLARE @mpu int
DECLARE @dater datetime
DECLARE @srokh datetime
DECLARE @Country varchar(15)
DECLARE @sklad smallint
DECLARE @summacost decimal(12,2)
DECLARE @BasePrice decimal(10,2)
declare @Locked bit 
declare @OnlyBox bit 
declare @NDS tinyint
declare @Ncountry int
declare @MeasID tinyint
declare @OnlyBase bit
declare @Netto decimal(12,3)
declare @Brutto decimal(12,3)
declare @WEIGHT decimal(12,3)
declare @Gtd varchar(30)
declare @StrDateR varchar(20)
declare @StrSrokh varchar(20)

begin

  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
  begin transaction 

  set @ND=CONVERT(varchar,getdate(),4);
  set @Our_ID=(select Our_ID from a3req where a3id=@a3id);
  set @Ncod=(select Ncod from a3req where a3id=@A3id);
  set @OP=(select OP from a3req where a3id=@a3id);
  set @Srok=(select Srok from Vendors V inner join A3req on V.Ncod=A3req.Ncod where A3req.a3id=@A3id);

  set @NewNcom=(select IsNull(max(Ncom),0)+1 from Comman); -- новый номер комиссии

  -- Заголовок:
  insert into Comman (Ncom,Ncod,
    [date],[Time],
    summaprice,summacost,ostat,
    realiz,corr,plata,closdate,srok,op,our_id,doc_nom,doc_date,
    comp,izmensc,errflag,copyexists,origdate,skMan,grMan)
  select @NewNcom as Ncom,Ncod,
    @nd as [date], CONVERT(varchar,getdate(),8) as [time],
    SP,SC, SC as Ostat,
    0 as realiz,0 as corr, 0 as plata, null as closdate,@srok,op,our_id,Doc_nom,Doc_date,
    comp, 0,0,0,null,skMan,grMan
    from a3req
    where a3id=@a3id;

  -- Табличная часть:
  declare CurDet cursor fast_forward  
    for select hitag, price, cost, kol, sert_id, minp,mpu,dater,srokh,Country,
    sklad,summacost,BasePrice, Locked, OnlyBox, NDS, Ncountry,MeasID,
    OnlyBase, Netto,Brutto,WEIGHT, Gtd
    from a3reqdet
    where a3id=@a3id;
    
  open CurDet; 
  fetch next from CurDet into @hitag, @price, @cost, @kol, @sert_id, @minp,@mpu,@dater,@srokh,@Country,
    @sklad,@summacost,@BasePrice, @Locked, @OnlyBox, @NDS, @Ncountry,@MeasID,
    @OnlyBase, @Netto,@Brutto,@WEIGHT, @Gtd

  WHILE (@@FETCH_STATUS=0)  BEGIN
    
    if @dater is null or @Dater<'20000101' begin
      set @dater=null;
      set @StrDateR=null;
    end; else set @StrDater=CONVERT(varchar,@dater,4);
    
    if @srokh is null or @srokh<'20000101' begin
      set @srokh=null;
      set @Strsrokh=null;
    end; else set @Strsrokh=CONVERT(varchar,@srokh,4);
    
  
    set @TekID=(select IsNull(max(ID),0)+1 from TDVI); -- новый ID товара

    -- Запись в склад:
    insert into tdVI(ND, ID,StartID,Ncom,Ncod,DatePost,
      Price,Start,StartThis,Hitag,Sklad,Cost,Nalog5,MinP,Mpu,Sert_ID,
      Rang,Morn,Sell,Isprav,REMOV,Bad,DateR,Srokh,Country,
      Rezerv,Units,Locked,Ncountry,Gtd,Vitr,Our_ID,WEIGHT,
      SaveDate,MeasID,OnlyMinP)
	values(@ND, @TekID,@TekID,@NewNcom,@Ncod,@ND,
      @Price,@Kol,@Kol,@Hitag,@Sklad,@Cost,0,@MinP,@Mpu,@Sert_ID,
      '5',@Kol,0,0,0,0,@DateR,@Srokh,@Country,
      0,'',@Locked,@Ncountry,@Gtd,0,@Our_ID,@WEIGHT,
      @ND, @MeasID,@OnlyBox);
    
    -- Запись детализации прихода:
   
   insert into Inpdet(nd, ncom, id, hitag, price, cost, kol,
      sert_id,minp,mpu,dater,srokh,nalog5,op,country,
      sklad,kol_b,summacost,BasePrice)
    values(@nd, @newncom, @TekID, @hitag, @price, @cost, @kol,
      @sert_id,@minp,@mpu,@StrDateR,CONVERT(varchar,@srokh,4),0,@op,@country,
      @sklad,0,@summacost,@BasePrice);

    fetch next from CurDet into @hitag, @price, @cost, @kol, @sert_id, @minp,@mpu,@dater,@srokh,@Country,
      @sklad,@summacost,@BasePrice, @Locked, @OnlyBox, @NDS, @Ncountry,@MeasID,
      @OnlyBase, @Netto,@Brutto,@WEIGHT, @Gtd
  END; -- WHILE  
  close CurDet;
  deallocate CurDet;       
  update A3req set Ncom=@NewNcom, Done=1 where a3id=@a3id;
  update Comman set SummaPrice=(SELECT SUM(price*kol) from inpdet 
    where Ncom=@NewNcom) where Ncom=@NewNcom;
  update Comman set SummaCost=(SELECT SUM(Cost*kol) from inpdet 
    where Ncom=@NewNcom) where Ncom=@NewNcom;
  select @NewNcom;  
  COMMIT;
end