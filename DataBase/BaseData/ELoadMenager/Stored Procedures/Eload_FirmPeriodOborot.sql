CREATE PROCEDURE [ELoadMenager].Eload_FirmPeriodOborot
@dt1 datetime,
@dt2 datetime,
@our_id INT,
@isGroup BIT 
AS
BEGIN
set nocount on
declare @dt datetime

IF OBJECT_ID('tempdb..#res') IS NOT NULL DROP TABLE #res
IF OBJECT_ID('tempdb..#firms') IS NOT NULL DROP TABLE #firms

CREATE TABLE #firms (id INT)

IF @isGroup=1
  INSERT INTO #firms 
  SELECT fc.Our_id
  FROM morozdata.dbo.FirmsConfig fc WHERE fc.FirmGroup=@our_id
else
  INSERT INTO #firms VALUES(@our_id)
         
create table #res (id int identity(1,1) not null,
									 period varchar(20) not null,
                   dt datetime,
                   datnom1 int,
                   datnom2 int,
                   sPrice decimal(12,2) not null default 0,
                   sCost decimal(12,2) not null default 0,
                   sVal decimal(12,2) not null default 0)

set @dt=@dt1
while @dt<=@dt2
begin
	if not exists(select 1 from #res where month(dt)=month(@dt) and year(dt)=year(@dt))
  	insert into #res(dt,
    								 period,
                     datnom1,
                     datnom2) 
    values(@dt,
    			 datename(month,@dt)+' '+cast(year(@dt) as varchar),
           dbo.indatnom(0,@dt),
           dbo.indatnom(9999,iif(@dt2<eomonth(@dt),@dt2,eomonth(@dt))))
    
   set @dt=dateadd(day,1,@dt)
end

create nonclustered index idx_resdatnom1 on #res(datnom1)
create nonclustered index idx_resdatnom2 on #res(datnom2)
create nonclustered index idx_resdatnom1datnom2 on #res(datnom1,datnom2)

select datnom,sp,sc
into #tmpNC 
from nc c
INNER JOIN DefContract dc ON c.DCK = dc.DCK 
INNER JOIN #firms f ON ISNULL(dc.gpOur_ID,dc.Our_id)=f.id 
where c.Actn=0
      and not c.stip in (2,3,4)
      and c.datnom between dbo.indatnom(0,@dt1) and dbo.indatnom(9999,@dt2)
      
create nonclustered index idx_tmpNCdatnom on #tmpNC(datnom)

update #res set sPrice=ISNULL((select sum(c.sp)
											  from #tmpNC c 
											  where c.datnom between #res.datnom1 and #res.datnom2),0),
			 					sCost=ISNULL((select sum(c.sc)
											  from #tmpNC c 
											  where c.datnom between #res.datnom1 and #res.datnom2),0),
       					sVal=ISNULL((select sum(c.sp-c.sc)
											  from #tmpNC c 
											  where c.datnom between #res.datnom1 and #res.datnom2),0)

select period [Период],
			 sPrice [Выручка],
       sCost [Стоимость закупки],
       sVal [Валовая прибыль],
       cast(iif(sPrice=0,0,(sVal * 100.0 / sPrice)) as decimal(12,2)) [Процент наценки]
from #res
order by dt
drop table #tmpNC      
drop table #res
set nocount off
END