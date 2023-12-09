CREATE FUNCTION RetroB.GetBasPriceID (@hitag int, @ncod int, @dck int, @cost decimal(20,4), @cost1kg decimal(20,4), @nd datetime)
RETURNS int
AS
BEGIN
declare @res int

select top 1 @res=bp.prid
from [RetroB].BasPricesMain m 
join [RetroB].BasPrices bp on m.BPMid=bp.BPMid
join [RetroB].BasVend v on m.BPMid=v.BPMid 
where m.Actual = 1 and bp.hitag = @hitag                                                     
      and ((v.Ncod = @ncod and v.DCK=0) or v.dck = @dck)
      and @nd>=bp.Day0 and @nd<=bp.Day1
      and abs(bp.FinalCost - iif(bp.flgweight=1,@cost1kg,@cost))<=0.03
order by bp.bpmid 

return isnull(@res,0)
END