CREATE PROCEDURE dbo.SkladPrepareListFiltered_Debug
@skladlist varchar(500),
@nd datetime,
@type int=0 
WITH RECOMPILE
AS
BEGIN
set transaction isolation level read uncommitted
set @nd=convert(varchar,getdate(),104)
declare @dn1 int
declare @dn2 int
declare @tmEnd varchar(8)

set @tmEnd='18:00:00'
set @dn1=dbo.InDatNom(0,dateadd(day,-1,@nd))
set @dn2=dbo.InDatNom(9999,@nd)
--set @dn2=@dn1+9999
if OBJECT_ID('tempdb..#s') is not null 
	drop table #s
	
create table #s (s int not null)
insert into #s
select distinct number
from dbo.String_to_Int(@skladlist,',',1) 	

create index tmp_skl_idx on #s(s)

if object_id('tempdb..#tZakaz') is not null
	drop table #tZakaz
	
create table #tZakaz (datnom int,
					  hitag int,
					  kol decimal(10,3),
                      kg decimal(10,3),
					  done bit,
                      skladNo int,
                      tm varchar(8),
                      nzid INT,
                      curWeight DECIMAL(10,3))
											
insert into #tZakaz
select 	z.datnom,
		z.Hitag,
		z.Zakaz,
        z.Zakaz*isnull(n.netto,1),
		z.Done,
        z.skladNo,
        z.tm,
        z.nzid,
        z.curWeight
from nvZakaz z
inner join nomen n on n.hitag=z.hitag
where z.datnom between @dn1 and @dn2
			and z.skladNo in (select s from #s)

create index tmp_req_idx on #tZakaz(datnom,hitag);

if object_id('tempdb..#tRest') is not null
	drop table #tRest
	
create table #tRest (hitag int,
                     rest decimal(10,3),
                     isBlocked bit)

insert into #tRest
select t.HITAG,
       isnull(sum(case when n.flgWeight=1 then t.weight*(t.morn-t.sell+t.isprav-t.remov-t.rezerv) else (t.morn-t.sell+t.isprav-t.remov-t.rezerv) end),0),
       case when exists(select * from tdvi where tdvi.sklad in (select sklad from #s) and tdvi.hitag=t.hitag and (tdvi.locked=1 or tdvi.lockid<>0)) then cast(1 as bit) else cast(0 as bit) end
from tdVi t 
left join nomen n on n.hitag=t.hitag
where t.LOCKED=0
			and t.LockID=0			
      and t.sklad in (select s from #s)
      and t.hitag in (select hitag from #tZakaz)
group by t.HITAG

create index r_temp_idx on #tRest(hitag);

if object_id('tempdb..#tRes') is not null
	drop table #tRes

create table #tRes(	isHeader bit, 
                    B_ID int, 
                    Nnak int, 
                    Fam varchar(200),
                    Hitag int, 
                    [Zakaz] int,
                    [ZakazKG] decimal(10,3), 
                    Rest decimal(10,3), 
                    Tip tinyint, 
                    Stored decimal(10,3), 
                    DepID int, 
                    [NCPriority] bit default 0, 
                    DatNom int,
                    flgWeight bit default 1,
                    isFar bit default 0,
                    marsh int)
--только заказы
insert into #tRes
select 	cast(1 as bit),  
        c.B_ID,
        c.datnom % 10000 as Nnak,
        c.fam +' ('+ isnull(d.Dname,'отдел не определен')+')', 
        null,
        null,
        null,
        null,
        10, 
        null,
        d.DepID,
        case when exists(select 1 from #tZakaz b where b.datnom=c.datnom and b.skladNo in (201,202)) then cast(1 as bit) else cast(0 as bit) end,
        c.datnom,
        0,
        cast(0 as bit),
        c.Marsh					
from #tZakaz z
inner join nc c on c.DatNom=z.datnom
inner join defcontract dc on c.dck=dc.dck
left join agentlist a on dc.ag_id=a.ag_id
left join Deps d on a.DepID=d.DepID
where z.done=0 
 	  and z.kol>0    
group by c.b_id,c.datnom,c.fam,d.dname,d.depid,c.Marsh
	
insert into #tRes
select 	cast(0 as bit),  
      	c.b_id,
      	c.datnom % 10000,
      	case when z.skladNo in (201,202) then '[REST]' else '' end+case when #trest.isBlocked=1 then '***' else '' end+
      	--cast((row_number() over(partition by z.datnom order by z.nzid)) as varchar)+'. '+
      	nm.name,
      	z.hitag,
      	z.kol,
      	z.kg,
      	isnull(#trest.Rest,0) [Rest],
      	10, 
      	null,
      	l.DepID,
      	case when z.skladNo in (201,202) then cast(1 as bit) else cast(0 as bit) end,
      	z.datnom,
      	nm.flgWeight,
      	iif((not d.reg_id like '%[абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ]%') and datediff(minute,z.tm,@tmEnd)<0,cast(1 as bit),cast(0 as bit)),
        c.Marsh					
from #tZakaz z
left join #trest on #trest.Hitag=z.hitag
inner join nc c on c.datnom=z.datnom
left join def d on c.b_id=d.pin
inner join Nomen nm on nm.hitag=z.hitag
left join defcontract dc on c.dck=dc.dck
left join agentlist l on dc.ag_id=l.ag_id
where z.done=0 
	  and z.kol>0

insert into #tRes
select 	cast(1 as bit),  
    c.B_ID,
    c.datnom % 10000 as Nnak,
    c.fam +' ('+ isnull(d.Dname,'отдел не определен')+')', 
    null,
    null,
    null,
    null,
    10, 
    null,
    d.DepID,
    case when exists(select 1 from #tZakaz b where b.datnom=c.datnom and b.skladNo in (201,202)) then cast(1 as bit) else cast(0 as bit) end,
    c.datnom,
    0,
    cast(0 as bit),
    c.Marsh					
from #tZakaz z
inner join nc c on c.DatNom=z.datnom
inner join defcontract dc on c.dck=dc.dck
left join agentlist a on dc.ag_id=a.ag_id
left join Deps d on a.DepID=d.DepID
where z.done=0 
	  and z.kol<0
group by c.b_id,c.datnom,c.fam,d.dname,d.depid,c.Marsh
  	
insert into #tRes
select 	cast(0 as bit),  
    c.b_id,
    c.datnom % 10000,
    case when z.skladNo in (201,202) then '[REST]' else '' end+case when #trest.isBlocked=1 then '***' else '' end+
    --cast((row_number() over(partition by z.datnom order by z.nzid)) as varchar)+'. '+
    nm.name,
    z.hitag,
    z.kol,
    z.curWeight,
    isnull(#trest.Rest,0) [Rest],
    10, 
    null,
    l.DepID,
    case when z.skladNo in (201,202) then cast(1 as bit) else cast(0 as bit) end,
    z.datnom,
    nm.flgWeight,
    cast(0 as bit),
    c.Marsh					
from #tZakaz z
left join #trest on #trest.Hitag=z.hitag
inner join nc c on c.datnom=z.datnom
left join def d on c.b_id=d.pin
inner join Nomen nm on nm.hitag=z.hitag
left join defcontract dc on c.dck=dc.dck
left join agentlist l on dc.ag_id=l.ag_id
where z.done=0 
 	  and z.kol<0

update #tRes set NCPriority=1
from #tRes 
inner join ncpriority on #tRes.datnom=ncpriority.datnom

update #tRes set NCPriority=1
from #tRes 
inner join (SELECT DISTINCT datnom FROM #tRes r where Zakaz<0) c on #tRes.datnom=c.datnom

		
select 	r.isHeader, 
		r.B_ID,
		r.nNak,
		--case when @type<>4 and r.isHeader=1 then '['+isnull((select def.Reg_ID from def where def.pin=r.b_id),'')+']:'+r.Fam else r.Fam end as [Name],
        case when @type<>4 and r.isHeader=1 then '['+isnull(r1.SkladReg,'')+'#'+cast(r.marsh as varchar)+']:'+r.Fam else r.Fam end as [Name],
		r.hitag,
		r.zakaz,
        cast(r.Rest as decimal(12,1)) [Rest],
		r.tip,
		r.stored,
		r.depid,
		IIF(r.isHeader=1,null, ns.TipName) as TipName,
		r.datnom,
		(select count(a.datnom) from (select distinct datnom from #tRes) a) [cnt],
        r.flgWeight,
		r.zakazKG,
        r.isFar,
        r.marsh
from #tRes r
LEFT JOIN Def d ON r.b_id=D.pin
LEFT JOIN Regions r1 ON d.Reg_ID = r1.Reg_ID
left join nv_state ns on ns.tip=r.tip	
left join Deps on Deps.depid=r.depid
where r.marsh=64
order by --r.NCPriority desc,
		 --r.tip desc,
		 --Deps.SeqNo,
		 --IIF(r1.SkladReg like  '%[Ъъ]%',0,iif(r1.SkladReg like  '%[А-яЁё]%',r.nNak*10000,r.Nnak)),
         iif(r.marsh in (0,99),r.datnom,r.marsh),
		 r.datnom,
         --.b_id, 
		 r.isHeader desc
         --r.fam
         --4

drop table #s
drop table #tZakaz
drop table #tRest
drop table #tRes
END