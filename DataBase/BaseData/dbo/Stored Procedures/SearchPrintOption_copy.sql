CREATE procedure dbo.SearchPrintOption_copy @Datnom int
as
declare @ND datetime, @Stip int, @NeedDover Bit, @B_ID int, @OurID int, @Master int, @DCK int, @DckVend int, 
  @NeedDover2 smallint, @depid int, @VendID int
begin

  select @NeedDover2=DoverM2, @NeedDover = NeedDover,  @Stip = Stip, @Dck = Dck, @ND = ND, @DckVend=gpOur_ID from NC where NC.DatNom = @Datnom;
  set @DepID=(select A.DepID from Defcontract DC inner join Agentlist A on A.ag_id=dc.ag_id where dc.dck=@DCK); 

  select @b_id=pin, @ourID=our_ID from defcontract where dck=@dck;
  set @master=(select master from def where pin=@B_ID);


  if @Stip = 4 set @VendID=@DckVend
  else         set @VendID=@OurID;
  
  
  CREATE TABLE #m( [OurID] smallint, [Pin] int, [Dck] int,[QtyNakl] tinyint,
    [QtyStf] tinyint, [QtyTorg12] tinyint, [QtyTtn] tinyint,  [QtyBill] tinyint,
    [QtyDover] tinyint,  [StfBase] varchar(40),  [Remark] varchar(60),  [rec] int,
    [QtyUPD] tinyint,  [DCKVend] int, op int, QtyDover2 tinyint, QtyDover2money tinyint, QtyDover2goods tinyint, Torg12weight smallint,
    Actual bit, [QtyMH3] tinyint)

  print('@dckvend='+cast(@dckvend as varchar)); -- 0
  print('@dck='+cast(@dck as varchar));         -- 52061
  print('@OurID='+cast(@OurID as varchar));         -- 

 /*******************************ПРОВЕРКА НА СОВПАДЕНИЕ (ПОКУПАТЕЛЯ ИЛИ ДОГОВОРА ИЛИ МАСТЕРА) И ПОСТАВЩИКА************************************/ 
  if exists(select * from PrintOptions where Actual=1 and @Stip=4 and DckVend=@VendID and Dck=@DCK) 
  begin
    print('a1');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3 from PrintOptions  
    where DCKvend = @VendID and DCK=@DCK and Actual=1;
  end;
  else
  if exists(select * from PrintOptions where Actual=1 and @Stip<>4 and OurID=@VendID and Dck=@DCK) 
  begin
    print('a2');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3 from PrintOptions  
    where OurID=@VendID and DCK=@DCK and Actual=1;
  end;
  else
  if exists(select * from PrintOptions where Actual=1 and @Stip=4 and DckVend=@VendID and pin=@B_ID) 
  begin
    print('a3');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3 from PrintOptions  
    where DCKVend=@VendID and pin=@B_ID and Actual=1;
  end;
  else
  if exists(select * from PrintOptions where Actual=1 and @Stip<>4 and OurID=@VendID and pin=@B_ID) 
  begin
    print('a4');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3 from PrintOptions  
    where OurID=@VendID and pin=@B_ID and Actual=1;
  end;
  else
  if exists(select * from PrintOptions where Actual=1 and @Stip=4 and DckVend=@VendID and pin=@master and @master>0) 
  begin
    print('a5');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3 from PrintOptions  
    where DCKVend=@VendID and pin=@master and Actual=1;
  end;
  else
  if exists(select * from PrintOptions where Actual=1 and @Stip<>4 and OurID=@VendID and pin=@master and @master>0) 
  begin
    print('a6');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3 from PrintOptions  
    where OurID=@VendID and pin=@master and Actual=1;
  end;
  
 /*******************************ПРОВЕРКА НА СОВПАДЕНИЕ ПОКУПАТЕЛЯ ИЛИ ДОГОВОРА ИЛИ МАСТЕРА************************************/ 
 
 else
  if exists(select * from PrintOptions where Actual=1 and Dck=@DCK) 
  begin
    print('b1');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3 from PrintOptions  
    where DCK=@DCK and Actual=1;
  end;
  else
  if exists(select * from PrintOptions where Actual=1 and pin=@B_ID) 
  begin
    print('b2');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3 from PrintOptions  
    where pin=@B_ID and Actual=1;
  end;
  else
  if exists(select * from PrintOptions where Actual=1 and pin=@master and @master>0) 
  begin
    print('b3');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3 from PrintOptions  
    where pin=@master and Actual=1;
  end;
 /*******************************ПРОВЕРКА НА СОВПАДЕНИЕ ПОСТАВЩИКА************************************/   
else
  if exists(select * from PrintOptions where Actual=1 and DCKVend=@VendID and @Stip=4) 
  begin
    print('c1');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3 from PrintOptions  
    where Actual=1 and DCKVend=@VendID;
  end;
  else
  if exists(select * from PrintOptions where Actual=1 and OurID=@VendID and @Stip<>4) 
  begin
    print('c2');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3 from PrintOptions  
    where Actual=1 and OurID=@VendID
  end;
 
  
  if (@NeedDover  = 1) and not EXISTS(select * from #m where qtyDover>0) update #m set QtyDover=1;
  
  if (@NeedDover2>0) update #m set QtyDover2=@NeedDover2;
  
  if @DepID=43 and not exists(select * from PrintOptions P where (P.Pin=@B_ID or P.Dck=@DCK) and P.qtyttn>0 and P.Actual=1)
    update #M set QtyTtn=0;  
  
  if exists(select * from nc where datnom=@datnom and stip in (2,3))
    update #m set qtyStf=0, qtyBill=0;

  select top 1 * from #m; -- Нужна проверка на кол-во полученных правил

end;