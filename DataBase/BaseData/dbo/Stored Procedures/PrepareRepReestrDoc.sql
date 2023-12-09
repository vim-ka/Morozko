CREATE procedure PrepareRepReestrDoc
  @dck int, @day0 datetime, @day1 datetime
as
declare @yesterday datetime
begin
  set @yesterday=DATEADD(DAY, -1, dbo.today())
  create table #t(datnom int);
  
  if @day1 < dbo.today()  
    insert into #t
    select distinct nv.datnom
    from 
      nv 
      inner join visual v on v.id=nv.TekID 
      inner join comman cm on cm.ncom=v.ncom
      inner join nc on nc.datnom=nv.datnom
    where
      nv.datnom>=1401010001 and cm.dck = @DCK
      and
        (
         (nc.stfdate between @day0 and @day1)
         or
         (nc.StfDate is null and nc.nd between @day0 and @day1)
        );
  else BEGIN
    insert into #t
    select distinct nv.datnom
    from 
      nv 
      inner join visual v on v.id=nv.TekID 
      inner join comman cm on cm.ncom=v.ncom
      inner join nc on nc.datnom=nv.datnom
    where
      nv.datnom>=1401010001 and cm.dck = @DCK
      and
        (
         (nc.stfdate between @day0 and @yesterday)
         or
         (nc.StfDate is null and nc.nd between @day0 and @yesterday)
        );
    insert into #t
    select distinct nv.datnom
    from 
      nv 
      inner join tdvi v on v.id=nv.TekID 
      inner join comman cm on cm.ncom=v.ncom
      inner join nc on nc.datnom=nv.datnom
    where
      nv.datnom>=1401010001 and cm.dck = @DCK
      and
        (
         (nc.stfdate=dbo.today())
         or
         (nc.StfDate is null and nc.nd=dbo.today())
        );  
  end;

  create index t_temp_idx on #t(datnom);

  select
    case when nc.stfdate>0 then nc.stfdate else nc.nd end as DateDoc,
    nv.datnom, nc.stfnom, nc.stfdate, nc.fam, def.gpaddr, def.braddr,
    nc.op,
    case when nc.op<1000 then u.fio else p.fio end as Author,
    sum((nv.kol-nv.kol_b)*nv.price*(1.0+nc.extra/100)) as SP
  from
    #t
    inner join nv on nv.datnom=#t.datnom
    inner join nc on nc.datnom=nv.datnom
    left join usrpwd u on u.uin=nc.op and nc.op<1000
    left join agentlist a on a.ag_id=nc.op-1000 and nc.op>=1000
    left join person p on p.p_id=a.p_id and p.p_id>0
    left join def on def.pin=nc.b_id and nc.b_id>0
  group by
    case when nc.stfdate>0 then nc.stfdate else nc.nd end,
    nv.datnom, nc.stfnom, nc.stfdate, nc.fam, def.gpaddr, def.braddr,
    nc.op, case when nc.op<1000 then u.fio else p.fio end, nc.datnom
  having sum(nv.kol-nv.kol_b) <>0
  order by
    case when nc.stfdate>0 then nc.stfdate else nc.nd end,
    nc.datnom
    
end