CREATE PROCEDURE dbo.GetPriceDeltaForPeriod
@year varchar(100)='2014',
@month varchar(100)='1,2,3,4,5,6,7,8,9,10,11,12'	
AS
BEGIN
  create table #tmpM (i int)
	create table #tmpY (j int)
	declare @tmp varchar(700)
	set @tmp=replace(@month,',',' union all select ')
	set @tmp='insert into #tmpM select '+@tmp	
	exec(@tmp)

	set @tmp=replace(@year,',',' union all select ')
	set @tmp='insert into #tmpY select '+@tmp	
	exec(@tmp)


	select *
	from (
	select 	x.*,
					cast((x.[sum]/x.[cnt]) as decimal(10,2)) as [avg],
					cast((x.[sum]/x.[cnt]-x.[fst]) as decimal(10,2)) as [avg-fst]
	from (
	select 	c.[date] [nd],
					c.Ncom,
					i.hitag,
					n.flgWeight,
					i.weight,
					case when (n.flgWeight=1)and(i.weight<>0) then i.price/i.weight else i.price end [price],
					
					(select sum(case when (sn.flgWeight=1)and(si.weight<>0) then si.price/si.weight else si.price end)
					from inpdet si
					join comman sc on sc.ncom=si.ncom
					join nomen sn on si.hitag=sn.hitag
					where year(sc.[date]) in (select * from #tmpY)
								and month(sc.[date]) in (select * from #tmpM) 
								and si.hitag=i.hitag) [sum],
					
					(select count(*)
					from inpdet ci
					join comman cc on cc.ncom=ci.ncom
					where year(cc.[date]) in (select * from #tmpY)
								and month(cc.[date]) in (select * from #tmpM)
								and ci.hitag=i.hitag) [cnt],
					
					(select top 1 case when (fn.flgWeight=1)and(fsi.weight<>0) then fsi.price/fsi.weight else fsi.price end
					from inpdet fsi
					join comman fc on fc.ncom=fsi.ncom
					join nomen fn on fsi.hitag=fn.hitag
					where year(fc.[date]) in (select * from #tmpY)
								and month(fc.[date]) in (select * from #tmpM)
								and fsi.hitag=i.hitag
					order by fc.[date]) [fst]
	from inpdet i
	join comman c on c.ncom=i.ncom
	join nomen n on n.hitag=i.hitag
	where year(c.[date]) in (select * from #tmpY)
				and month(c.[date]) in (select * from #tmpM)
				and c.summacost>0
				and c.summaprice>0 
				and n.ngrp in (select ngrp from gr where aginvis=0)) x )y
	where y.[avg-fst]<>0    
	order by y.[hitag]

	drop table #tmpM 
	drop table #tmpY 
END