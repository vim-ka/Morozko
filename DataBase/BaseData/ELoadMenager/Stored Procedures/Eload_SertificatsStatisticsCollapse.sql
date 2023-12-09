CREATE PROCEDURE ELoadMenager.Eload_SertificatsStatisticsCollapse
@nd1 datetime,
@nd2 datetime
as
begin
declare @dat1 int
declare @dat2 int
declare @dno int
declare @markcount int
declare @netmarkcount int

set @dat1=dbo.InDatNom(0, @nd1) 
set @dat2=dbo.InDatNom(9999, @nd2)

if object_id('tempdb..#tmpnc') is not null drop table #tmpnc

select c.datnom, 
			 dbo.indatnom(9000+c.marsh,c.nd) [marsh], 
       c.remark+' '+c.RemarkOp [rem], 
       c.SertifDoc, 
       cast(iif(exists(select 1 
       					from dbo.defcontract dc 
                inner join dbo.AgentList al on dc.ag_id=al.AG_ID 
                where dc.pin=d.pin 
                			and al.DepID=3),1,0) as bit) [isNet]
into #tmpNC
from dbo.nc c
inner join dbo.def d on c.b_id=d.pin
where c.datnom>=@dat1
			and c.datnom<=@dat2
			and c.Marsh<>99
      and d.tip=1
      and (c.Remark like '%вет%' or
      	   c.Remark like '%свид%' or
      		 c.Remark like '%общ%' or
      		 c.Remark like '%доку%' or
           c.RemarkOp like '%вет%' or
      	   c.RemarkOp like '%свид%' or
      		 c.RemarkOp like '%общ%' or
      		 c.RemarkOp like '%доку%' or
           exists(select 1 from dbo.defcontract dc inner join dbo.AgentList al on dc.ag_id=al.AG_ID where dc.pin=d.pin and al.DepID=3) or
           exists(select 1 
      					 from dbo.nv v 
                 inner join dbo.nomen n on n.hitag=v.hitag
                 inner join dbo.gr g on g.ngrp=n.ngrp
                 where g.vet=1
                 			 and v.datnom=c.datnom) or
           c.sertifdoc<>0)
           
create nonclustered index idx_tmpnc on #tmpnc([sertifdoc])                                  
create nonclustered index idx_tmpnc1 on #tmpnc([marsh])
create nonclustered index idx_tmpnc2 on #tmpnc([datnom])
create nonclustered index idx_tmpnc3 on #tmpnc([isnet])
       
if object_id('tempdb..#res') is not null drop table #res

select sd.dNo,
			 sd.dName
into #res       
from dbo.SertifDoc sd 

insert into #res 
select -1, 'Ремарки'

alter table #res add MarkCount int,
                     NetMarkCount int

declare upd_cur cursor for
select dno from #res
open upd_cur
fetch next from upd_cur into @dno
while @@fetch_status=0
begin
	if @dno>0
  begin
	if @dno=16
	update #res set markcount=(select count(distinct [marsh]) from #tmpnc where sertifdoc&@dno<>0),
  								netmarkcount=(select count(distinct [marsh]) from #tmpnc where sertifdoc&@dno<>0 and isnet=1)
  where dno=@dno
	else
  update #res set markcount=(select count(distinct [datnom]) from #tmpnc where sertifdoc&@dno<>0),
  								netmarkcount=(select count(distinct [datnom]) from #tmpnc where sertifdoc&@dno<>0 and isnet=1)
  where dno=@dno
  end
  else
  update #res set markcount=(select count(distinct [datnom]) from #tmpnc where isnet=0),
  								netmarkcount=(select count(distinct [datnom]) from #tmpnc where sertifdoc&256<>0 and SertifDoc>0 and isnet=0)
  where dno=@dno
  
  fetch next from upd_cur into @dno
end
close upd_cur
deallocate upd_cur

select dName [Наименование],
			 MarkCount [Отметки],
       NetMarkCount [ОтметкиСети] 
from #res
       
drop table #tmpnc       
drop table #res
end