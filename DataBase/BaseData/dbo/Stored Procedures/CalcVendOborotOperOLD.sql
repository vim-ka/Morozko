

CREATE PROCEDURE CalcVendOborotOperOLD @ncod int, @date1 datetime, @date2 datetime
AS
BEGIN
select k.nd Data, max(k.tm) TIM, sum(k.Plata) Plata, max(k.Remark) Remark,
null sumcost, null izmen, null corr, null remove,
k.Bank_id bank, null My, null nomdok,
isnull((select sum(c2.summacost) from comman c2 where c2.ncod=@ncod and c2.date<k.nd),0) +
isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.ncod=@ncod and ((cc2.nd<k.nd)or (cc2.nd<=k.nd))),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and ((k2.nd<k.nd)or(k2.nd=k.nd and k2.kassid < min(k.kassid)))),0)+
isnull((select sum(i2.smi) from izmen i2 where i2.ncod=@ncod and (i2.Act='Снят' or i2.Act='ИзмЦ') and ((i2.nd<=k.nd)/*or(i2.nd=i.nd)*/)),0) saldo1,

isnull((select sum(c2.summacost) from comman c2 where c2.ncod=@ncod and c2.date<k.nd),0) +
isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.ncod=@ncod and ((cc2.nd<k.nd)or(cc2.nd<=k.nd))),0) +
isnull((select sum(i2.smi) from izmen i2 where i2.ncod=@ncod and (i2.Act='Снят' or i2.Act='ИзмЦ') and ((i2.nd<=k.nd)/*or(i2.nd=i.nd)*/)),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and ((k2.nd<k.nd)or(k2.nd=k.nd and k2.kassid < min(k.kassid)))),0) - sum(k.plata) saldo2,
k.op OP, max(k.kassid) mid, 3 aid
from kassa1 k
where k.ncod = @ncod and k.nd >= @date1 and k.nd < @date2
      and k.oper = -1
group by k.nd,k.bank_id,k.op

union

select c.date Data, c.time TIM, null Plata, 'Приход - срок конс. '+convert(varchar(4),srok)+' дней' Remark,
c.summacost sumcost, null izmen, null corr, null remove,
null bank, our_id My, c.doc_nom nomdok,
isnull((select sum(c2.summacost) from comman c2 where c2.ncod=@ncod and ((c2.date<c.date)or(c2.date=c.date and c2.ncom<c.ncom))),0) +
isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.ncod=@ncod and ((cc2.nd<c.date) or (cc2.nd<=c.date))),0) +
isnull((select sum(i2.smi) from izmen i2 where i2.ncod=@ncod and (i2.Act='Снят' or i2.Act='ИзмЦ') and ((i2.nd<=c.date)/*or(i2.nd=i.nd)*/)),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and (k2.nd<=c.date)),0) saldo1,

isnull((select sum(c2.summacost) from comman c2 where c2.ncod=@ncod and ((c2.date<c.date)or(c2.date=c.date and c2.ncom<=c.ncom))),0) +
isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.ncod=@ncod and ((cc2.nd<c.date)or (cc2.nd<=c.date))),0) +
isnull((select sum(i2.smi) from izmen i2 where i2.ncod=@ncod and (i2.Act='Снят' or i2.Act='ИзмЦ') and ((i2.nd<=c.date)/*or(i2.nd=i.nd)*/)),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and (k2.nd<=c.date)),0) saldo2,
c.op OP, c.ncom mid, 4 aid
from comman c
where c.ncod = @ncod and c.date >= @date1 and c.date < @date2

union

select cast(floor(cast(cc.nd as decimal(38,19))) as datetime) Data, convert(varchar(8),cc.nd,108) TIM, null Plata,cc.Remark,
Null sumcost, null izmen, cc.corr corr, null remove,
null bank, null My, null nomdok,
isnull((select sum(c2.summacost) from comman c2 where c2.ncod=@ncod and c2.date<cc.nd),0) +
isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.ncod=@ncod and ((cc2.nd<cc.nd))),0) +
isnull((select sum(i2.smi) from izmen i2 where i2.ncod=@ncod and (i2.Act='Снят' or i2.Act='ИзмЦ') and ((i2.nd<=cc.nd)/*or(i2.nd=i.nd)*/)),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and ((k2.nd<cc.nd))),0) saldo1,

isnull((select sum(c2.summacost) from comman c2 where c2.ncod=@ncod and c2.date<cc.nd),0) +
isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.ncod=@ncod and ((cc2.nd<cc.nd))),0) +
isnull((select sum(i2.smi) from izmen i2 where i2.ncod=@ncod and (i2.Act='Снят' or i2.Act='ИзмЦ') and ((i2.nd<=cc.nd)/*or(i2.nd=i.nd)*/)),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and ((k2.nd<cc.nd))),0) + cc.corr saldo2,
cc.op OP, cc.ncom mid, 2 aid
from commancorr cc,comman cm
where cc.ncom=cm.ncom and cm.ncod = @ncod and cc.Nd >= @date1 and cc.Nd < @date2

union

select i.ND Data, max(i.tm) TIM, null Plata, max(i.Remark) Remark,
Null sumcost, Null izmen, null corr, sum(i.smi) remove,
null bank, null My, null nomdok,
isnull((select sum(c2.summacost) from comman c2 where c2.ncod=@ncod and c2.date<i.nd),0) +
isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.ncod=@ncod and ((cc2.nd<i.nd))),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and ((k2.nd<i.nd)/*or(k2.nd=i.nd)*/)),0) +
isnull((select sum(i2.smi) from izmen i2 where i2.ncod=@ncod and (i2.Act='Снят' or i2.Act='ИзмЦ') and ((i2.nd<i.nd)/*or(i2.nd=i.nd)*/)),0) saldo1,

isnull((select sum(c2.summacost) from comman c2 where c2.ncod=@ncod and c2.date<i.nd),0) +
isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.ncod=@ncod and ((cc2.nd<i.nd))),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and ((k2.nd<i.nd)/*or(k2.nd=i.nd)*/)),0) + 
isnull((select sum(i2.smi) from izmen i2 where i2.ncod=@ncod and (i2.Act='Снят' or i2.Act='ИзмЦ') and ((i2.nd<i.nd)/*or(i2.nd=i.nd)*/)),0)+sum(smi) saldo2,
i.op OP, null mid, 1 aid
from izmen i
where i.ncod = @ncod and i.Nd >= @date1 and i.Nd < @date2
      and i.Act='Снят' and i.smi<>0
group by i.ND,i.OP

union

select i.ND Data, max(i.tm) TIM, null Plata, max(i.Remark) Remark,
Null sumcost, sum(i.smi) izmen, null corr, null remove,
null bank, null My, null nomdok,
isnull((select sum(c2.summacost) from comman c2 where c2.ncod=@ncod and c2.date<i.nd),0) +
isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.ncod=@ncod and ((cc2.nd<i.nd))),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and ((k2.nd<i.nd)/*or(k2.nd=i.nd)*/)),0) +
isnull((select sum(i2.smi) from izmen i2 where i2.ncod=@ncod and (i2.Act='Снят' or i2.Act='ИзмЦ') and ((i2.nd<i.nd)/*or(i2.nd=i.nd)*/)),0) saldo1,

isnull((select sum(c2.summacost) from comman c2 where c2.ncod=@ncod and c2.date<i.nd),0) +
isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.ncod=@ncod and ((cc2.nd<i.nd))),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and ((k2.nd<i.nd)/*or(k2.nd=i.nd)*/)),0) + 
isnull((select sum(i2.smi) from izmen i2 where i2.ncod=@ncod and (i2.Act='Снят' or i2.Act='ИзмЦ') and ((i2.nd<i.nd)/*or(i2.nd=i.nd)*/)),0)+sum(smi) saldo2,
i.op OP, null mid, 0 aid
from izmen i
where i.ncod = @ncod and i.Nd >= @date1 and i.Nd < @date2
      and i.Act='ИзмЦ' and i.smi<>0
group by i.ND,i.OP
order by 1,2,16


END