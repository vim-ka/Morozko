CREATE PROCEDURE dbo.EloadFinMoneyOborotDet
@nd1 datetime,
@nd2 datetime,
@our int,
@isGroup bit
AS
BEGIN
select k.nd, 
			 k.tm, 
       k.oper, 
       ks.opername,
			 iif(ks.Rashflag=0,k.plata,0) as 'Приход',
			 iif(ks.Rashflag=1,k.plata,0) as 'Расход',
			 k.fam,
			 k.remark, 
       k.realoper,
			 k.our_id
from kassa1 k 
join FirmsConfig f on f.Our_id=k.Our_id
join KsOper ks on k.oper=ks.oper
where k.nd between @nd1 and @nd2 
			and k.op in (14,29,43,44) 
      and (k.stnom - k.p_id*100) <> 1 
		  and f.Our_id=iif(@isGroup=1,f.Our_id,iif(@our=-1,f.Our_id,@our))
      and f.FirmGroup=iif(@isGroup=1,@our,f.FirmGroup)
END