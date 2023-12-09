

CREATE PROCEDURE CalcVendOborotOLD @ncod int, @date1 datetime, @date2 datetime
AS
BEGIN
select k.nd Data, max(k.tm) TIM, sum(k.Plata) Plata, max(k.Remark) Remark,
null sumcost, null izmen, null corr, null remove,
k.Bank_id bank, null My, null nomdok,
isnull((select sum(c2.summacost + c2.izmen + c2.remove + c2.corr) from comman c2 where c2.ncod=@ncod and c2.date<k.nd),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and ((k2.nd<k.nd)or(k2.nd=k.nd and k2.kassid < min(k.kassid)))),0) saldo1,
isnull((select sum(c2.summacost + c2.izmen + c2.remove + c2.corr) from comman c2 where c2.ncod=@ncod and c2.date<k.nd),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and ((k2.nd<k.nd)or(k2.nd=k.nd and k2.kassid < min(k.kassid)))),0) - sum(k.plata) saldo2,
k.op OP, max(k.kassid) mid, 0 aid
from kassa1 k
where k.ncod = @ncod and k.nd >= @date1 and k.nd < @date2
      and k.oper = -1
group by k.nd,k.bank_id,k.op

union

select c.date Data, c.time TIM, null Plata, 'Приход - срок конс. '+convert(varchar(4),srok)+' дней' Remark,
c.summacost sumcost, c.izmen izmen, c.corr corr, c.remove remove,
null bank, our_id My, c.doc_nom nomdok,
isnull((select sum(c2.summacost + c2.izmen + c2.remove + c2.corr) from comman c2 where c2.ncod=@ncod and ((c2.date<c.date)or(c2.date=c.date and c2.ncom<c.ncom))),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and (k2.nd<=c.date)),0) saldo1,
isnull((select sum(c2.summacost + c2.izmen + c2.remove + c2.corr) from comman c2 where c2.ncod=@ncod and ((c2.date<c.date)or(c2.date=c.date and c2.ncom<=c.ncom))),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and (k2.nd<=c.date)),0) saldo2,
c.op OP, c.ncom mid, 1 aid
from comman c
where c.ncod = @ncod and c.date >= @date1 and c.date < @date2
order by 1,2,12

END