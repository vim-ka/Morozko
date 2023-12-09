CREATE PROCEDURE db_FarLogistic.set_koefficient_expence
@proc decimal(7,4)=65.0,
@nd datetime=null,
@MinCost money=7000,
@DotCost money=1500,
@MinRaceKM money=50,
@MinCostRef money=3500,
@DotCostRef money=1500,
@MinRaceKMRef money=50
as
begin
if @nd is null set @nd=dateadd(day,1,convert(varchar,getdate(),104));

with veh_koef as 
(
select dlvehtypeid [id],
			 cast(@proc/100.0 as decimal(6,4)) [alpha],
       case when dlvehtypeid=1 then @mincost
       			when dlvehtypeid=3 then @mincostref
            else 0 end [mincost],
       case when dlvehtypeid=1 then @dotcost
       			when dlvehtypeid=3 then @dotcostref
            else 0 end [dotcost],
       case when dlvehtypeid=1 then @minracekm
       			when dlvehtypeid=3 then @minracekmref
            else 0 end [minracekm],
       case when dlvehtypeid=1 then 30 
       			when dlvehtypeid=3 then 18
            else 0 end [palcount]
from db_farlogistic.dlvehtype 
where dlvehtypeid in (1,3,5)
)

insert into db_FarLogistic.dlExpence(Amort,Strah,Serv,Fuel,DriverZar,LogicZar,Other,Handler,IDVehTYpe,DateStart,PriceKM,KMPalCost,MinCost,DotCost,MinRaceKM,[percent])
select Amort*k.alpha [Amort],Strah*k.alpha [Strah],Serv*k.alpha [Serv],Fuel*k.alpha [Fuel],DriverZar*k.alpha [DriverZar],
			 LogicZar*k.alpha [LogicZar],Other*k.alpha [Other],Handler*k.alpha [Handler],IDVehTYpe,@nd,
  		 cast(e.pricekm*k.alpha as decimal(15,2)) [pricekm],cast(iif(k.palcount=0,0,e.pricekm*k.alpha/k.palcount) as decimal(15,2)) [kmpalcost],
       isnull(k.MinCost,e.mincost) [MinCost],isnull(k.DotCost,e.dotcost) [DotCost],isnull(k.MinRaceKM,e.minracekm) [MinRaceKM],
       @proc
from db_FarLogistic.dlExpence e
join veh_koef k on k.id=e.idvehtype
where e.datestart='20130101'
end