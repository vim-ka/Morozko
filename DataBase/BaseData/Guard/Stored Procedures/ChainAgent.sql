CREATE procedure Guard.ChainAgent @SourAg_ID int, @ChainAg_id int,
  @Day0 datetime, @Day1 datetime, @Op int, @WholeAgent bit=1, @DckList varchar(8000)=''
as
  declare @LastCHID integer;
begin
  delete from Guard.ChainDet where chid in (select chid from guard.chain where SourAg_ID=@SourAg_ID and day0=@day0 and Day1=@day1);

  delete from guard.chain where SourAg_ID=@SourAg_ID and day0=@day0 and Day1=@day1;

  insert into guard.chain(SourAG_ID,ChainAg_Id,Day0,Day1,Op,WholeAgent)
  values(@SourAG_ID,@ChainAg_Id,@Day0,@Day1, @Op, @WholeAgent);
  set @LastCHID=SCOPE_IDENTITY();

  if @WholeAgent=0 and @DckList<>''
    insert into guard.Chaindet(chid, dck) select @LastChID, k from dbo.Str2intarray(@DckList);

  select @LastCHID as LastChID;   

end;