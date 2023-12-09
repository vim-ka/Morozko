CREATE PROCEDURE dbo.EloadSertificatsStatisticsMarsh
@ND datetime,
@marsh int
AS
BEGIN
declare @dt1 int
declare @dt2 int
set @dt1=dbo.indatnom(0,@nd)
set @dt2=@dt1+9999

select d.pin,
			 d.brName,
       c.datnom,
       c.SertifDoc
into #tmpNC
from nc c
inner join def d on d.pin=c.b_id
inner join nv v on v.datnom=c.datnom
inner join nomen n on n.hitag=v.hitag 
inner join gr g on g.ngrp=n.ngrp              
where c.datnom between @dt1 and @dt2
			and c.sp>0
			and g.Vet=1
      and c.Marsh=@marsh
group by c.datnom,d.pin,d.brname,c.SertifDoc
      
select c.pin [КодТочки],
			 c.brname [НаименвоаниеТочки],
       (select count(1) from #tmpNC t where t.pin=c.pin) [КоличествоНакладных],
       (select count(1) from #tmpNC t where t.pin=c.pin and ((t.SertifDoc & 4)<>0 or (t.SertifDoc & 16)<>0)) [КоличествоНакладныхСОтметкой],
       (select count(1) from #tmpNC t where t.pin=c.pin and (t.SertifDoc & 4)=0 and (t.SertifDoc & 16)=0) [КоличествоНакладныхБезОтметкой]
from #tmpNC c
group by c.pin,c.brname

drop table #tmpNC
END