CREATE procedure dbo.SearchPrintOption @Datnom BIGINT
as
declare @ND datetime, @Stip int, @NeedDover Bit, @B_ID int, @Our_ID int, @Master int, 
  @DCK int, @DckVend int, 
  @NeedDover2 smallint, @depid INT, @Worker bit
begin

  select @NeedDover2=DoverM2, @NeedDover = NeedDover,  @Stip = Stip, @Dck = Dck, @ND = ND from NC where NC.DatNom = @Datnom;
  set @DepID=(select A.DepID from Defcontract DC inner join Agentlist A on A.ag_id=dc.ag_id where dc.dck=@DCK); 
  select @b_id=pin, @our_ID=our_ID from defcontract where dck=@dck;
  select @master=master, @Worker=worker from def where pin=@B_ID;

  -- @DoverM2 может быть равен 0, 1, 1001, 2001
/*  set @NeedDover2money=0; 
  set @NeedDover2goods=0; 
  if @DoverM2 between 1 and 999 set @NeedDover2money=1;
  if @DoverM2 between 1000 and 1999 set @NeedDover2goods=1;
  else if @DoverM2 between 2000 and 2999 begin set @NeedDover2money=1; set @NeedDover2goods=1; end;
*/  
  if @Stip = 4 begin
    print('Stip=4');
    if @ND=dbo.today() set @DCKVend=(select min(tdvi.Dck) from NV inner join TDVI on TDVI.id=nv.tekid where nv.Datnom=@Datnom);
    else set @DCKVend=(select min(V.Dck) from NV inner join Visual V on V.id=nv.tekid where nv.Datnom=@Datnom);    
  end; 
  else set @DckVend = 0;
  
  
  CREATE TABLE #m( [OurID] smallint, [Pin] int, [Dck] int,[QtyNakl] tinyint,
    [QtyStf] tinyint, [QtyTorg12] tinyint, [QtyTtn] tinyint,  [QtyBill] tinyint,
    [QtyDover] tinyint,  [StfBase] varchar(40),  [Remark] varchar(60),  [rec] int,
    [QtyUPD] tinyint,  [DCKVend] int, op int, QtyDover2 tinyint,  Torg12weight smallint,
    Actual bit, [QtyMH3] tinyint)

  print('@dckvend='+cast(@dckvend as varchar)); -- 0
  print('@dck='+cast(@dck as varchar));         -- 52061
  print('@Our_ID='+cast(@Our_ID as varchar));         -- 

   if (@Worker=1) 
  begin
    print('a0');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select Our_ID,Pin,Dck,1,0,0,0,0,0,
      0,'',0,0,0,0,0,0,1,0
    FROM DefContract WHERE dck=@dck
    --from PrintOptions where DCKvend = @DCKVend and DCK=@DCK and Actual=1;
  end;
  
  else
  if (@dckVend>0) and (@Dck>0) and exists(select * from PrintOptions where DCKVend = @DCKVend and DCK=@DCK and Actual=1) 
  begin
    print('a1');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3)
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3 from PrintOptions  
    where DCKvend = @DCKVend and DCK=@DCK and Actual=1;
  end;


/*  INSERT INTO #m(OurID,  Pin,  Dck,  QtyNakl,  QtyStf,  QtyTorg12,  QtyTtn,  QtyBill,
    QtyDover,  StfBase,  Remark,  rec,  QtyUPD,  DCKVend) 
  select OurID,  Pin,  Dck,  QtyNakl,  QtyStf,  QtyTorg12,  QtyTtn,  QtyBill,
    QtyDover,  StfBase,  Remark,  rec,  QtyUPD,  DCKVend from PrintOptions  
    where DCKvend = @DCKVend and DCK=@DCK;
*/    
  else if (@dckVend>0)and(@B_ID>0) and exists(select * from PrintOptions where DCKVend = @DCKVend and PIN=@B_ID and Actual=1)
  begin
    print('a2');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3) 
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3
      from PrintOptions where DCKvend = @DCKVend and PIN=@B_ID and Actual=1;
  end;
  else if (@dckVend>0)and(@Master>0) and exists(select * from PrintOptions where DCKVend = @DCKVend and PIN=@Master and Actual=1)
  begin
    print('a3');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3) 
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3
      from PrintOptions where DCKvend = @DCKVend and PIN=@Master and Actual=1;
  end;
  else if (@dckVend>0) and exists(select * from PrintOptions where DCKVend = @DCKVend and DCK=0 and PIN=0 and Actual=1)
  begin
    print('a4');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight,Actual, QtyMh3) 
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
    StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3
    from PrintOptions where DCKvend = @DCKVend and DCK=0 and PIN=0 and Actual=1;
  end; 
  
  else if (@dckVend>0) and exists(select * from PrintOptions where DCKVend = 0 and PIN=@Master and Actual=1)
  begin
    print('a4.1');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight,Actual, QtyMh3) 
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
    StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3
    from PrintOptions where DCKvend = 0 and PIN=@master and Actual=1;
  end;
    
  -- След. три ветки - это для наших организаций, пока мы не указываем для них DCKVend:  
  else if (@DCKVend=0) and (@dck>0) and exists(select * from PrintOptions where DCK = @DCK and DCKVend=0 and Actual=1)
  begin
    print('a5');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3) 
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
    StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3
    from PrintOptions where DCK = @DCK and DCKVend=0 and Actual=1;
  end;
  else if (@DCKVend=0) and (@B_ID>0) and exists(select * from PrintOptions where Pin=@B_ID and DCK=0 and DCKVend=0 and Actual=1)
  begin
    print('a6');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3) 
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
    StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3
    from PrintOptions where Pin = @B_ID and DCKVend=0 and Actual=1;
  end;
  else if (@DckVend=0) and (@Master>0) and  exists(select * from PrintOptions where Pin=@master and DCK=0 and DckVend=0 and Actual=1)
  begin
    print('a7');
      insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
        StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3) 
      select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3
      from PrintOptions where Pin = @master and DckVend=0 and Actual=1;
  end;
  else 
  begin
    print('a8');
    insert into #m(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3) 
    select OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTTN,QtyBill,QtyDover,
      StfBase,Remark,Rec,QtyUpd,DckVend,Op,QtyDover2,Torg12weight, Actual, QtyMh3
      from PrintOptions where Pin=0 and Dck=0 and OurID=@Our_ID and Actual=1;
  end;
  
  
  if (@NeedDover  = 1) and not EXISTS(select * from #m where qtyDover>0) update #m set QtyDover=1;
  
  if (@NeedDover2>0) update #m set QtyDover2=@NeedDover2;
  
  if @DepID=43 and not exists(select * from PrintOptions P where (P.Pin=@B_ID or P.Dck=@DCK) and P.qtyttn>0 and P.Actual=1)
    update #M set QtyTtn=0;  
  
  if exists(select * from nc where datnom=@datnom and stip in (2,3))
    update #m set qtyStf=0, qtyBill=0;

  select *,cast(0 as tinyint)as  QtyDover2money, cast(0 as tinyint) as  QtyDover2goods from #m;

end;