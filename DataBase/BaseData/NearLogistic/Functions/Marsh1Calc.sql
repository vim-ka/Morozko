CREATE FUNCTION NearLogistic.Marsh1Calc (
  @mhID int, 
  @nlTariffParamsIDDrv int,
  @nlTariffParamsIDSpd int
/*  ,@v_id int=0 */
)
RETURNS money
AS
BEGIN
declare @smdrv money, @smspd money, @CrutchPay money
declare @DotsNet int, @Dots int, @DotsOver25 int

declare @DotsBasePlan int, @Dot2NetDot float, @isBonus bit, @DurationHours decimal(7,2), @ttID int  
 
declare @DistForCalc decimal(10,3)

select @DistForCalc = iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0))
from [dbo].marsh m 
where m.mhid = @mhid

select @DotsBasePlan=cast(Value as int)
from [NearLogistic].nlConfig
where Param='DotsBasePlan'

select @Dot2NetDot=cast(Value as float)
from [NearLogistic].nlConfig
where Param='Dot2NetDot'

set @DurationHours=isnull((select iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)) from dbo.Marsh m  where m.mhid=@mhID),0)     

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
                    
            
if @DotsNet*@Dot2NetDot+(@Dots-@DotsNet) > @DotsBasePlan
set @isBonus=1 
else set @isBonus=0              
            
set @DotsOver25 = @Dots - 25               
if @DotsOver25<0 set @DotsOver25=0
set @DotsNet=iif(@DotsNet>25,25,@DotsNet)       

set @ttid=(select t.ttid 
           from nearlogistic.nltariffParams p join nearlogistic.nltariffsdet d on d.nltariffparamsid=p.nltariffparamsid
                                             join nearlogistic.nltariffs t on t.nltariffsid=d.nltariffsid
           where p.nlTariffParamsID=@nlTariffParamsIDDrv)

if @ttid=2 set @Dots=[NearLogistic].[RoundToDecDown](@Dots);  

set @smdrv=(
select 
 cast(isnull(pd.Pay1Km*@DistForCalc+
  pd.Pay1Dot*iif(@Dots-@DotsNet-@DotsOver25 > 0, @Dots-@DotsNet-@DotsOver25, 0)+
  pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
  pd.Pay1Hour*@DurationHours+
  pd.Pay1DotNet*@DotsNet+
  pd.Pay1DotOver*@DotsOver25+
  pd.PayAllDot*(case when @Dots<25 then 1 else 0 end)+
  pd.PayAllDotOver*(case when @Dots>25 then 1 else 0 end)+
  [NearLogistic].WorkShift(@DistForCalc)*pd.Rate0Rank*iif(r.nlPersonalRank=0,1,0)+
  [NearLogistic].WorkShift(@DistForCalc)*pd.Rate1Rank*iif(r.nlPersonalRank=1,1,0)+
  [NearLogistic].WorkShift(@DistForCalc)*pd.Rate2Rank*iif(r.nlPersonalRank=2,1,0)+
  [NearLogistic].WorkShift(@DistForCalc)*pd.Rate3Rank*iif(r.nlPersonalRank=3,1,0)+
  pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end),0)+
  pd.Bonus*@isBonus+
  isnull(h.expense,0)+
  @DistForCalc*isnull(h.tariff1km,0) as varchar) as sm
from  
      Marsh m left join Drivers r on m.drId=r.drId
              left join vehicle h on h.v_id=m.v_id --iif(@v_id=0,m.v_id, @v_id)
              left join NearLogistic.nlTariffParams pd  on pd.nlTariffParamsID=@nlTariffParamsIDDrv 
              left join NearLogistic.nlTariffsDet d on pd.nlTariffParamsID=d.nlTariffParamsID
              left join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID
where m.mhID=@mhID 
)

set @smspd=(
select
  cast( pd.Pay1Km*@DistForCalc+
  pd.Pay1Dot*iif(@Dots-@DotsNet-@DotsOver25 > 0, @Dots-@DotsNet-@DotsOver25, 0)+
  pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
  pd.Pay1Hour*@DurationHours+
  pd.Pay1DotNet*@DotsNet+
  pd.Pay1DotOver*@DotsOver25+
  pd.PayAllDot*(case when @Dots<25 then 1 else 0 end)+
  pd.PayAllDotOver*(case when @Dots>25 then 1 else 0 end)+
  [NearLogistic].WorkShift(@DistForCalc)*pd.Rate0Rank*iif(r.nlPersonalRank=0,1,0)+
  [NearLogistic].WorkShift(@DistForCalc)*pd.Rate1Rank*iif(r.nlPersonalRank=1,1,0)+
  [NearLogistic].WorkShift(@DistForCalc)*pd.Rate2Rank*iif(r.nlPersonalRank=2,1,0)+
  [NearLogistic].WorkShift(@DistForCalc)*pd.Rate3Rank*iif(r.nlPersonalRank=3,1,0)+
  pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end)+
  pd.Bonus*@isBonus as varchar) as sm
from  NearLogistic.nlTariffParams pd join NearLogistic.nlTariffsDet d on pd.nlTariffParamsID=d.nlTariffParamsID
                                     join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID,
      Marsh m left join Drivers r on m.SpedDrID=r.drID

where m.mhID=@mhID   and   pd.nlTariffParamsID=@nlTariffParamsIDSpd  
)

set @CrutchPay = [NearLogistic].fnCrutch(@mhid, 1, 0)

Return isnull(@smdrv,0) + isnull(@smspd,0)-- + isnull(@CrutchPay,0)
END