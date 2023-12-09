CREATE FUNCTION db_FarLogistic.PeriodDayCount (@isDrv bit, @MarshStart int, @MarshEnd int, @ID int)
RETURNS int
AS
BEGIN
declare @res int
declare @t table (dt datetime)
declare @FromDate datetime
declare @ToDate datetime
declare curMarsh cursor for
select 	m.dt_beg_fact,
				m.dt_end_fact
from db_FarLogistic.dlMarsh m
where right(year(m.dt_beg_fact),2)*100+month(m.dt_beg_fact)>=@MarshStart
			and right(year(m.dt_end_fact),2)*100+month(m.dt_end_fact)<=@MarshEnd
			and m.IDdlMarshStatus=4
			and exists(select * from db_FarLogistic.dlGroupBill g where g.MarshID=m.dlMarshID)
			and m.IDdlDrivers=case when @isDrv=1 then @ID else m.IDdlDrivers end
			and m.IDdlVehicles=case when @isDrv=1 then m.IDdlVehicles else @ID end
order by 1	    
open curMarsh 	    
fetch next from curMarsh into @FromDate, @ToDate	    
while @@FETCH_STATUS=0 
begin
	with Days(D) AS
	(
	 select @FromDate where @FromDate <= @ToDate
	 union all
	 select dateadd(day,1,D) from Days where D < @ToDate
	)	      
	insert into @t
	select D
	from Days
	fetch next from curMarsh into @FromDate, @ToDate
end	    
close curMarsh
deallocate curMarsh
select @res=count(*)
from (
 			select distinct * from @t
 			) a
return @res
END