CREATE procedure dbo.SearchPrintOption_debug @Datnom int
as
declare @ND datetime, @Stip int, @NeedDover Bit, @B_ID int, @Our_ID int, @Master int, @DCK int, @DckVend int, @NeedDover2 Bit
begin

  select @NeedDover = NeedDover,  @Stip = Stip, @Dck = Dck, @ND = ND from NC where NC.DatNom = @Datnom;
  
  if @Stip = 4 begin
    if @ND=dbo.today() set @DCKVend=(select min(tdvi.Dck) from NV inner join TDVI on TDVI.id=nv.tekid where nv.Datnom=@Datnom);
    else set @DCKVend=(select min(V.Dck) from NV inner join Visual V on V.id=nv.tekid where nv.Datnom=@Datnom);    
  end; 
  else set @DckVend = 0;
  
  select @b_id=pin, @our_ID=our_ID from defcontract where dck=@dck;
  set @master=(select master from def where pin=@B_ID);
  
  CREATE TABLE #m( [OurID] smallint, [Pin] int, [Dck] int,[QtyNakl] tinyint,
    [QtyStf] tinyint, [QtyTorg12] tinyint, [QtyTtn] tinyint,  [QtyBill] tinyint,
    [QtyDover] tinyint,  [StfBase] varchar(40),  [Remark] varchar(60),  [rec] int,
    [QtyUPD] tinyint,  [DCKVend] int, op int, QtyDover2 tinyint)

  if (@dckVend>0) and (@Dck>0) and exists(select * from PrintOptions where DCKVend = @DCKVend and DCK=@DCK)
  insert into #m select * from PrintOptions  
    where DCKvend = @DCKVend and DCK=@DCK;


/*  INSERT INTO #m(OurID,  Pin,  Dck,  QtyNakl,  QtyStf,  QtyTorg12,  QtyTtn,  QtyBill,
    QtyDover,  StfBase,  Remark,  rec,  QtyUPD,  DCKVend) 
  select OurID,  Pin,  Dck,  QtyNakl,  QtyStf,  QtyTorg12,  QtyTtn,  QtyBill,
    QtyDover,  StfBase,  Remark,  rec,  QtyUPD,  DCKVend from PrintOptions  
    where DCKvend = @DCKVend and DCK=@DCK;
*/    
  else if (@dckVend>0)and(@B_ID>0) and exists(select * from PrintOptions where DCKVend = @DCKVend and PIN=@B_ID)
    insert into #m select * from PrintOptions where DCKvend = @DCKVend and PIN=@B_ID;
  else if (@dckVend>0)and(@Master>0) and exists(select * from PrintOptions where DCKVend = @DCKVend and PIN=@Master)
    insert into #m select * from PrintOptions where DCKvend = @DCKVend and PIN=@Master;
  else if (@dckVend>0) and exists(select * from PrintOptions where DCKVend = @DCKVend and DCK=0 and PIN=0)
    insert into #m select * from PrintOptions where DCKvend = @DCKVend and DCK=0 and PIN=0;
    
  -- След. три ветки - это для наших организаций, пока мы не указываем для них DCKVend:  
  else if (@DCKVend=0) and (@dck>0) and exists(select * from PrintOptions where DCK = @DCK and DCKVend=0)
    insert into #m select * from PrintOptions where DCK = @DCK and DCKVend=0;
  else if (@DCKVend=0) and (@B_ID>0) and exists(select * from PrintOptions where Pin=@B_ID and DCK=0 and DCKVend=0)
    insert into #m select * from PrintOptions where Pin = @B_ID and DCKVend=0;
  else if (@DckVend=0) and (@Master>0) and  exists(select * from PrintOptions where Pin=@master and DCK=0 and DckVend=0)
      insert into #m select * from PrintOptions where Pin = @master and DckVend=0;
  else insert into #m select * from PrintOptions where Pin=0 and Dck=0 and OurID=@Our_ID;

select @DckVend as DckVend, @Dck as Dck;  
    
  if (@NeedDover=1) and not EXISTS(select * from #m where qtyDover>0) update #m set QtyDover=1;
  if (@NeedDover2=1) and not EXISTS(select * from #m where qtyDover2>0) update #m set QtyDover2=1;

  if exists(select * from nc where datnom=@datnom and stip in (2,3))
    update #m set qtyStf=0, qtyBill=0;
  select * from #m;

end;