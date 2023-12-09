CREATE PROCEDURE dbo.EloadSertifStatPlanFact
@nd1 datetime,
@nd2 datetime
AS
BEGIN
declare @uin int
declare @fio varchar(200)
declare @isMenag bit
declare @datnom int
declare @docno int

create table #tmp_ncSertif (datnom int,
														nd datetime,
                            marsh int, 
														pin int, 
                            uin int, 
                            docno int, 
                            iscity bit,
                            isnet bit,
                            remark varchar(50),
                            isHead bit,
                            isMarsh bit)
insert into #tmp_ncSertif(datnom,nd,marsh,pin,uin,docno,iscity,isnet,remark,isHead,isMarsh)
select c.DatNom,
			 c.nd,
       c.marsh,
			 c.b_id,
       0,
       c.SertifDoc,
       iif(d.Rn_ID=1,cast(1 as bit),cast(0 as bit)),
       iif(d.Master=0,cast(0 as bit),cast(1 as bit)),
       isnull(c.Remark,'')+iif(d.Fmt=4,'вет',''),
       cast(1 as bit),
       cast(0 as bit) 
from dbo.nc c
inner join dbo.def d on d.pin=c.b_id
where c.sp>0
			and c.nd between @nd1 and @nd2
      
delete from #tmp_ncSertif 
where isnet=0 
			and patindex('%вет%',remark)=0 
      and patindex('%в/с%',remark)=0 
      and patindex('%в\с%',remark)=0
      and docno=0

delete from #tmp_ncSertif
where isnet=1
		  and not exists(select 1 from nv v 
      							 inner join nomen n on n.hitag=v.hitag 
                     inner join gr g on g.ngrp=n.ngrp 
                     where g.vet=1 
                     			 and v.datnom=#tmp_ncSertif.datnom)
      and docno=0
      
insert into #tmp_ncSertif
select distinct
			 s.DatNom,
       t.nd,
       t.marsh,
       t.pin,
       s.op,
       s.SertifDoc,
       t.iscity,
       t.isnet,
       t.Remark,
       cast(0 as bit),
       iif(s.Act='НАКЛ',cast(0 as bit),cast(1 as bit))
from SertifLog s 
inner join #tmp_ncSertif t on t.datnom=s.datnom
where (t.docno & s.SertifDoc)<>0
      
delete from #tmp_ncSertif where isHead=1

create table #res (id int not null identity(1,1),
									 ResName varchar(200) not null default '',
                   PlanValue int,
                   FactValue int)
                   
declare curPersonal cursor for
select u.uin,
			 p.fio,
       iif(p.trID=14,cast(1 as bit),cast(0 as bit)) [isMenager]
from person p
inner join usrpwd u on u.p_id=p.p_id
where p.depid=19
			and p.closed=0
			and not u.uin in (30,119)
open curPersonal

fetch next from curPersonal into @uin, @fio, @isMenag

while @@fetch_status=0 
begin
	if @isMenag=1
  begin
  	insert into #res(ResName,PlanValue,FactValue)
    select @fio,0,0
    
    insert into #res(ResName,PlanValue,FactValue)
    select 'Количество отметок:',
    			 isnull(
    			 (select sum(a.ncount)
            from (select count(1) nCount
                  from #tmp_ncSertif
                  where patindex('%серт%',remark)<>0
                  group by datnom) a),0),
           isnull(
           (select sum(a.ncount)
            from (select count(1) nCount
                  from #tmp_ncSertif
                  where uin=@uin 
                  			and not docno in (0,256)
                  group by datnom) a),0)
  end
  else
  begin
  	insert into #res(ResName,PlanValue,FactValue)
    select @fio,0,0
    
    insert into #res(ResName,PlanValue,FactValue)
    select 'Количество отметок город:',
    			 isnull(
           (select sum(a.ncount)
            from (select count(1) nCount
                  from #tmp_ncSertif
                  where iscity=1
                  			and (isnet=0 and (patindex('%вет%',remark)<>0 or patindex('%в/с%',remark)<>0 or patindex('%в\с%',remark)<>0))or(isnet=1)
                  group by nd,pin) a),0),
           isnull(
           (select sum(a.ncount)
            from (select count(1) nCount
                  from #tmp_ncSertif
                  where uin=@uin 
                  			and not docno in (0,256) 
                        and (isnet=0 and (patindex('%вет%',remark)<>0 or patindex('%в/с%',remark)<>0 or patindex('%в\с%',remark)<>0))or(isnet=1)
                        and iscity=1                         
                  group by nd,pin) a),0)
                  
    insert into #res(ResName,PlanValue,FactValue)
    select 'Количество отметок область:',
    			 isnull(
    			 (select sum(a.ncount)
            from (select count(1) nCount
                  from #tmp_ncSertif
                  where iscity=0
                  			and (isnet=0 and (patindex('%вет%',remark)<>0 or patindex('%в/с%',remark)<>0 or patindex('%в\с%',remark)<>0))or(isnet=1)
                  group by nd,pin) a),0),
           isnull(
           (select sum(a.ncount)
            from (select count(1) nCount
                  from #tmp_ncSertif
                  where uin=@uin 
                  			and not docno in (0,256)
                        and (isnet=0 and (patindex('%вет%',remark)<>0 or patindex('%в/с%',remark)<>0 or patindex('%в\с%',remark)<>0))or(isnet=1) 
                        and iscity=0
                  group by nd,pin) a),0)
  end
  fetch next from curPersonal into @uin, @fio, @isMenag
end

close curPersonal
deallocate curPersonal

select ResName [Наименование],
			 PlanValue [План],
       FactValue [Факт] 
from #res

drop table #tmp_ncSertif
drop table #res
END