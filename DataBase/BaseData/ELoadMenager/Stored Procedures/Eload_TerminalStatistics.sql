CREATE PROCEDURE ELoadMenager.Eload_TerminalStatistics
@nd1 datetime, 
@nd2 datetime
AS
BEGIN
select right(comp,9) [Терминал],
       cast(iif(z.tmEnd>='09:00:00' and z.tmEnd<'21:00:00',1,0) as bit) [Смена],
			 iif(cast(iif(z.tmEnd>='09:00:00' and z.tmEnd<'21:00:00',1,0) as bit)=0 and z.tmEnd<'00:00:00',dateadd(day,-1,z.dtEnd),z.dtEnd) [День],
			 count(distinct z.datnom) [Накладные],
       count(z.nzid) [Строки],
       sum(iif(n.flgweight=1,z.curweight,n.netto*z.zakaz)) [Масса]
from dbo.nvzakaz z
join dbo.nomen n on n.hitag=z.hitag
where z.dtEnd between @nd1 and @nd2
			and z.id>0 and right(comp,9) like '%terminal%'
group by cast(iif(z.tmEnd>='09:00:00' and z.tmEnd<'21:00:00',1,0) as bit), 
				 iif(cast(iif(z.tmEnd>='09:00:00' and z.tmEnd<'21:00:00',1,0) as bit)=0 and z.tmEnd<'00:00:00',dateadd(day,-1,z.dtEnd),z.dtEnd),
         right(comp,9)
order by 3,2,1
END