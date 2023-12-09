CREATE PROCEDURE NearLogistic.MarshCalc
  @mhID int, 
  @nlTariffParamsIDDrv int,
  @nlTariffParamsIDSpd int 
AS
BEGIN

declare @DotsNet int, @Dots int, @DotsOver25 int, @DotsBasePlan int, @Dot2NetDot float, @isBonus bit, @DurationHours decimal(7,2),--, @isNeed bit,
        @ttID int

/*set @isNeed=cast(iif(exists(select 1 from dbo.marsh m join nearlogistic.nltariffsdet d on d.nltariffparamsid=m.nltariffparamsiddrv
                              join nearlogistic.nltariffs t on t.nltariffsid=d.nltariffsid where m.mhid=@mhid and t.ttid in (2))
                       ,1,0) as bit)
*/
select @DotsBasePlan=cast(Value as int)
from [NearLogistic].nlConfig
where Param='DotsBasePlan'

select @Dot2NetDot=cast(Value as float)
from [NearLogistic].nlConfig
where Param='Dot2NetDot'

set @DotsNet = isnull((select count(distinct iif(mr.PINFrom>0,mr.pinFrom,mr.Pinto)  /*(case when isnull(d.vmaster,0)>0 then d.vmaster else d.pin end)*/) 
                       from nc c join
                                 NearLogistic.MarshRequests mr on mr.ReqID=c.DatNom and mr.ReqType=0
                                 join defcontract f on c.dck=f.dck
                                 join agentlist a on f.ag_id=a.ag_id
                                 --join def d on c.b_id=d.pin
                                 
                        where mr.mhid=@mhID and a.depid in (3,26)),0)
                                   
set @Dots = isnull((select count(distinct iif(mr.PINFrom>0,mr.pinFrom,mr.Pinto)/*(case when isnull(d.vmaster,0)>0 then d.vmaster else d.pin end)*/) 
                    from NearLogistic.MarshRequests mr join def d on mr.PINTo=d.pin
                    where mr.mhid=@mhID and mr.reqtype=0),0)
                    
set @dots = @dots + isnull((select count(distinct d.point_id) from nearlogistic.marshrequests_free f 
														join nearlogistic.marshrequestsdet d on f.mrfid=d.mrfid 
                            where f.mhid=@mhid and d.action_id=6),0)                    
            
set @DurationHours=isnull((select iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)) from dbo.Marsh m  where m.mhid=@mhID),0)            

set @ttid=(select t.ttid 
           from nearlogistic.nltariffParams p join nearlogistic.nltariffsdet d on d.nltariffparamsid=p.nltariffparamsid
                                             join nearlogistic.nltariffs t on t.nltariffsid=d.nltariffsid
           where p.nlTariffParamsID=@nlTariffParamsIDDrv)
            
if @DotsNet*@Dot2NetDot+(@Dots-@DotsNet) > @DotsBasePlan
set @isBonus=1 
else set @isBonus=0            

set @DotsOver25 = @Dots - 25               
if @DotsOver25<0 set @DotsOver25=0
set @DotsNet=iif(@DotsNet>25,25,@DotsNet)

if @ttid=2 set @Dots=[NearLogistic].[RoundToDecDown](@Dots);
               
select -1 as Num,'Трф вод' as Name,
  pd.Pay1Km,
  pd.Pay1Dot,
  pd.Pay1Kg,
  pd.Pay1Hour,
  pd.Pay1DotNet,
  pd.Pay1DotOver,
  pd.PayAllDot,
  pd.PayAllDotOver,
  pd.Rate0Rank,
  pd.Rate1Rank,
  pd.Rate2Rank,
  pd.Rate3Rank,
  pd.Trailer,
  pd.Bonus,
  '  водит=' as sm,
  0 as Peni
from  NearLogistic.nlTariffParams pd join NearLogistic.nlTariffsDet d on pd.nlTariffParamsID=d.nlTariffParamsID
                                     join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID
where pd.nlTariffParamsID=@nlTariffParamsIDDrv
         
union

select 1 as Num,'Итого' as Name,
  pd.Pay1Km*iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)),
  pd.Pay1Dot*iif(@Dots-@DotsNet-@DotsOver25 > 0, @Dots-@DotsNet-@DotsOver25, 0),
  pd.Pay1Kg*(m.[Weight]+m.dopWeight),
  pd.Pay1Hour*@DurationHours,
  pd.Pay1DotNet*@DotsNet,
  pd.Pay1DotOver*@DotsOver25,
  pd.PayAllDot*(case when @Dots<=25 then 1 else 0 end),
  --+pd.PayAllDot*(case when @Dots<=25 then 1 else 0 end)*iif(@isNeed=1,[NearLogistic].fnCrutch(@mhid,1,0),0),
  pd.PayAllDotOver*(case when @Dots>25 then 1 else 0 end),
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1,0),
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate1Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1,0),
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate2Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1,0),
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate3Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1,0),
  pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end),
  pd.Bonus*@isBonus,
  
  cast(pd.Pay1Km*iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0))+
  pd.Pay1Dot*iif(@Dots-@DotsNet-@DotsOver25 > 0, @Dots-@DotsNet-@DotsOver25, 0)+
  pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
  pd.Pay1Hour*@DurationHours+
  pd.Pay1DotNet*@DotsNet+
  pd.Pay1DotOver*@DotsOver25+
  pd.PayAllDot*(case when @Dots<=25 then 1 else 0 end)+
  pd.PayAllDotOver*(case when @Dots>25 then 1 else 0 end)-
  isnull(m.Peni,0)+
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1,0)+
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate1Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1,0)+
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate2Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1,0)+
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate3Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1,0)+
  pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end)+ 
  pd.Bonus*cast(@isBonus as int)
  --+pd.PayAllDot*(case when @Dots<=25 then 1 else 0 end)*iif(@isNeed=1,[NearLogistic].fnCrutch(@mhid,1,0),0) 
  as varchar)   
  as sm,
  m.Peni
from  NearLogistic.nlTariffParams pd  join NearLogistic.nlTariffsDet d on pd.nlTariffParamsID=d.nlTariffParamsID
                                      join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID,
      Marsh m left join Drivers r on m.drId=r.drId

              cross apply (select min(s.mhid) as DrvMhId from marsh s where s.nd=m.nd and s.drID=m.drId) ms 
where m.mhID=@mhID and  pd.nlTariffParamsID=@nlTariffParamsIDDrv
         
union

select 2 as Num,'Трф эксп' as Name,
  ps.Pay1Km,
  ps.Pay1Dot,
  ps.Pay1Kg,
  ps.Pay1Hour,
  ps.Pay1DotNet,
  ps.Pay1DotOver,
  ps.PayAllDot,
  ps.PayAllDotOver,
  ps.Rate0Rank,
  ps.Rate1Rank,
  ps.Rate2Rank,
  ps.Rate3Rank,
  ps.Trailer,
  ps.Bonus,
  '  эксп=' as sm,
  0 as Peni
from  NearLogistic.nlTariffParams ps join NearLogistic.nlTariffsDet d on ps.nlTariffParamsID=d.nlTariffParamsID
                                     join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID
where ps.nlTariffParamsID=@nlTariffParamsIDSpd

union 

select 3 as Num,'Итого' as Name,
  pd.Pay1Km*iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)),
  pd.Pay1Dot*iif(@Dots-@DotsNet-@DotsOver25 > 0, @Dots-@DotsNet-@DotsOver25, 0),
  pd.Pay1Kg*(m.[Weight]+m.dopWeight),
  pd.Pay1Hour*@DurationHours,
  pd.Pay1DotNet*@DotsNet,
  pd.Pay1DotOver*@DotsOver25,
  pd.PayAllDot*(case when @Dots<=25 then 1 else 0 end),
  pd.PayAllDotOver*(case when @Dots>25 then 1 else 0 end),
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.SpdMhID=m.mhID,1,0),
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate1Rank*iif(r.nlPersonalRank=1 and ms.SpdMhID=m.mhID,1,0),
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate2Rank*iif(r.nlPersonalRank=2 and ms.SpdMhID=m.mhID,1,0),
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate3Rank*iif(r.nlPersonalRank=3 and ms.SpdMhID=m.mhID,1,0),
  pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end),
  pd.Bonus*@isBonus,

  cast( pd.Pay1Km*iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0))+
  pd.Pay1Dot*iif(@Dots-@DotsNet-@DotsOver25 > 0, @Dots-@DotsNet-@DotsOver25, 0)+
  pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
  pd.Pay1Hour*@DurationHours+
  pd.Pay1DotNet*@DotsNet+
  pd.Pay1DotOver*@DotsOver25+
  pd.PayAllDot*(case when @Dots<=25 then 1 else 0 end)+
  pd.PayAllDotOver*(case when @Dots>25 then 1 else 0 end)+
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.SpdMhID=m.mhID,1,0)+
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate1Rank*iif(r.nlPersonalRank=1 and ms.SpdMhID=m.mhID,1,0)+
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate2Rank*iif(r.nlPersonalRank=2 and ms.SpdMhID=m.mhID,1,0)+
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate3Rank*iif(r.nlPersonalRank=3 and ms.SpdMhID=m.mhID,1,0)+
  pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end)+
  pd.Bonus*cast(@isBonus as int) as varchar)  as sm,

  m.Peni as Peni
from  NearLogistic.nlTariffParams pd join NearLogistic.nlTariffsDet d on pd.nlTariffParamsID=d.nlTariffParamsID
                                     join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID,
      Marsh m left join Drivers r on m.SpedDrID=r.drID

              cross apply (select min(s.mhid) as SpdMhId from marsh s where s.nd=m.nd and s.SpedDrID=m.SpedDrId) ms 
where m.mhID=@mhID   and   pd.nlTariffParamsID=@nlTariffParamsIDSpd  
         
union

select 0 as Num,'Маршрут' as Name, 
       iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)),
       iif(@Dots-@DotsNet-@DotsOver25 > 0, @Dots-@DotsNet-@DotsOver25, 0),
       m.[Weight]+m.dopWeight,
       @DurationHours,
       @DotsNet,
       @DotsOver25,
       case when @Dots <= 25 then 1 else 0 end,
       case when @Dots > 25 then 1 else 0 end,
       case when d.nlPersonalRank=0 then [NearLogistic].WorkShift(iif(m.dist=0,m.CalcDist,m.dist)) else 0 end,
       case when d.nlPersonalRank=1 then [NearLogistic].WorkShift(iif(m.dist=0,m.CalcDist,m.dist)) else 0 end,
       case when d.nlPersonalRank=2 then [NearLogistic].WorkShift(iif(m.dist=0,m.CalcDist,m.dist)) else 0 end,
       case when d.nlPersonalRank=3 then [NearLogistic].WorkShift(iif(m.dist=0,m.CalcDist,m.dist)) else 0 end,
       case when isnull(m.V_idTR,0)>0 then 1 else 0 end,
       @isBonus,
       null as sm,
       m.Peni as Peni
       
from Marsh m left join Drivers d on m.drId=d.drId
             
where m.mhID=@mhID  

order by Num
           
           

END