CREATE PROCEDURE [NearLogistic].PrintWayList @mhid int
AS
BEGIN
set nocount off
declare @ND datetime
declare @isToday bit

set @ND=(select ND from marsh where mhid=@mhid)
if @ND=dbo.today() set @isToday=1 else set @isToday=0

if object_id('tempdb..#defDots') is not null drop table #defDots

select top 5 * 
into #defDots
from (
select rank() OVER (ORDER BY d.gpAddr) as rank, 
    d.gpAddr, 
       mr.mhid 
       from def d 
join [NearLogistic].MarshRequests mr on d.pin=mr.pinto and mr.mhid=@mhid) x

select top 1
      v.V_id,
        V.model,
        V.regNom,
        Cr.crName,
        Cr.UrArrd,
        Cr.Phone,
        Dr.Fio,
        Dr.DriverDoc,
        m.ND,
        m.Marsh,
        IsNull(N.Cnt,0) as Cnt,
        iif(@isToday=1,null, m.Dist) as Dist,
        iif(@isToday=1,null, Round(m.weight/1000,3)) as weight,
        iif(@isToday=1,null, m.km0) as km0,
        iif(@isToday=1,null, m.km1) as km1,
        iif(@isToday=1,null,dbo.InTime(m.TimeBack-m.TimeGo)) as  TmWork,
        REPLICATE('0', 3-len(cast(m.Marsh as varchar)))+cast(m.Marsh as varchar)+format(m.nd,'ddMMyy')  as CalcNom,
        '' as DateGo,
        '' as DateBack,        
        t1.gpAddr  as addr1,
        t2.gpAddr  as addr2,
        t3.gpAddr  as addr3,
        t4.gpAddr  as addr4,
        t5.gpAddr  as addr5
from Marsh m 
left join Vehicle v on v.V_id=m.V_Id
left join Carriers Cr on Cr.CrID=v.CrId
left join Drivers Dr on Dr.DrId=m.drId
left join (select mr.mhid, count(mr.PINTo) as Cnt from [NearLogistic].MarshRequests mr group by mr.mhid) n on m.mhid=n.mhid
left join #defDots t1 on m.mhid=t1.mhid and t1.rank=1
left join #defDots t2 on m.mhid=t2.mhid and t2.rank=2
left join #defDots t3 on m.mhid=t3.mhid and t3.rank=3
left join #defDots t4 on m.mhid=t4.mhid and t4.rank=4
left join #defDots t5 on m.mhid=t5.mhid and t5.rank=5                      
where m.mhid=@mhid 

if object_id('tempdb..#defDots') is not null drop table #defDots
set nocount on
END