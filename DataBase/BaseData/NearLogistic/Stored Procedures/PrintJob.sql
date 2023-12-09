CREATE PROCEDURE NearLogistic.PrintJob
@mhID int
AS
BEGIN
declare @stat varchar(48)
if object_id('tempdb..#mh') is not null drop table #mh
set @stat='1) Проверить наличие всех документов по маршруту'
declare @drID int, @nd datetime
select @drID=drID, @nd=nd from dbo.marsh where mhid=@mhid
select mhid into #mh
from [dbo].marsh m 
where m.drID=@drID and m.nd<=@nd
      
select @stat+char(13)+char(10)+
isnull(
stuff((
select N' '+cast((row_number() over(order by m.nd desc) +1) as varchar)+') '+j.Task+' [ №'+cast(m.marsh as varchar)+' от '+convert(varchar,m.nd,104)+' ]'+char(13)+char(10) 
from dbo.MarshJob j
inner join [dbo].marsh m on m.mhid=j.mhid
inner join #mh on #mh.mhid=j.mhid
where j.Done=0 
for xml path(''), type).value('.','varchar(max)'),1,1,''),N' ') [job]

if object_id('tempdb..#mh') is not null drop table #mh
END