create procedure PeriodRep1agent @day0 datetime, @day1 datetime, @ag_id int
as begin
	select YEAR(nd) as year, datepart(wk,nd) as Week,
	  sum(isnull(sp,0)) sp,
	  sum(isnull(sp,0)-isnull(sc,0)) as Dohod,
	  sum(isnull(Weight,0)) Weight
	from nc
	where
	  nd between @day0 and @day1
	  and ag_id=@ag_id
	group by YEAR(nd),datepart(wk,nd)
	order by YEAR(nd),datepart(wk,nd)
END