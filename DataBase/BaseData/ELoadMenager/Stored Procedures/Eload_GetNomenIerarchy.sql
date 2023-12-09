CREATE procedure ELoadMenager.Eload_GetNomenIerarchy
@depid int
as
begin
declare @level int

if object_id('tempdb..#goods') is not null drop table #goods
if object_id('tempdb..#cats') is not null drop table #cats
if object_id('tempdb..#res') is not null drop table #res

select n.hitag,
			 n.ngrp,
			 n.name,
			 max(v.price) [price],
       '.0.'+cast(row_number() over(partition by n.[ngrp] order by n.[name]) as varchar) [lvl],
       0 [ord]
into #goods        
from dbo.tdvi v 
left join dbo.skladlist s on v.sklad=s.skladNo
inner join dbo.nomen n on v.hitag=n.hitag                                
left join dbo.SkladGroups g on s.skg=g.skg
where v.locked=0 
      and s.locked=0 
      and s.agInvis=0 
      and s.Discard=0
      and n.ngrp not in (select ngrp from gr where AgInvis=1)      
group by n.hitag, n.name, n.ngrp

insert into #goods
select n.hitag,
			 n.ngrp,
			 n.name,
			 -1 [price],
       '.0.'+cast(row_number() over(partition by n.[ngrp] order by n.[name]) as varchar) [lvl],
       0 [ord]
from dbo.nomen n
join dbo.gr g on n.ngrp=g.ngrp
where g.AgInvis=0
			and not n.hitag in (select hitag from #goods)

update g set [ord]=isnull(m.ord,0)
from #goods g 
left join (select * from dbo.mtprior where depid=@depid) m on m.hitag=g.hitag

update g set [ord]=isnull(m.ord,0)
from #goods g 
left join (select * from dbo.mtprior where depid=0) m on m.hitag=g.hitag
where isnull(g.[ord],0)=0

select g.ngrp,
			 g.parent,
			 g.GrpName [name]
into #cats       
from dbo.gr g 
where g.AgInvis=0

create table #res ([name] varchar(200), [price] decimal(15,2), [ngrp] int, [parent] int, [level] int, [lvl] varchar(100), [ord] int)

insert into #res
select [name],0,ngrp,ngrp,0,cast(ngrp as varchar),-1
from #cats
where parent=0   

delete from #cats where parent=0   
set @level=1

while exists(select 1 from #cats)
begin
	insert into #res
  select c.[name],0,c.ngrp,c.parent,@level,x.[lvl]+'.'+cast(c.ngrp as varchar),-1
  from #cats c 
  inner join (select * from #res where [level]=@level-1) x on x.ngrp=c.parent
  
  delete from #cats where ngrp in (select ngrp from #res where [level]=@level)
	
  set @level=@level+1
end

insert into #res
select g.name, 
			 g.price, 
       g.hitag, 
       g.ngrp,
       99,
       r.[lvl]+'.0'/*g.[lvl]*/,
       g.ord
from #goods g
inner join #res r on r.ngrp=g.ngrp

select iif([ord]=0,'0',cast([ord] as varchar)) [Порядок],
			 replace(dbo.RemoveMask('%[0-9]%',[lvl]),'.','--' )+
			 [name] [Наименование],
			 iif([price]=-1 or [price]=0,'',cast([price] as varchar)) [Стоимость],
       cast(iif([level]=99,0,1) as bit) [Группа],
       cast(iif([price]=-1,0,1) as bit) [Остатки],
       [lvl] [порядок] 
from #res
order by [lvl],iif([ord]=0,999,[ord]),[name]

if object_id('tempdb..#goods') is not null drop table #goods
if object_id('tempdb..#cats') is not null drop table #cats
if object_id('tempdb..#res') is not null drop table #res
end