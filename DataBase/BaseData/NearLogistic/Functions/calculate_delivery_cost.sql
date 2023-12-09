CREATE function NearLogistic.calculate_delivery_cost(@mhid int, @v_id int, @ttype int=0)
returns money
as
begin
declare @smdrv money, @smspd money, @dotsnet int, @dots int, @dotsover25 int,
				@DotsBasePlan int, @dot2netdot money, @isbonus bit, @durationhours decimal(7,2),
        @tp_drid int, @tp_spdrid int, @type int, @km int, @expense money, @tariff1km money,
        @istrailer bit, @dr_rank int, @spd_rank int, @marsh_weight decimal(15,2) 

select @tp_drid=nlTariffParamsIDDrv,
			 @tp_spdrid=nlTariffParamsIDSpd
from [dbo].marsh
where mhid=@mhid

if @v_id>0 and @ttype=0
begin
  select @type=c.ttid
  from [dbo].vehicle v
  join [dbo].carriers c on c.crid=v.crid
  where v.v_id=@v_id

  select @tp_drid=d.nlTariffParamsID, 
         @tp_spdrid=x.[spd]
  from (
  select m.nlTariffParamsIDDrv [drv], m.nlTariffParamsIDSpd [spd], 
         m.weight [w], iif(isnull(m.km1 - m.km0,0)<=0,m.calcdist,m.km1-m.km0) [km],
         cast(iif(m.SpedDrID>0,1,0)as bit) [withsped]
  from [dbo].marsh m
  where m.mhid=@mhid) x
  left join nearlogistic.nlvehcapacity vc on x.[w] between vc.weightmin and vc.weightmax
  left join nearlogistic.nltariffs t on t.ttid=@type and t.withsped=x.[withsped] and x.[km] between t.diststart and t.distend 
  left join nearlogistic.nltariffsdet d on d.nlvehcapacityid=vc.nlvehcapacityid and t.nltariffsid=d.nltariffsid
end

if @v_id=0 and @ttype>0
begin
  set @type=@ttype

  select @tp_drid=d.nlTariffParamsID, 
         @tp_spdrid=x.[spd]
  from (
  select m.nlTariffParamsIDDrv [drv], m.nlTariffParamsIDSpd [spd], 
         m.weight [w], iif(isnull(m.km1 - m.km0,0)<=0,m.calcdist,m.km1-m.km0) [km],
         cast(iif(m.SpedDrID>0,1,0)as bit) [withsped]
  from [dbo].marsh m
  where m.mhid=@mhid) x
  left join nearlogistic.nlvehcapacity vc on x.[w] between vc.weightmin and vc.weightmax
  left join nearlogistic.nltariffs t on t.ttid=@type and t.withsped=x.[withsped] and x.[km] between t.diststart and t.distend 
  left join nearlogistic.nltariffsdet d on d.nlvehcapacityid=vc.nlvehcapacityid and t.nltariffsid=d.nltariffsid
end

select @dotsbaseplan=cast(value as int)
from [nearlogistic].nlConfig where Param='DotsBasePlan'

select @dot2netdot=cast(value as float)
from [nearlogistic].nlConfig where Param='Dot2NetDot'

set @durationhours=isnull(
		(select iif(datediff(hour,m.timego,m.timeback)<=0,0,datediff(hour,m.timego,m.timeback)) 
     from [dbo].marsh m where m.mhid=@mhID)
    											,0) 

select @km=iif(isnull(m.km1-m.km0,0)>0,m.km1-m.km0,m.calcdist),
			 @expense=isnull(v.expense,0),
       @tariff1km=isnull(v.tariff1km,0),
       @istrailer=cast(iif(m.v_idtr>0,1,0) as bit),
       @dr_rank=isnull(d.nlPersonalRank,0),
       @spd_rank=isnull(s.nlPersonalRank,0),
       @marsh_weight=m.[Weight]+isnull(m.dopWeight,0)
from [dbo].marsh m
left join [dbo].vehicle v on v.v_id=iif(@v_id<=0,m.v_id,@v_id) 
left join [dbo].drivers d on d.drid=m.drid
left join [dbo].drivers s on s.drid=m.speddrid
where m.mhid=@mhid                            

set @dotsnet= isnull(
		(select count(distinct iif(mr.PINFrom>0,mr.pinFrom,mr.Pinto) /*(case when isnull(d.vmaster,0)>0 then d.vmaster else d.pin end)*/) 
     from [dbo].nc c 
     join [NearLogistic].MarshRequests mr on mr.ReqID=c.DatNom and mr.ReqType=0
     join [dbo].defcontract f on c.dck=f.dck
    -- join [dbo].def d on c.b_id=d.pin
    -- join [dbo].marsh m on c.mhid=m.mhid
    join [dbo].agentlist a on f.ag_id=a.ag_id
     where mr.mhid=@mhID and a.depid in (3,26))
     								,0)

set @dotsnet=iif(@dotsnet>25,25,@dotsnet)            
                                   
set @dots= isnull(
		(select count(distinct iif(mr.PINFrom>0,mr.pinFrom,mr.Pinto) /*(case when isnull(d.vmaster,0)>0 then d.vmaster else d.pin end)*/) 
     from 
      [NearLogistic].MarshRequests mr 
     --join [dbo].defcontract f on c.dck=f.dck
     --join [dbo].def d on c.b_id=d.pin
     where mr.mhid=@mhID)
     							,0)

set @dotsover25 = @dots - 25               
if @dotsover25<0 set @dotsover25=0
            
if @dotsnet*@dot2netdot+(@dots-@dotsnet) > @dotsbaseplan set @isbonus=1 
else set @isbonus=0              

set @smdrv=(
		select pd.Pay1Km*@km+
           pd.Pay1Dot*iif(@dots-@dotsnet-@dotsover25 > 0, @dots-@dotsnet-@dotsover25, 0)+
           pd.Pay1Kg*@marsh_weight+
           pd.Pay1Hour*@durationhours+
           pd.Pay1DotNet*@dotsnet+
           pd.Pay1DotOver*@dotsover25+
           pd.PayAllDot*(case when @dots<25 then 1 else 0 end)+
           pd.PayAllDotOver*(case when @dots>25 then 1 else 0 end)+
           pd.Rate0Rank*(case when @dr_rank=0 then 1 else 0 end)+
           pd.Rate1Rank*(case when @dr_rank=1 then 1 else 0 end)+
           pd.Rate2Rank*(case when @dr_rank=2 then 1 else 0 end)+
           pd.Rate3Rank*(case when @dr_rank=3 then 1 else 0 end)+
           pd.Trailer*iif(@istrailer=1,1,0)+
  				 pd.Bonus*@isbonus+@expense+@km*@tariff1km
    from [nearlogistic].nlTariffParams pd
    where pd.nlTariffParamsID=@tp_drid  
    				)

set @smspd=(
		select pd.Pay1Km*@km+
  				 pd.Pay1Dot*iif(@dots-@dotsnet-@dotsover25 > 0, @dots-@dotsnet-@dotsover25, 0)+
  				 pd.Pay1Kg*@marsh_weight+
  				 pd.Pay1Hour*@durationhours+
  				 pd.Pay1DotNet*@dotsnet+
  				 pd.Pay1DotOver*@dotsover25+
  				 pd.PayAllDot*(case when @dots<25 then 1 else 0 end)+
  				 pd.PayAllDotOver*(case when @dots>25 then 1 else 0 end)+
  				 pd.Rate0Rank*(case when @spd_rank=0 then 1 else 0 end)+
  				 pd.Rate1Rank*(case when @spd_rank=1 then 1 else 0 end)+
  				 pd.Rate2Rank*(case when @spd_rank=2 then 1 else 0 end)+
  				 pd.Rate3Rank*(case when @spd_rank=3 then 1 else 0 end)+
  				 pd.Trailer*iif(@istrailer=1,1,0)+
  				 pd.Bonus*@isbonus
		from [nearlogistic].nlTariffParams pd 
    where pd.nlTariffParamsID=@tp_spdrid
					)

return isnull(@smdrv,0) + isnull(@smspd,0)
end