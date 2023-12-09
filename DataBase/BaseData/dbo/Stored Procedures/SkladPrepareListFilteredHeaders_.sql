CREATE PROCEDURE dbo.SkladPrepareListFilteredHeaders_ --старая процедура
@skladlist varchar(500),
@nd datetime,
@type int 
WITH RECOMPILE
AS
BEGIN
--set transaction isolation level read uncommitted
declare @dn1 int
declare @dn2 int

--SET @nd=IIF(DATEDIFF(HOUR,convert(varchar,getdate(),104),GETDATE())<7,DATEADD(day,-1,convert(varchar,getdate(),104)),convert(varchar,getdate(),104))
set @nd=convert(varchar,getdate(),104)
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

create table #tZakaz (datnom int, hitag int, kol decimal(10,3), kg decimal(10,3), done bit, skladNo int)
											
insert into #tZakaz
select 	z.datnom,
        z.Hitag,
        z.Zakaz,
        z.Zakaz*isnull(n.netto,1),
        z.Done,
        z.skladNo
from nvZakaz z
inner join nomen n on n.hitag=z.hitag
where z.datnom between @dn1 and @dn2
			and z.skladNo in (select s from #s)

create index tmp_req_idx on #tZakaz(datnom,hitag);


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
                    flgWeight bit default 1)

insert into #tRes
select 	cast(1 as bit),  
      c.B_ID,
      c.datnom % 10000 as Nnak,
      c.fam +' ('+ d.Dname+')', 
      null,
      null,
      null,
      null,
      10, 
      null,
      d.DepID,
      case when exists(select 1 from #tZakaz b where b.datnom=c.datnom and b.skladNo in (201,202)) then cast(1 as bit) else cast(0 as bit) end,
      c.datnom,
      0					
from #tZakaz z
inner join nc c on c.DatNom=z.datnom
inner join defcontract dc on c.dck=dc.dck
inner join agentlist a on dc.ag_id=a.ag_id
inner join Deps d on a.DepID=d.DepID
where z.done=0
group by c.b_id,c.datnom,c.fam,d.dname,d.depid    
    
update #tRes set NCPriority=1
from #tRes 
inner join ncpriority on #tRes.datnom=ncpriority.datnom
		
select 	r.isHeader, 
				r.B_ID,
				r.nNak,
--				case when @type<>4 and r.isHeader=1 then '['+isnull((select def.Reg_ID from def where def.pin=r.b_id),'')+']:'+r.Fam else r.Fam end as [Name],
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
				r.zakazKG
from #tRes r
left join nv_state ns on ns.tip=r.tip	
left join Deps on Deps.depid=r.depid
left join Def on Def.pin = r.b_id
left join Regions on Regions.Reg_ID = Def.Reg_ID
order by  r.NCPriority desc,
          r.tip desc,
          --Deps.SeqNo,
          r.nNak, 
          r.b_id, 
          r.isHeader desc,
          4    

drop table #s
drop table #tZakaz
drop table #tRes
END