CREATE FUNCTION NearLogistic.Bill1CalcFact (@bill_id int, @TestDist decimal(10,3)=0.0, @TestnlTariffParamsID int=0)
RETURNS money
AS
BEGIN

declare @ttID int, @Ret money
declare @DotsNet int, @Dots int, @DotsOver25 int, @mas float
declare @DotsBasePlan int, @Dot2NetDot float, @isBonus bit, @DurationHours decimal (7,2)

declare @DistForCalc decimal(10,3)

select @DistForCalc = iif(@TestDist<>0.0, @TestDist, m.realdist)/1000.0, @Dots=m.RecCount, @mas=m.mas, @ttid=m.nlTariffParamsID
from [NearLogistic].BillsSum m 
where m.bill_id = @bill_id

select @ttid=t.ttid
from NearLogistic.nlTariffs t join NearLogistic.nlTariffsDet d on t.nlTariffsID=d.nlTariffsID
where d.nlTariffParamsID=@ttid


if @ttid = 7 and @DistForCalc<=200 set @Dots=NearLogistic.RoundToDecDown(@Dots)
if @ttid = 8 and @Dots<=2 
begin
  if @mas<150 set @mas=150
  set @DistForCalc=0
end  
if @ttid = 8 set @mas=0

select @DotsBasePlan=cast(Value as int)
from [NearLogistic].nlConfig
where Param='DotsBasePlan'

select @Dot2NetDot=cast(Value as float)
from [NearLogistic].nlConfig
where Param='Dot2NetDot'

set @DurationHours = 0;--isnull((select iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)) from dbo.Marsh m  where m.mhid=@mhID),0)     

set @DotsNet = 0;
            
if @DotsNet*@Dot2NetDot+(@Dots-@DotsNet) > @DotsBasePlan
set @isBonus=1 
else set @isBonus=0              
            
set @DotsOver25 = @Dots - 25               
if @DotsOver25<0 set @DotsOver25=0
set @DotsNet=iif(@DotsNet>25,25,@DotsNet)            


set @Ret=(
select 
 cast(isnull(pd.Pay1Km*@DistForCalc+
  pd.Pay1Dot*iif(@Dots-@DotsNet-@DotsOver25 > 0, @Dots-@DotsNet-@DotsOver25, 0)+
  pd.Pay1Kg*@mas+
  pd.Pay1Hour*@DurationHours+
  pd.Pay1DotNet*@DotsNet+
  pd.Pay1DotOver*@DotsOver25+
  pd.PayAllDot*(case when @Dots<25 then 1 else 0 end)+
  pd.PayAllDotOver*(case when @Dots>25 then 1 else 0 end)+
  pd.Rate0Rank*(case when r.nlPersonalRank=0 then 1 else 0 end)+
  pd.Rate1Rank*(case when r.nlPersonalRank=1 then 1 else 0 end)+
  pd.Rate2Rank*(case when r.nlPersonalRank=2 then 1 else 0 end)+
  pd.Rate3Rank*(case when r.nlPersonalRank=3 then 1 else 0 end)+
  pd.Trailer*(case when isnull(a.V_idTR,0)>0 then 1 else 0 end),0)
  /*pd.Bonus*@isBonus*//*+
  isnull(h.expense,0)+
  iif(m.dist=0,m.CalcDist,m.dist)*isnull(h.tariff1km,0)*/
  as varchar) as sm
from  
      [NearLogistic].BillsSum m join [dbo].marsh a on m.mhid=a.mhid
              left join Drivers r on a.drId=r.drId
              left join vehicle h on a.v_id=h.v_id
              left join NearLogistic.nlTariffParams pd on pd.nlTariffParamsID=iif(@TestnlTariffParamsID>0, @TestnlTariffParamsID,m.nlTariffParamsID)
              left join NearLogistic.nlTariffsDet d on pd.nlTariffParamsID=d.nlTariffParamsID
              left join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID                
where m.bill_id=@bill_id   
)


Return round(@Ret ,2)
  
END