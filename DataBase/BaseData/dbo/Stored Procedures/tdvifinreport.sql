CREATE procedure dbo.tdvifinreport
@safecust bit,
@typegroup int,
@period varchar(2000),
@gr varchar(2000),
@ncods varchar(2000),
@nd datetime 
as
begin
declare @id int, @s int, @e int, @sql varchar(3000)

if object_id('tempdb..#tdvi_') is not null drop table #tdvi_
if object_id('tmpdb.dbo.#tmpncods') is not null drop table #tmpncods
if object_id('tmpdb.dbo.#tmphitag') is not null drop table #tmphitag
if object_id('tmpdb.dbo.#tmpperiod') is not null drop table #tmpperiod
if object_id('tmpdb.dbo.#curbalance') is not null	drop table #curbalance
if object_id('tmpdb.dbo.#tmpgr') is not null drop table #tmpgr

create table #tdvi_ (nd datetime, datepost datetime, sklad int, hitag int, ncod int, safecust bit,
                     ncom int, morn int, sell int, isprav int, remov int, cost money, price money,
                     [weight] money, owner_id int, ngrp int, flgweight bit)
create table #tmpncods(id int)                     
create table #tmpgr(id int)
create table #tmphitag(id int)
create table #tmpperiod(id int identity ,s int, e int)
create table #curbalance (id int, grname varchar(100),owner_id int)

if datediff(day,@nd,getdate())=0
	insert into [#tdvi_]
  select nd, datepost, sklad, t.hitag, ncod, t.safecust, ncom, morn, sell, isprav, remov,
         iif(n.flgweight=1,1,(morn-sell+isprav-remov))*t.cost, iif(n.flgweight=1,1,(morn-sell+isprav-remov))*t.price, iif(n.flgweight=1,[weight],n.brutto)*(morn-sell-isprav-remov),
         iif(isnull(t.our_id,0)=0,7,t.our_id), dbo.getgronlyparent(n.ngrp), n.flgweight
  from dbo.tdvi t
  join dbo.nomen n on n.hitag=t.hitag
  join dbo.gr g on g.ngrp=n.ngrp and g.AgInvis=0
else
	insert into [#tdvi_]
  select a.datepost, a.datepost, a.sklad, a.hitag, a.ncod, 
  			 (select iif(dc.contrtip=6,cast(1 as bit),cast(0 as bit)) from dbo.defcontract dc where dc.dck=a.dck),
         a.ncom, a.eveningrest, 0, 0, 0, a.eveningrest*a.cost, a.eveningrest*a.price, iif(n.flgweight=1,[weight],n.brutto)*(eveningrest),
         iif(isnull(a.our_id,0)=0,7,a.our_id), dbo.getgronlyparent(n.ngrp), n.flgweight
  from morozarc.dbo.arcvi a
  join dbo.nomen n on n.hitag=a.hitag
  join dbo.gr g on g.ngrp=n.ngrp and g.AgInvis=0
  where a.workdate=@nd

delete from #tdvi_ where safecust<>@safecust  

if isnull(@ncods,'')<>'' insert into #tmpncods select value from string_split(@ncods,',')	
else insert into #tmpncods select distinct ncod from [#tdvi_]

if isnull(@gr,'')<>'' insert into #tmpgr select value from string_split(@gr,',')
else insert into #tmpgr select distinct ngrp from [#tdvi_]

insert into #tmphitag select distinct hitag from [#tdvi_]

set @period='select '+replace(@period,',',' union all select ')
set @period=replace(@period,'-',',')
set @period='insert into #tmpperiod(s,e) '+@period
exec(@period)

insert into #tmpperiod(s,e) 
values((select max(e)+1 from #tmpperiod),(select max(datediff(day,t.nd,getdate())) from [#tdvi_] t where t.safecust=@safecust))

set identity_insert #tmpperiod on 
insert into #tmpperiod(id,s,e) 
values(0,0,(select max(e) from #tmpperiod))
set identity_insert #tmpperiod off

if @typegroup=0
begin
	insert into #curbalance (id, grname,owner_id)
	select y.ngrp, y.grpname, x.owner_id 
  from (select distinct ngrp, owner_id from [#tdvi_]) x
  join dbo.gr y on x.ngrp=y.ngrp
end

if @typegroup=1
begin
	insert into #curbalance (id, grname,owner_id)
	select distinct t.ncod, d.brname, t.owner_id
	from [#tdvi_] t
	left join dbo.def d on d.ncod=t.ncod and t.ncod>0
	where t.ncom in (select ncom from dbo.comman where safecust=@safecust)
				and exists(select * from #tmphitag where id=t.hitag)
				and exists(select * from #tmpncods where #tmpncods.id=t.ncod)
																															
end

if @typegroup=2
begin
	insert into #curbalance (id, grname, owner_id)
	select distinct t.hitag, n.name, t.owner_id
	from [#tdvi_] t
	join dbo.nomen n on n.hitag=t.hitag
	where t.ncom in (select ncom from dbo.comman where safecust=@safecust)
				and exists(select * from #tmphitag where id=t.hitag)
				and exists(select * from #tmpncods where #tmpncods.id=t.ncod)
end

declare curperiod cursor for
select * from #tmpperiod order by id
open curperiod
fetch next from curperiod into @id, @s, @e 

while @@fetch_status=0
begin
	set @sql=''
	set @sql='alter table #curbalance add cost'+cast(@id as varchar)+' money default 0 not null,'+
																			' price'+cast(@id as varchar)+' money default 0 not null,'+
																			' weight'+cast(@id as varchar)+' float default 0 not null'
	exec(@sql)
	/*########################начало группировки по категориям###########################################################################*/
	if @typegroup=0
	begin
  	set @sql='
      update x set x.cost'+cast(@id as varchar)+'=isnull(z.sm,0)
      from #curbalance x
      join (select ngrp, owner_id, sum(cost) [sm]
            from #tdvi_ where abs(datediff(day,datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+' 
            group by ngrp, owner_id) z on z.owner_id=x.owner_id and z.ngrp=x.id'  
		print @sql
    exec(@sql)
		
    set @sql='
      update x set x.price'+cast(@id as varchar)+'=isnull(z.sm,0)
      from #curbalance x
      join (select ngrp, owner_id, sum(price) [sm]
            from #tdvi_ where abs(datediff(day,datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+' 
            group by ngrp, owner_id) z on z.owner_id=x.owner_id and z.ngrp=x.id'
		exec(@sql)
		
    set @sql='
      update x set x.weight'+cast(@id as varchar)+'=isnull(z.sm,0)
      from #curbalance x
      join (select ngrp, owner_id, sum(weight) [sm]
            from #tdvi_ where abs(datediff(day,datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+' 
            group by ngrp, owner_id) z on z.owner_id=x.owner_id and z.ngrp=x.id'
		exec(@sql)
	end
	/*########################конец группировки по категориям###########################################################################*/

	/*########################начало группировки по поставщикам###########################################################################*/
	if @typegroup=1
	begin
		set @sql='
      update x set x.cost'+cast(@id as varchar)+'=isnull(z.sm,0)
      from #curbalance x
      join (select ncod, owner_id, sum(cost) [sm]
            from #tdvi_ where abs(datediff(day,datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+' 
            group by ncod, owner_id) z on z.owner_id=x.owner_id and z.ncod=x.id'  
		exec(@sql)
    
    set @sql='
      update x set x.price'+cast(@id as varchar)+'=isnull(z.sm,0)
      from #curbalance x
      join (select ncod, owner_id, sum(price) [sm]
            from #tdvi_ where abs(datediff(day,datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+' 
            group by ncod, owner_id) z on z.owner_id=x.owner_id and z.ncod=x.id'  
		exec(@sql)
    
    set @sql='
      update x set x.weight'+cast(@id as varchar)+'=isnull(z.sm,0)
      from #curbalance x
      join (select ncod, owner_id, sum(weight) [sm]
            from #tdvi_ where abs(datediff(day,datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+' 
            group by ncod, owner_id) z on z.owner_id=x.owner_id and z.ncod=x.id'  
		exec(@sql)
	end
	/*########################конец группировки по поставщикам###########################################################################*/

	/*########################начало группировки по номенклатуре###########################################################################*/
	if @typegroup=2
	begin
		set @sql='
      update x set x.cost'+cast(@id as varchar)+'=isnull(z.sm,0)
      from #curbalance x
      join (select hitag, owner_id, sum(cost) [sm]
            from #tdvi_ where abs(datediff(day,datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+' 
            group by hitag, owner_id) z on z.owner_id=x.owner_id and z.hitag=x.id'  
		exec(@sql)
    
    set @sql='
      update x set x.price'+cast(@id as varchar)+'=isnull(z.sm,0)
      from #curbalance x
      join (select hitag, owner_id, sum(price) [sm]
            from #tdvi_ where abs(datediff(day,datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+' 
            group by hitag, owner_id) z on z.owner_id=x.owner_id and z.hitag=x.id'  
		exec(@sql)
    
    set @sql='
      update x set x.weight'+cast(@id as varchar)+'=isnull(z.sm,0)
      from #curbalance x
      join (select hitag, owner_id, sum(weight) [sm]
            from #tdvi_ where abs(datediff(day,datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+' 
            group by hitag, owner_id) z on z.owner_id=x.owner_id and z.hitag=x.id'  
		exec(@sql)
	end
	/*########################конец группировки по номенклатуре###########################################################################*/
	fetch next from curperiod into @id, @s, @e 
end

close curperiod
deallocate curperiod

select * from #curbalance

select * from #tmpperiod
select * from #tdvi_ 

select sum(cost0) from #curbalance where owner_id in (0,1,2,3,4,5,6,7,8,11,12,13,15,16,17,22)

if object_id('tempdb..#tdvi_') is not null drop table #tdvi_
if object_id('tmpdb.dbo.#tmpncods') is not null drop table #tmpncods
if object_id('tmpdb.dbo.#tmphitag') is not null drop table #tmphitag
if object_id('tmpdb.dbo.#tmpperiod') is not null drop table #tmpperiod
if object_id('tmpdb.dbo.#curbalance') is not null	drop table #curbalance
if object_id('tmpdb.dbo.#tmpgr') is not null drop table #tmpgr
end