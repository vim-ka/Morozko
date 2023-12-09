

CREATE PROCEDURE dbo.Eload_FinMoneyOborot
@nd1 datetime,
@nd2 datetime
AS
BEGIN
with money_takes(GroupID,Sum) as 
(
  select f.FirmGroup
        ,sum(k.plata) 
  from kassa1 k 
  join FirmsConfig f on f.Our_id=k.Our_id
  join KsOper ks on k.oper=ks.oper
  where (k.stnom - k.p_id*100) = 1 
        and k.nd between @nd1 and @nd2 
        and k.oper in (10)
        and k.realoper=1
  group by f.FirmGroup
),
money_gives(GroupID,Sum) as 
(
  select f.FirmGroup
        ,sum(k.plata) 
  from kassa1 k 
  join FirmsConfig f on f.Our_id=k.Our_id
  join KsOper ks on k.oper=ks.oper
  where (k.stnom - k.p_id*100) = 1 
        and k.nd between @nd1 and @nd2 
        and k.oper in (59)
        and k.p_id not in (5731)
  group by f.FirmGroup
)

select fg.FirmsGroupName [Фирма],
			 mg.sum [Собрано ДС],
       mt.sum [Сдано ДС]
from FirmsGroup fg 
inner join money_takes mt on mt.GroupID=fg.FirmsGroupID
inner join money_gives mg on mg.GroupID=fg.FirmsGroupID
END