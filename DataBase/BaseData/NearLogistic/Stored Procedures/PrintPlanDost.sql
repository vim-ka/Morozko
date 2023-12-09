CREATE PROCEDURE [NearLogistic].PrintPlanDost 
@ND datetime, 
@Type bit
AS
BEGIN
if object_id('tempdb..#tmp') is not null drop table #tmp
if object_id('tempdb..#drv') is not null drop table #drv

select * into #drv from (
select m.drId,
    convert(varchar,dateadd(hour,6,m.timeback),108) [tmNext],
       row_number() over(partition by m.drid order by m.marsh) [x]
from dbo.marsh m
where m.nd=dateadd(day,-1,@nd)
    and m.drid>0) a
where a.x=1

select m.mhID,
    nd,
    marsh,
       left(cast(isnull(Direction,'')+' '+isnull(rs.RegName,'<..>') as varchar(500)),15) [direction],
       isnull(A.Fio,'') [DriverName],
       isnull(b.Fio,'') [SpedName],
       case
         when (TimeGo='0:00:00' or TimeGo is null) then '' else dbo.InDate(TimeGo)
       end 
       as DateGo,
       isnull(convert(varchar,timego,108),'')
       as TimeGo,
       case when len(TimePlan)=5 then left(timeplan,5)+':00'
           when len(timeplan)=7 then '0'+TimePlan
            when len(TimePlan)=8 then TimePlan
            else '' end [TimePlan],
       case when len(TimeStart)=5 then left(timestart,5)+':00'
           when len(TimeStart)=7 then '0'+TimeStart
            else '' end [TimeStart],
       case when len(TimeFinish)=5 then left(timeFinish,5)+':00'
           when len(timeFinish)=7 then '0'+TimeFinish
            else '' end [TimeFinish],
       case
         when (TimeBack='0:00:00' or TimeBack is null) then '' else dbo.InDate(TimeBack) 
       end as DateBack, 
       isnull(convert(varchar,timeback,108),'') as TimeBack,
       isnull(RatedArrivalTime,'') [RatedArrivalTime],
       isnull(NotifyDrvTime,'') [NotifyDrvTime],
       Dots,
       cast(left(isnull(#drv.tmNext,''),5) as varchar) [tmNext]
into #tmp 
from dbo.marsh m 
left join NearLogistic.GetRegsString(@nd) rs on rs.mhid=m.mhid
left join dbo.Drivers A on A.drId=m.drID
left join dbo.Drivers B on B.drId=m.SpedDrID
left join #drv on #drv.drid=m.drid
where nd=@nd 
   and not marsh in (0,99) 
      and SelfShip=0
   and Dots>0
select t.*,
    x.[rast],
       round(x.[weight],0) [weight],
       /*case when isnull(RatedArrivalTime,'')<>'' then RatedArrivalTime
          else case when TimeBack<>'00:00:00' and TimeBack<>'' and TimeBack<>'19991230' then TimeBack
               else case when TimeGo<>'00:00:00' and TimeGo<>'' then TimeGo
                     else case when TimeFinish<>'00:00:00' and TimeFinish<>'' then TimeFinish
                         else case when TimeStart<>'00:00:00' and TimeStart<>'' then TimeStart
                              else case when TimePlan<>'00:00:00' and TimePlan<>'' then TimePlan
                                   else '' end end end end end end */
       TimePlan [tm]
from #tmp t
left join (select mr.mhid, max(r.rast) [rast], sum(mr.Weight_) [weight] 
      from NearLogistic.MarshRequests mr 
            inner join dbo.def d on d.pin=mr.pinto 
            inner join dbo.regions r on r.Reg_ID=d.Reg_ID 
            inner join #tmp on #tmp.mhid=mr.mhid
            group by mr.mhID
            having sum(mr.Weight_)>0) x on x.mhID=t.mhID
order by [tm],iif(@type=1,row_number() over(order by x.rast desc), cast(marsh as int)) 
 
if object_id('tempdb..#tmp') is not null drop table #tmp
if object_id('tempdb..#drv') is not null drop table #drv
end