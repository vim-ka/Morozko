CREATE PROCEDURE ELoadMenager.Eload_NLRates
@nd1 datetime
AS
BEGIN
declare @nd2 datetime,@nd3 datetime, @nd4 datetime,@nd5 datetime, @nd6 datetime
set @nd1=dateadd(day,1,eomonth(@nd1,-1))
set @nd2=dateadd(month, 1, @nd1)
set @nd3=dateadd(month, -1, @nd1)
set @nd4=@nd1
set @nd5=dateadd(month, -2, @nd1)
set @nd6=@nd3

select '3 '+datename(month,@nd1)+' '+cast(year(@nd1) as varchar) as [Период],
       sum(m.Dots) as [Количество сработавших тт],
       count(m.marsh) as [Количество вывезенных маршрутов],
       round(avg(m.weight+m.dopweight),2) as [Средняя загрузка транспорта, кг],
       round(sum(m.weight+m.dopweight),2) as [Всего вывезено, кг],
       round(sum(d.OplataSum),2) as [Затраты на доставку, руб],
       round(sum(d.OplataSum)/sum(m.weight+m.dopweight),2) as [Затраты на доставку 1кг груза, руб],
       sum(d.OplataSum)/ (select sum(sp) from nc where ND>=@nd1 and ND<@nd2 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as [Затраты на доставку 1руб. продукции],
       round(sum(d.OplataSum)/sum(m.Dots),2) as [Средние затраты на доставку в 1 точку],
       (select sum(sp) from nc where ND>=@nd1 and ND<@nd2 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as [Объём продаж]            
from Marsh m join NearLogistic.nlListPayDet d on m.Marsh=d.Marsh and m.ND=d.Nd
where m.ND>=@nd1 and m.ND<@nd2 /*and m.mState=2*/ and m.Marsh<>99 and m.SelfShip<>1  and m.weight>0

union

select '2 '+datename(month,@nd3)+' '+cast(year(@nd3) as varchar) as [Период],
       sum(m.Dots) as kolvo,
       count(m.marsh) as kMarsh,
       round(avg(m.weight+m.dopweight),2) as sweight,
       round(sum(m.weight+m.dopweight),2) as vweight,
       round(sum(d.OplataSum),2) as Oplata,
       round(sum(d.OplataSum)/sum(m.weight+m.dopweight),2) as Oplat1kg,
       sum(d.OplataSum)/ (select sum(sp) from nc where ND>=@nd3 and ND<@nd4 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as Oplata1Rub,
       round(sum(d.OplataSum)/sum(m.Dots),2) as Oplata1Dots,
       (select sum(sp) from nc where ND>=@nd3 and ND<@nd4 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as sm            
from Marsh m join NearLogistic.nlListPayDet d on m.Marsh=d.Marsh and m.ND=d.Nd
where m.ND>=@nd3 and m.ND<@nd4 /*and m.mState=2*/ and m.Marsh<>99 and m.SelfShip<>1 and m.weight>0

union

select '1 '+datename(month,@nd5)+' '+cast(year(@nd5) as varchar) as [Период],
       sum(m.Dots) as kolvo,
       count(m.marsh) as kMarsh,
       round(avg(m.weight+m.dopweight),2) as sweight,
       round(sum(m.weight+m.dopweight),2) as vweight,
       round(sum(d.OplataSum),2) as Oplata,
       round(sum(d.OplataSum)/sum(m.weight+m.dopweight),2) as Oplat1kg,
       sum(d.OplataSum)/ (select sum(sp) from nc where ND>=@nd5 and ND<@nd6 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as Oplata1Rub,
       round(sum(d.OplataSum)/sum(m.Dots),2) as Oplata1Dots,
       (select sum(sp) from nc where ND>=@nd5 and ND<@nd6 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as sm
from Marsh m join NearLogistic.nlListPayDet d on m.Marsh=d.Marsh and m.ND=d.Nd
where m.ND>=@nd5 and m.ND<@nd6 /*and m.mState=2*/ and m.Marsh<>99 and m.SelfShip<>1 and m.weight>0

union 

select '3.1 '+datename(month,@nd1)+' '+cast(year(@nd1) as varchar) as [Период],
       sum(m.Dots) as [Количество сработавших т\т],
       count(m.marsh) as [Количество вывезенных маршрутов],
       round(avg(m.weight+m.dopweight),2) as [Средняя загрузка транспорта, кг],
       round(sum(m.weight+m.dopweight),2) as [Всего вывезено, кг],
       round(sum(d.OplataSum),2) as [Затраты на доставку, руб],
       round(sum(d.OplataSum)/sum(m.weight+m.dopweight),2) as [Затраты на доставку 1кг груза, руб],
       sum(d.OplataSum)/ (select sum(sp) from nc where ND>=@nd1 and ND<@nd2 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as [Затраты на доставку 1руб. продукции],
       round(sum(d.OplataSum)/sum(m.Dots),2) as [Средние затраты на доставку в 1 точку],
       (select sum(sp) from nc where ND>=@nd1 and ND<@nd2 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as [Объём продаж]            
from Marsh m join dbo.MarshOplDet d on m.Marsh=d.Marsh and m.ND=d.Ndmarsh
where m.ND>=@nd1 and m.ND<@nd2 /*and m.mState=2*/ and m.Marsh<>99 and m.SelfShip<>1  and m.weight>0

union

select '2.1 '+datename(month,@nd3)+' '+cast(year(@nd3) as varchar) as [Период],
       sum(m.Dots) as kolvo,
       count(m.marsh) as kMarsh,
       round(avg(m.weight+m.dopweight),2) as sweight,
       round(sum(m.weight+m.dopweight),2) as vweight,
       round(sum(d.OplataSum),2) as Oplata,
       round(sum(d.OplataSum)/sum(m.weight+m.dopweight),2) as Oplat1kg,
       sum(d.OplataSum)/ (select sum(sp) from nc where ND>=@nd3 and ND<@nd4 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as Oplata1Rub,
       round(sum(d.OplataSum)/sum(m.Dots),2) as Oplata1Dots,
       (select sum(sp) from nc where ND>=@nd3 and ND<@nd4 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as sm            
from Marsh m join dbo.MarshOplDet d on m.Marsh=d.Marsh and m.ND=d.Ndmarsh
where m.ND>=@nd3 and m.ND<@nd4 /*and m.mState=2*/ and m.Marsh<>99 and m.SelfShip<>1 and m.weight>0

union

select '1.1 '+datename(month,@nd5)+' '+cast(year(@nd5) as varchar) as [Период],
       sum(m.Dots) as kolvo,
       count(m.marsh) as kMarsh,
       round(avg(m.weight+m.dopweight),2) as sweight,
       round(sum(m.weight+m.dopweight),2) as vweight,
       round(sum(d.OplataSum),2) as Oplata,
       round(sum(d.OplataSum)/sum(m.weight+m.dopweight),2) as Oplat1kg,
       sum(d.OplataSum)/ (select sum(sp) from nc where ND>=@nd5 and ND<@nd6 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as Oplata1Rub,
       round(sum(d.OplataSum)/sum(m.Dots),2) as Oplata1Dots,
       (select sum(sp) from nc where ND>=@nd5 and ND<@nd6 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as sm
from Marsh m join dbo.MarshOplDet d on m.Marsh=d.Marsh and m.ND=d.ndmarsh
where m.ND>=@nd5 and m.ND<@nd6 /*and m.mState=2*/ and m.Marsh<>99 and m.SelfShip<>1 and m.weight>0
END