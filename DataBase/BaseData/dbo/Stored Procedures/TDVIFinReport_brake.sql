CREATE PROCEDURE dbo.TDVIFinReport_brake
@safecust bit,
@typeGroup int,
@period varchar(5000),
@gr varchar(5000),
@ncods varchar(5000),
@nd datetime,
@delta decimal(10,4) = 1.0
AS
BEGIN
declare @sql varchar(3000)

if object_id('tempdb..#tdvi_') is not null
	drop table [#tdvi_]
  
create table [#tdvi_] ( nd datetime,
                       datepost datetime,
                       sklad int,
                       hitag int,
                       ncod int,
                       safecust bit,
                       ncom int,
                       morn int,
                       sell int,
                       isprav int,
                       remov int,
                       cost money,
                       price money,
                       [weight] money)
  
if datediff(day,@nd,getdate())=0
	insert into [#tdvi_]
  select nd,
         datepost,
         sklad,
         hitag,
         ncod,
         safecust,
         ncom,
         morn,
         sell,
         isprav,
         remov,
         cost,
         price,
         [weight]
  from tdvi
else
	insert into [#tdvi_]
  select a.DatePost,
         a.DatePost,
         a.Sklad,
         a.Hitag,
         a.Ncod,
         (select iif(dc.ContrTip=6,cast(1 as bit),cast(0 as bit)) from DefContract dc where dc.dck=a.dck),
         a.Ncom,
         a.EveningRest,
         0,
         0,
         0,
         a.Cost,
         a.Price,
         a.Weight
  from MorozArc.dbo.ArcVI a
  where a.WorkDate=@nd

create nonclustered index idx_tdvi_1 on [#tdvi_](ncod)
create nonclustered index idx_tdvi_2 on [#tdvi_](ncom)
create nonclustered index idx_tdvi_3 on [#tdvi_](hitag)
create nonclustered index idx_tdvi_4 on [#tdvi_](nd)
create nonclustered index idx_tdvi_5 on [#tdvi_](datepost)
create nonclustered index idx_tdvi_6 on [#tdvi_](sklad)

if object_id('tmpdb.dbo.#tmpNCODS') is not null 
	drop table #tmpNCODS
create table #tmpNCODS(id int)
if isnull(@ncods,'')<>''
begin
	set @ncods='select '+replace(@ncods,',',' union all select ')
	set @ncods='insert into #tmpNCODS '+@ncods
	exec(@ncods)
end
else
begin
	insert into #tmpNCODS
	select distinct ncod
	from [#tdvi_]
end

if object_id('tmpdb.dbo.#tmpGR') is not null 
	drop table #tmpGR
create table #tmpGR(id int)
if isnull(@gr,'')<>''
begin
	set @gr='select '+replace(@gr,',',' union all select ')
	set @gr='insert into #tmpGR '+@gr
	exec(@gr)
end
else
begin
	insert into #tmpGR
	select Ngrp
	from gr 
	where Levl=0 
				and AgInvis=0
end

if object_id('tmpdb.dbo.#tmpHitag') is not null 
	drop table #tmpHitag
create table #tmpHitag(id int)
insert into #tmpHitag
select hitag 
from nomen 
where ngrp in (select ngrp from gr where mainparent in (select id from #tmpGR)) 

if object_id('tmpdb.dbo.#tmpPeriod') is not null 
	drop table #tmpPeriod
create table #tmpPeriod(id int identity ,s int, e int)
set @period='select '+replace(@period,',',' union all select ')
set @period=replace(@period,'-',',')
set @period='insert into #tmpPeriod(s,e) '+@period
exec(@period)

insert into #tmpPeriod(s,e) 
values((select max(e)+1 from #tmpPeriod),(select max(datediff(day,t.nd,getdate())) from [#tdvi_] t where t.safeCust=iif(@safecust=0,t.safeCust,@safecust)))

set identity_insert #tmpPeriod on 
insert into #tmpPeriod(id,s,e) 
values(0,0/*(select min(s) from #tmpPeriod)*/,(select max(e) from #tmpPeriod))
set identity_insert #tmpPeriod off

if object_id('tmpdb.dbo.#curBalance') is not null
	drop table #curBalance

create table #curBalance (id int, GrName varchar(100))

if @typeGroup=0
begin
	insert into #curBalance (id, GrName)
	select Ngrp, GrpName 
	from gr 
	where ngrp in (select ID from #tmpGR)
end
if @typeGroup=1
begin
	insert into #curBalance (id, GrName)
	select distinct t.ncod, d.brName
	from [#tdvi_] t
	join def d on d.ncod=t.ncod
	where t.ncom in (select ncom from comman where safeCust=iif(@safecust=0,t.safeCust,@safecust))
				and exists(select * from #tmpHitag where id=t.hitag)
				and exists(select * from #tmpNCODS where #tmpNCODS.id=t.ncod)
        and t.morn-t.sell+t.isprav-t.remov>0
        and t.sklad<90
																															
end
if @typeGroup=2
begin
	insert into #curBalance (id, GrName)
	select distinct t.hitag, n.name
	from [#tdvi_] t
	join nomen n on n.hitag=t.hitag
	where t.ncom in (select ncom from comman where safeCust=iif(@safecust=0,t.safeCust,@safecust))
				and exists(select * from #tmpHitag where id=t.hitag)
				and exists(select * from #tmpNCODS where #tmpNCODS.id=t.ncod)
        and t.morn-t.sell+t.isprav-t.remov>0
        and t.sklad<90
end

declare @id int
declare @s int
declare @e int
declare curPeriod cursor for
select * from #tmpPeriod order by id

open curPeriod

fetch next from curPeriod into @id, @s, @e 

while @@fetch_status=0
begin
	set @sql=''
	set @sql='alter table #curBalance add cost'+cast(@id as varchar)+' money default 0 not null,'+
																			' price'+cast(@id as varchar)+' money default 0 not null,'+
																			' weight'+cast(@id as varchar)+' float default 0 not null'
	exec(@sql)
	/*########################НАЧАЛО ГРУППИРОВКИ ПО КАТЕГОРИЯМ###########################################################################*/
	if @typeGroup=0
	begin
		set @sql=''
		set @sql='update #curBalance set '
		set @sql=@sql+' cost'+cast(@id as varchar)+'=isnull((select sum((v.morn-v.sell+v.isprav-v.remov)*v.cost)'+
																											 ' from [#tdvi_] v'+
																											 ' left join nomen n on n.hitag=v.hitag'+
																											 ' where (abs(datediff(day,v.datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+')'+
																											 				' and v.ncom in (select ncom from comman where safeCust='+iif(@safecust=0,'safeCust',cast(@safecust as varchar))+')'+
																															' and v.sklad<90'+
                                                              ' and v.morn-v.sell+v.isprav-v.remov>0'+
																															' and exists(select * from #tmpNCODS where #tmpNCODS.id=v.ncod)'+
																															' and v.hitag in (select hitag '+
																											 										' from nomen '+
																																					' where ngrp in (select ngrp from gr where gr.mainparent=#curBalance.id))'
																								+'),0)'
		exec(@sql)
		
		set @sql=''
		set @sql='update #curBalance set '
		set @sql=@sql+' price'+cast(@id as varchar)+'=isnull((select sum((v.morn-v.sell+v.isprav-v.remov)*v.price)'+
																											 ' from [#tdvi_] v'+
																											 ' left join nomen n on n.hitag=v.hitag'+
																											 ' where (abs(datediff(day,v.datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+')'+
																											 				' and v.ncom in (select ncom from comman where safeCust='+iif(@safecust=0,'safeCust',cast(@safecust as varchar))+')'+
																															' and v.sklad<90'+
                                                              ' and v.morn-v.sell+v.isprav-v.remov>0'+
																															' and exists(select * from #tmpNCODS where #tmpNCODS.id=v.ncod)'+
																															' and v.hitag in (select hitag '+
																											 										' from nomen '+
																																					' where ngrp in (select ngrp from gr where gr.mainparent=#curBalance.id))'
																								+'),0)'
		exec(@sql)
		
		set @sql=''
		set @sql='update #curBalance set '
		set @sql=@sql+' weight'+cast(@id as varchar)+'=isnull((select sum(case when n.flgWeight=1 then v.weight else (v.morn-v.sell+v.isprav-v.remov)*n.Netto end)'+
																											 ' from [#tdvi_] v'+
																											 ' left join nomen n on n.hitag=v.hitag'+
																											 ' where (abs(datediff(day,v.datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+')'+
																											 				' and v.ncom in (select ncom from comman where safeCust='+iif(@safecust=0,'safeCust',cast(@safecust as varchar))+')'+
																															' and v.sklad<90'+
                                                              ' and v.morn-v.sell+v.isprav-v.remov>0'+
																															' and exists(select * from #tmpNCODS where #tmpNCODS.id=v.ncod)'+
																															' and v.hitag in (select hitag '+
																											 										' from nomen '+
																																					' where ngrp in (select ngrp from gr where gr.mainparent=#curBalance.id))'
																								+'),0)'
		exec(@sql)
	end
	/*########################КОНЕЦ ГРУППИРОВКИ ПО КАТЕГОРИЯМ###########################################################################*/

	/*########################НАЧАЛО ГРУППИРОВКИ ПО ПОСТАВЩИКАМ###########################################################################*/
	if @typeGroup=1
	begin
		set @sql=''
		set @sql='update #curBalance set '
		set @sql=@sql+' price'+cast(@id as varchar)+'=isnull((select sum((v.morn-v.sell+v.isprav-v.remov)*v.price)'+
																											 ' from [#tdvi_] v'+
																											 ' where (abs(datediff(day,v.datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+')'+
																											 				' and v.ncom in (select ncom from comman where safeCust='+iif(@safecust=0,'safeCust',cast(@safecust as varchar))+')'+
																															' and v.sklad<90'+
																															' and v.ncod=#curBalance.id '+
																															' and exists(select * from #tmpNCODS where #tmpNCODS.id=v.ncod)'+
																															' and exists(select * from #tmpHitag where id=v.hitag)'+
                                                              ' and v.morn-v.sell+v.isprav-v.remov>0'+
																								+'),0)'
		exec(@sql)
		
		set @sql=''
		set @sql='update #curBalance set '
		set @sql=@sql+' cost'+cast(@id as varchar)+'=isnull((select sum((v.morn-v.sell+v.isprav-v.remov)*v.cost)'+
																											 ' from [#tdvi_] v'+
																											 ' where (abs(datediff(day,v.datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+')'+
																											 				' and v.ncom in (select ncom from comman where safeCust='+iif(@safecust=0,'safeCust',cast(@safecust as varchar))+')'+
																															' and v.sklad<90'+
																															' and v.ncod=#curBalance.id '+
																															' and exists(select * from #tmpNCODS where #tmpNCODS.id=v.ncod)'+
																															' and exists(select * from #tmpHitag where id=v.hitag)'+
                                                              ' and v.morn-v.sell+v.isprav-v.remov>0'+
																								+'),0)'
		exec(@sql)
		
		set @sql=''
		set @sql='update #curBalance set '
		set @sql=@sql+' weight'+cast(@id as varchar)+'=isnull((select sum(case when n.flgWeight=1 then v.weight else (v.morn-v.sell+v.isprav-v.remov)*n.Netto end)'+
																											 ' from [#tdvi_] v'+
																											 ' left join nomen n on n.hitag=v.hitag'+
																											 ' where (abs(datediff(day,v.datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+')'+
																											 				' and v.ncom in (select ncom from comman where safeCust='+iif(@safecust=0,'safeCust',cast(@safecust as varchar))+')'+
																															' and v.sklad<90'+
																															' and exists(select * from #tmpNCODS where #tmpNCODS.id=v.ncod)'+
																															' and v.ncod=#curBalance.id '+
																															' and exists(select * from #tmpHitag where id=v.hitag)'+
                                                              ' and v.morn-v.sell+v.isprav-v.remov>0'+
																								+'),0)'
		exec(@sql)
	end
	/*########################КОНЕЦ ГРУППИРОВКИ ПО ПОСТАВЩИКАМ###########################################################################*/

	/*########################НАЧАЛО ГРУППИРОВКИ ПО НОМЕНКЛАТУРЕ###########################################################################*/
	if @typeGroup=2
	begin
		set @sql=''
		set @sql='update #curBalance set '
		set @sql=@sql+' price'+cast(@id as varchar)+'=isnull((select sum((v.morn-v.sell+v.isprav-v.remov)*v.price)'+
																											 ' from [#tdvi_] v'+
																											 ' where (abs(datediff(day,v.datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+')'+
																											 				' and v.ncom in (select ncom from comman where safeCust='+iif(@safecust=0,'safeCust',cast(@safecust as varchar))+')'+
																															' and v.sklad<90'+
																															' and exists(select * from #tmpNCODS where #tmpNCODS.id=v.ncod)'+
																															' and v.hitag=#curBalance.id '+
																															' and exists(select * from #tmpHitag where id=v.hitag)'+
                                                              ' and v.morn-v.sell+v.isprav-v.remov>0'+
																								+'),0)'
		exec(@sql)
		
		set @sql=''
		set @sql='update #curBalance set '
		set @sql=@sql+' cost'+cast(@id as varchar)+'=isnull((select sum((v.morn-v.sell+v.isprav-v.remov)*v.cost)'+
																											 ' from [#tdvi_] v'+
																											 ' where (abs(datediff(day,v.datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+')'+
																											 				' and v.ncom in (select ncom from comman where safeCust='+iif(@safecust=0,'safeCust',cast(@safecust as varchar))+')'+
																															' and v.sklad<90'+
																															' and exists(select * from #tmpNCODS where #tmpNCODS.id=v.ncod)'+
																															' and v.hitag=#curBalance.id '+
																															' and exists(select * from #tmpHitag where id=v.hitag)'+
                                                              ' and v.morn-v.sell+v.isprav-v.remov>0'+
																								+'),0)'
		exec(@sql)
		
		set @sql=''
		set @sql='update #curBalance set '
		set @sql=@sql+' weight'+cast(@id as varchar)+'=isnull((select sum(case when n.flgWeight=1 then v.weight else (v.morn-v.sell+v.isprav-v.remov)*n.Netto end)'+
																											 ' from [#tdvi_] v'+
																											 ' left join nomen n on n.hitag=v.hitag'+
																											 ' where (abs(datediff(day,v.datepost,getdate())) between '+cast(@s as varchar)+' and '+cast(@e as varchar)+')'+
																											 				' and v.ncom in (select ncom from comman where safeCust='+iif(@safecust=0,'safeCust',cast(@safecust as varchar))+')'+
																															' and v.sklad<90'+
																															' and exists(select * from #tmpNCODS where #tmpNCODS.id=v.ncod)'+
																															' and v.hitag=#curBalance.id '+
																															' and exists(select * from #tmpHitag where id=v.hitag)'+
                                                              ' and v.morn-v.sell+v.isprav-v.remov>0'+
																								+'),0)'
		exec(@sql)
	end
	/*########################КОНЕЦ ГРУППИРОВКИ ПО НОМЕНКЛАТУРЕ###########################################################################*/
	--/*
  set @sql=''
  set @sql='update #curBalance set '
  set @sql=@sql+' weight'+cast(@id as varchar)+'=weight'+cast(@id as varchar)+'*'+cast(@delta as varchar)+','--'*1.55,'
  set @sql=@sql+' cost'+cast(@id as varchar)+'=price'+cast(@id as varchar)+'*'+cast(@delta as varchar)+','--'*1.55,'
  set @sql=@sql+' price'+cast(@id as varchar)+'=(price'+cast(@id as varchar)+'+(price'+cast(@id as varchar)+'-cost'+cast(@id as varchar)+'))*'+cast(@delta as varchar)--'))*1.55'
  --set @sql=@sql+' cost'+cast(@id as varchar)+'=iif(weight'+cast(@id as varchar)+'=0,0,(price'+cast(@id as varchar)+'/weight'+cast(@id as varchar)+'*1.55)*weight'+cast(@id as varchar)+'*1.55),'
	--set @sql=@sql+' price'+cast(@id as varchar)+'=iif(weight'+cast(@id as varchar)+'=0,0,(((price'+cast(@id as varchar)+'/weight'+cast(@id as varchar)+')-(cost'+cast(@id as varchar)+'/weight'+cast(@id as varchar)+')+(price'+cast(@id as varchar)+'/weight'+cast(@id as varchar)+'))*1.55)*weight'+cast(@id as varchar)+'*1.55)'
  print @sql
  exec(@sql)
  --*/
  
  fetch next from curPeriod into @id, @s, @e 
end

close curPeriod
deallocate curPeriod

select * from #curBalance
order by id
drop table #tmpPeriod
drop table #curBalance
drop table #tmpHitag
drop table #tmpGR
drop table #tmpNCODS
drop table [#tdvi_]
END