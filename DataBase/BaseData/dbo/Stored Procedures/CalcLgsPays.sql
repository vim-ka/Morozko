CREATE PROCEDURE CalcLgsPays @day0 datetime, @day1 datetime
AS
Declare @sm numeric(10,2);        
Declare @kl numeric(10,2);
Begin
select
  m.LgsId,
  L.Fam,
  count(m.mhid) as MarshCount,
  sum(m.dots) as Dots,
  sum(m.Weight) as Weight,
  sum(v.MaxWeight) as MaxWeight,
  100*sum(m.Weight)/sum(v.MaxWeight) as Eff,
  count(m.mhid)*10.0 as Oplata,
  (case when (sum(m.Weight)/sum(v.MaxWeight)>=0.7) and (sum(m.Weight)/sum(v.MaxWeight)<0.8) then 0.7*count(m.mhid)*10 
  else case when (sum(m.Weight)/sum(v.MaxWeight)>=0.8) and (sum(m.Weight)/sum(v.MaxWeight)<0.9) then 0.8*count(m.mhid)*10 
  else case when (sum(m.Weight)/sum(v.MaxWeight)>=0.9) then count(m.mhid)*10 
  else 0 end end end) as Pereplata
into #TempTable  
from Marsh m, Lgs L,Vehicle v
where m.nd+m.MarshDay between @day0 and @day1 and m.V_ID=v.V_id and v.v_id<>0
and L.LgsId=M.LgsId and m.Dots>0 and m.Marsh<>99
group by
  m.LgsId, L.Fam
order by
  m.LgsId, L.Fam;

set @sm=(select sum(pereplata) from #TempTable);  
set @kl=(select count(*) from #TempTable where Pereplata=0);  
if @kl=0 set @kl=1; 
select LgsID,Fam,MarshCount,Dots,Weight,MaxWeight,Eff,Oplata, Pereplata,
       (case when Pereplata=0 then @sm/@kl else 0.0 end) as Doplata
 from #TempTable;   
end