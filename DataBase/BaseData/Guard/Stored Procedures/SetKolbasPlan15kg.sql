create procedure Guard.SetKolbasPlan15kg @nd datetime
as
declare @AG_ID int, @B_ID int, @DayOfWeek smallint
begin
  set @DayOfWeek=datepart(WEEKDAY, @ND);
  declare c1 cursor fast_forward for
  select distinct p.ag_id, dc.pin as b_id
  from 
    PlanVisit2 p 
    inner join defcontract dc on dc.dck=p.dck
    inner join def on def.pin=dc.pin
  where 
    p.dn=@DayOfWeek and dc.Actual=1 and dc.Disab=0 and dc.Disab=0
    and def.Disab=0 and def.Actual=1 and def.Debit=0;

  open C1;
  fetch from C1 into @ag_id, @b_id;
  while @@fetch_status=0 BEGIN
    if not exists(select *  from guard.KolbasPlan where ND=@nd and ag_id=@ag_id and b_id=@B_ID)
      insert into Guard.kolbasplan(nd,ag_id,b_id,KolbasWeight)
      values(@ND, @Ag_ID, @B_ID, 15.0);
    fetch from C1 into @ag_id, @b_id;
  end;
  close c1;
  deallocate c1;
end;