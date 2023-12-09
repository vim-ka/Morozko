CREATE PROCEDURE warehouse.terminal_GetBackSkladButtonsList
@reqid int,
@hitag int
AS
BEGIN
	set nocount on
	declare @depid int
  declare @ngrp int
	if object_id('tempdb..#btn') is not null drop table #btn
  if object_id('tempdb..#skl') is not null drop table #skl
	create table #btn (sklad int, btID int, btnname varchar(10), visible_name varchar(5), clr varchar(50), ord int)
  create table #skl (btid int,sklad int,ord int)
  
  insert into #btn 
  select 0, bt.btid, bt.btnname, bt.btncaption, bt.clr, bt.ord
  from warehouse.backtypes bt
  
	select @depid=a.depid
  from dbo.reqreturn r 
  join dbo.defcontract dc on dc.dck=r.dck
  join dbo.agentlist a on a.ag_id=dc.ag_id
  where r.reqnum=@reqid
  
  select @ngrp=n.ngrp
  from dbo.nomen n 
  where n.hitag=@hitag
  
  insert into #skl
  select *
  from (
	select c.btid, isnull(a.sklad,0) [sklad], 1 [ord] 
  from #btn c
  left join warehouse.sklad_ngrp_forback a on a.backtype=c.btid and a.ngrp=@ngrp and a.depid=@depid
  union all
  select c.btid, isnull(b.sklad,0) [sklad], 2 [ord] 
  from #btn c
  left join warehouse.sklad_ngrp_forback b on b.backtype=c.btid and b.ngrp=@ngrp and b.depid=0
  union all  
  select c.btid, isnull(aa.sklad,0) [sklad], 3 [ord] 
  from #btn c
  left join warehouse.sklad_ngrp_forback aa on aa.backtype=c.btid and aa.ngrp=dbo.GetGrOnlyParent(@ngrp) and aa.depid=@depid
  union all
  select c.btid, isnull(bb.sklad,0) [sklad], 4 [ord] 
  from #btn c
  left join warehouse.sklad_ngrp_forback bb on bb.backtype=c.btid and bb.ngrp=dbo.GetGrOnlyParent(@ngrp) and bb.depid=0
  ) x
  where x.sklad<>0
  
  update b set b.sklad=s.sklad
  from #btn b 
  join #skl s on s.btid=b.btid
  join (select btid, min(ord) [ord] from #skl group by btid) t on t.btid=s.btid and t.ord=s.ord
  
  select * from #btn order by ord
    
  if object_id('tempdb..#btn') is not null drop table #btn
  if object_id('tempdb..#skl') is not null drop table #skl
  set nocount off
END