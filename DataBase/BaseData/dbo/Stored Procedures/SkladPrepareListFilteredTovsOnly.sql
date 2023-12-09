CREATE PROCEDURE dbo.SkladPrepareListFilteredTovsOnly
@skladlist varchar(500),
@nd datetime,
@type int,
@nnak int 
WITH RECOMPILE
AS
BEGIN
--set transaction isolation level read uncommitted
declare @dn1 int
declare @dn2 int

--SET @nd=IIF(DATEDIFF(HOUR,convert(varchar,getdate(),104),GETDATE())<7,DATEADD(day,-1,convert(varchar,getdate(),104)),convert(varchar,getdate(),104))
set @nd=convert(varchar, @nd, 104)
declare @tmEnd varchar(8)

set @tmEnd='18:00:00'
--/*
set @dn1=dbo.InDatNom(0,@nd)
SET @dn2=@dn1+9999
--*/
/*
set @dn1=dbo.InDatNom(0,dateadd(day,-1,@nd))
set @dn1=dbo.InDatNom(9999,@nd)
*/

if OBJECT_ID('tempdb..#s') is not null 
	drop table #s
	
create table #s (s int not null)
insert into #s
select distinct number
from dbo.String_to_Int(@skladlist,',',1) 	

create index tmp_skl_idx on #s(s)

if object_id('tempdb..#tZakaz') is not null
	drop table #tZakaz
	
create table #tZakaz (datnom int, hitag int, kol decimal(10,3), kg decimal(10,3), done bit, skladNo int, nzid INT)
											
insert into #tZakaz
select 	z.datnom,
        z.Hitag,
        z.Zakaz,
        z.Zakaz*isnull(n.netto,1),
        z.Done,
        z.skladNo,
        z.nzid
from nvZakaz z
inner join nomen n on n.hitag=z.hitag
where z.datnom between @dn1 and @dn2
			and z.skladNo in (select s from #s)

create index tmp_req_idx on #tZakaz(datnom,hitag);

if object_id('tempdb..#tRest') is not null
	drop table #tRest
	
create table #tRest (hitag int, rest decimal(10,3), isBlocked bit)

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
                    nzid int)
	insert into #tRes
	select 	cast(0 as bit),  
          nc.b_id,
          nc.datnom % 10000,
          case when z.skladNo in (201,202) then '' else '' end+case when #trest.isBlocked=1 then '' else '' end+nm.name,
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
          z.nzid					
	from #tZakaz z
	left join #trest on #trest.Hitag=z.hitag
  inner join nc on nc.datnom=z.datnom
  inner join Nomen nm on nm.hitag=z.hitag
  left join defcontract dc on nc.dck=dc.dck
  left join agentlist l on dc.ag_id=l.ag_id
	where z.done=0

update #tRes set NCPriority=1
from #tRes 
inner join ncpriority on #tRes.datnom=ncpriority.datnom
		
select 	r.isHeader, 
        r.B_ID,
        r.nNak,
--        case when @type<>4 and r.isHeader=1 then '['+isnull((select def.Reg_ID from def where def.pin=r.b_id),'')+']:'+r.Fam else r.Fam end as [Name],
		case when @type<>4 and r.isHeader=1 then '['+isnull((Regions.SkladReg),'')+']:'+r.Fam else r.Fam end as [Name],
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
        r.nzid
from #tRes r
left join nv_state ns on ns.tip=r.tip	
left join Deps on Deps.depid=r.depid
left join Def on Def.pin = r.b_id
left join Regions on Regions.Reg_ID = Def.Reg_ID
where r.nnak = @nnak
order by r.NCPriority desc,
         r.tip desc,
         --Deps.SeqNo,
         r.nNak, 
         r.b_id, 
         r.isHeader desc,
         4

drop table #s
drop table #tZakaz
drop table #tRest
drop table #tRes
END