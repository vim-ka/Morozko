CREATE PROCEDURE NearLogistic.Marsh2CalcFact @day0 datetime, @day1 datetime
AS
BEGIN
declare @minmhid int
declare @maxmhid int
begin try
set transaction isolation level read uncommitted
select @minmhid = min(mhid) from dbo.marsh where nd = convert(varchar, @day0, 104)
select @maxmhid = max(mhid) from dbo.marsh where nd = convert(varchar, @day1, 104)
print @minmhid
print @maxmhid

declare @DotsBasePlan int, @Dot2NetDot float, @isBonus bit 

select @DotsBasePlan=cast(Value as int)
from [NearLogistic].nlConfig
where Param='DotsBasePlan'

select @Dot2NetDot=cast(Value as float)
from [NearLogistic].nlConfig
where Param='Dot2NetDot'

create table #dnet(kol int, mhid INT)
insert into #dnet
select count(distinct iif(mr.PINFrom>0,mr.pinFrom,mr.Pinto)/*(case when isnull(d.vmaster,0)>0 then d.vmaster else d.pin end)*/), m.mhid

from nc c join NearLogistic.MarshRequests mr on mr.ReqID=c.DatNom and mr.ReqType=0
          join defcontract f on c.dck=f.dck
          --join def d on c.b_id=d.pin
          join agentlist a on f.ag_id=a.ag_id
          join marsh m on c.mhID = m.mhid  --c.nd=m.nd and c.marsh=m.marsh
where a.depid in (3,26)
      and m.mhid >= @minmhid 
      and m.mhid <= @maxmhid
group by m.mhid

/*
from nc c 
     inner join defcontract f on c.dck=f.dck
     inner join def d on c.b_id=d.pin
     inner join marsh m on c.nd=m.nd and c.marsh=m.marsh
     --INNER join agentlist a on f.ag_id=a.ag_id
where 
 --a.depid=3
--AND
*/

create table #dall(kol int, mhid int)                                   
insert into #dall
select count(distinct iif(m.PINFrom>0,m.pinFrom,m.Pinto)/* (case when isnull(d.vmaster,0)>0 then d.vmaster else d.pin end)*/), m.mhid 
from NearLogistic.MarshRequests m 
              --left join nc c on mr.ReqID=c.DatNom --and mr.ReqType=0
              --join def d on mr.PINTo=d.pin
              --join marsh m on mr.mhid=m.mhid
/*from nc c inner join defcontract f on c.dck=f.dck
	inner join def d on c.b_id=d.pin*/
    
where m.mhid >= @minmhid 
      and m.mhid <= @maxmhid
group by m.mhid

create table #smdrv(sm money, mhid int)
insert into #smdrv(sm, mhid)
select 
 cast(isnull(pd.Pay1Km*iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0))+
  pd.Pay1Dot*(case when isnull(#dall.kol, 0)-isnull(#dnet.kol, 0) > 25 then 25 else isnull(#dall.kol, 0)-isnull(#dnet.kol, 0) end)+
  pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
  pd.Pay1DotNet*iif(isnull(#dnet.kol, 0)>25,25,0)+
  pd.Pay1DotOver*(case when isnull(#dall.kol, 0) > 25 then isnull(#dall.kol, 0)-25 else 0 end)+
  pd.PayAllDot*(case when isnull(#dall.kol, 0)<25 then 1 else 0 end)+
  pd.PayAllDotOver*(case when isnull(#dall.kol, 0)>=25 then 1 else 0 end)+
  pd.Rate0Rank*iif(r.nlPersonalRank=0,1,0)+
  pd.Rate1Rank*iif(r.nlPersonalRank=1,1,0)+
  pd.Rate2Rank*iif(r.nlPersonalRank=2,1,0)+
  pd.Rate3Rank*iif(r.nlPersonalRank=3,1,0)+
  pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end),0)+
  pd.Bonus*(iif((isnull(#dnet.kol, 0)*@Dot2NetDot+(m.Dots-isnull(#dnet.kol, 0)) > @DotsBasePlan),1,0) )+
  isnull(h.expense,0)+
  iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0))*isnull(h.tariff1km,0) as varchar) as sm,
  m.mhid
from  
  Marsh m left join Drivers r on m.drId=r.drId
          left join vehicle h on m.v_id=h.v_id
          left join NearLogistic.nlTariffParams pd on pd.nlTariffParamsID=m.nlTariffParamsIDDrv 
          left join NearLogistic.nlTariffsDet d on pd.nlTariffParamsID=d.nlTariffParamsID
          left join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID                
          left join #dnet on #dnet.mhid = m.mhid
          left join #dall on #dall.mhid = m.mhid              

create table #smspd(sm money, mhid int)
insert into #smspd(sm, mhid)
select
  cast( pd.Pay1Km*iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0))+
  pd.Pay1Dot*(case when isnull(#dall.kol, 0)-isnull(#dnet.kol, 0) > 25 then 25 else isnull(#dall.kol, 0)-isnull(#dnet.kol, 0) end)+
  pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
  pd.Pay1DotNet*iif(isnull(#dnet.kol, 0)>25,25,0)+
  pd.Pay1DotOver*(case when isnull(#dall.kol, 0) > 25 then isnull(#dall.kol, 0)-25 else 0 end)+
  pd.PayAllDot*(case when isnull(#dall.kol, 0) < 25 then 1 else 0 end)+
  pd.PayAllDotOver*(case when isnull(#dall.kol, 0) >= 25 then 1 else 0 end)+
  pd.Rate0Rank*iif(r.nlPersonalRank=0,1,0)+
  pd.Rate1Rank*iif(r.nlPersonalRank=1,1,0)+
  pd.Rate2Rank*iif(r.nlPersonalRank=2,1,0)+
  pd.Rate3Rank*iif(r.nlPersonalRank=3,1,0)+
  pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end)+
  pd.Bonus*(iif((isnull(#dnet.kol, 0)*@Dot2NetDot+(m.Dots-isnull(#dnet.kol, 0)) > @DotsBasePlan),1,0)) as varchar) as sm,
  m.mhid
from  NearLogistic.nlTariffParams pd 
	  join NearLogistic.nlTariffsDet d on pd.nlTariffParamsID=d.nlTariffParamsID
      join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID,
      Marsh m left join Drivers r on m.SpedDrID=r.drID
	  left join #dnet on #dnet.mhid = m.mhid
      left join #dall on #dall.mhid = m.mhid      
where pd.nlTariffParamsID = m.nlTariffParamsIDSpd  

truncate table dbo.Marsh2CalcFact
insert into dbo.Marsh2CalcFact(sm, mhid)
select isnull(#smdrv.sm, 0) + isnull(#smspd.sm, 0) + isnull(nlpd.bonus, 0), #smdrv.mhid 
--select isnull(#smdrv.sm, 0) + isnull(#smspd.sm, 0), #smdrv.mhid 
from #smdrv
left join #smspd on #smspd.mhid = #smdrv.mhid
left join NearLogistic.nlListPayDet nlpd on nlpd.mhid = #smdrv.mhid
where isnull(#smdrv.sm, 0) + isnull(#smspd.sm, 0) > 0 

drop table #dnet
drop table #dall
drop table #smdrv
drop table #smspd

 end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
  end catch

END