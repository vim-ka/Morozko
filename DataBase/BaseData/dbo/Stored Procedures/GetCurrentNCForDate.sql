CREATE PROCEDURE dbo.GetCurrentNCForDate 
@dt datetime,
@isVet bit =0
AS
begin
select distinct x.*
into #nc_filter
FROM (
select distinct c.*
from nv v
inner join nc c on c.datnom=v.datnom
inner join nomen n on n.hitag=v.hitag
inner join gr g on g.ngrp=n.ngrp
where c.nd=@dt
      AND c.RefDatnom = 0
      and c.sp>=0
			and c.DayShift<1
			--and c.marsh<>99
      and g.vet=iif(@isVet=1,@isVet,Vet)
UNION ALL 
select distinct c.*
from nvZakaz v
inner join nc c on c.datnom=v.datnom
inner join nomen n on n.hitag=v.hitag
inner join gr g on g.ngrp=n.ngrp
where c.nd=@dt
      AND c.RefDatnom = 0
			and c.sp>=0
      AND v.Done=0
			and c.DayShift<1
			--and c.marsh<>99
      and g.vet=iif(@isVet=1,@isVet,Vet)) x

create nonclustered index idx_nc_filteredDatNom on #nc_filter(datnom)

select 	c.nd,				 
				case when isnull(c.stfnom,'')='' then cast((c.datnom % 10000)as varchar) else c.stfnom end [n1],
				c.datnom % 10000 [n],
				case when exists(select * from nvzakaz where datnom=c.DatNom and done=0) then '{K}'+isnull(c.StfNom,'') else c.StfNom end [StfNom],
				c.b_id,
				c.fam,
				c.sp,
				c.sc,
				c.remark,
				c.RemarkOp,
				c.DatNom,
				c.sertifdoc,
				cast(m.Marsh as int) [marsh],
				cast(left(case when m.Marsh=0 then m.driver else m.Direction end+' '+isnull(rs.RegName,''),200) as varchar(200)) [napr],
				IIF(EXISTS(SELECT 1 FROM defcontract dc INNER JOIN AgentList al ON dc.ag_id=al.AG_ID where dc.pin=d.pin AND al.DepID=3),1,0) [Master],
        --d.Master,
				m.mhid,
				c.ag_id,
				p.fio [agfam],
				isnull(d.Fmt,0) [fmt],
				cast(0 as bit)  [res45],
				case when (d.fmt=4)OR(d.pin IN (37833,11527,1811,821,35388,360,38064,34710,32957,20684,20702,44001,2217,40610,34124,32717,63)) then cast(1 as bit) else cast(0 as bit) end [isVip],
        c.DCK,
        iif(fc.our_id in (10,18,19),fc.OurName,'') [OurName],

        STUFF((SELECT '; ' + t.FIO
        FROM (
              select isnull((select top 1 ' {'+fio+'}' [fio] 
				    		from sertiflog lg 
                join usrpwd on uin=op 
               where datnom=c.datnom
                 and lg.SertifDoc & dno <> 0
                 and nc.SertifDoc & dNo <> 0
                 ORDER BY lg.sid desc
                     ),'') AS FIO 
              from SertifDoc
              inner join nc on nc.DatNom=c.datnom and nc.SertifDoc & dNo <> 0
            )t
  for xml path(''))
  ,1,2,'') AS Pril, fc.Our_id
  --dbo.SertifCheckVSDOUT(c.DatNom) AS VSD

from #nc_filter c
left join def d on d.pin=c.b_id
left join marsh m on /*m.nd=c.nd and*/ m.mhid=c.mhid
left join NearLogistic.GetRegsString(@dt) rs on rs.mhid=m.mhid
left join agentlist a on a.ag_id=c.ag_id
left join person p on p.p_id=a.p_id
left join FirmsConfig fc on fc.Our_id=c.OurID
where c.nd=@dt
			and c.sp>=0
			and c.DayShift<1
			--and c.marsh<>99
order by c.datnom

drop table #nc_filter
end