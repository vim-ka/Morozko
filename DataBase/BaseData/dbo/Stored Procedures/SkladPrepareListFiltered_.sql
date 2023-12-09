CREATE procedure SkladPrepareListFiltered_
@SkladList varchar(200),  
@nd datetime, 
@type tinyint=0 -- @type=0-только заказы, 1-всё, 2-только продажи
as
declare @nom0 int, @nom1 int
begin
  set @nom0=dbo.InDatNom(1, @nd)
  set @nom1=dbo.InDatNom(9999, @nd)

  -- Список складов:
  create table #s (sklad int);
  insert into #s select k from dbo.Str2intarray(@skladList);
  create index tmp_skl_idx on #s(sklad);
  
  -- Сводка заказов по кодам:
  create table #z(hitag int, Zakaz decimal(12,3));
  insert into #z select hitag, sum(zakaz) zakaz from nvZakaz 
  where Done=0  and datnom>=@nom0 and datnom<=@nom1
  group by hitag;
  
  -- Сводка продаж по кодам:
  create table #p(hitag int, Zakaz decimal(12,3), Stored decimal(12,3));
  insert into #p 
  select nv.hitag, sum(z.zakaz) Zakaz, sum(nv.Kol*v.weight) Stored
  from 
    nvZakaz z 
    inner join NV on nv.datnom=z.datnom and nv.Hitag=z.hitag
    inner join tdvi v on v.id=nv.tekid
  where z.Done=1 and nv.tekid>0 and z.datnom>=@nom0 and z.datnom<=@nom1
  group by nv.hitag,nv.tekid;
  
  -- Остатки:
  create table #Rest(Hitag int, Rest decimal(12,3), isBlocked bit);
  
  insert into #rest
  select 	x.hitag,
					x.sm,
					case when exists(select * from tdvi where tdvi.sklad in (select sklad from #s) and tdvi.hitag=x.hitag and (tdvi.locked=1 or tdvi.lockid<>0)) then cast(1 as bit) else cast(0 as bit) end
	from (select v.hitag, sum(v.weight*(v.morn-v.sell+v.isprav-v.remov-v.rezerv)) [sm] 
				from tdvi v
				where v.sklad in (select sklad from #s)
				group by v.hitag) x
    
/*  insert into #rest
  select #z.hitag, sum(v.weight*(v.morn-v.sell+v.isprav-v.remov-v.rezerv)) 
  from #z inner join tdvi v on v.hitag=#z.hitag
  where v.sklad in (select sklad from #s)
  group by #z.hitag;
*/  
  create index r_temp_idx on #rest(hitag);

  create table #R(isHeader bit, B_ID int, Nnak int, Fam varchar(200),
    Hitag int, Zakaz int, Rest decimal(10,3), Tip tinyint, Stored decimal(10,3), DepID int, 
		NCPriority bit default 0, DatNom int);
  -- tip=10-заказ, tip=0-продажа.
    
      if @type<=1 begin
        -- Заголовок заказа (клиент):
        insert into #R
        SELECT distinct
          cast(1 as bit) isHeader,  
          nc.B_ID,
          nc.datnom % 10000 as Nnak,
          nc.fam +' ('+ d.Dname+')' as Name, 
          null as hitag,
          null as Zakaz,
          null as Rest,
          10 as tip, null as stored,
          d.DepID,
					cast(0 as bit),
					nz.datnom
        FROM  
          nvzakaz nz
          inner join tdvi v on v.hitag=nz.hitag
          inner join #s on #s.sklad=v.sklad
          inner join nc on nc.datnom=nz.datnom
          left join defcontract dc on nc.dck=dc.dck
          left join agentlist a on dc.ag_id=a.ag_id
          left join Deps d on a.DepID=d.DepID
        where 
          nc.nd = @ND
          and nz.done=0

        -- Детализация заказа:
        insert into #R
        SELECT
          cast(0 as bit) isHeader,  
          nc.b_id,
          nc.datnom % 10000 as Nnak,
          case when #rest.isBlocked=1 then '***'+nm.name else nm.name end [name],
          nz.hitag,
          nz.Zakaz,
          #rest.Rest,
          10 as tip, null as stored,
          l.DepID,
					cast(0 as bit),
					nz.datnom
        FROM  
          nvzakaz nz
          inner join #rest on #rest.Hitag=nz.hitag
          inner join nc on nc.datnom=nz.datnom
          inner join Nomen nm on nm.hitag=nz.hitag
          left join defcontract dc on nc.dck=dc.dck
          left join agentlist l on dc.ag_id=l.ag_id
        where 
          nc.nd = @ND
          and nz.done=0 
          and nc.datnom % 10000 in (select nnak from #r)
      end;
          
    if @type>0       
    begin  
      -- Заголовок продаж (клиент):
      insert into #R
      SELECT distinct
        cast(1 as bit) isHeader,  
        nc.B_ID,
        null as Nnak,
				nc.fam as Name, 
        null as hitag,
        null as Zakaz,
        null as Rest,
        0 as tip, null as stored,
        d.DepID,
				cast(0 as bit),
				nz.datnom
      FROM  
        nvzakaz nz
        inner join tdvi v on v.hitag=nz.hitag
        inner join #s on #s.sklad=v.sklad
        inner join nc on nc.datnom=nz.datnom
        left join defcontract dc on nc.dck=dc.dck
        left join agentlist a on dc.ag_id=a.ag_id
        left join Deps d on a.DepID=d.DepID
      where 
        nc.nd = @ND
        and nz.done=1 
				and nc.marsh= case when @type=3 then 0 else nc.marsh end
      
      union

      -- Детализация продаж:
      
      SELECT
        cast(0 as bit) isHeader,  
        nc.b_id,
        nc.datnom % 10000 as Nnak,
				case when #rest.isBlocked=1 then '***'+nm.name else nm.name end [name],
        nz.hitag,
        nz.Zakaz, 
        #rest.Rest,
        0 as tip, nv.kol*vi.weight as Stored,
        l.DepID,
				cast(0 as bit),
				nc.datnom
      FROM  
        nc 
        inner join nvzakaz nz on nc.datnom=nz.datnom
        inner join nv on nv.datnom=nz.datnom and nv.hitag=nz.hitag
        left join #rest on #rest.hitag=nz.hitag
        inner join Nomen nm on nm.hitag=nz.hitag
        inner join tdvi vi on vi.id=nv.tekid
         inner join #s on #s.sklad=vi.sklad
        left join defcontract dc on nc.dck=dc.dck
        left join agentlist l on dc.ag_id=l.ag_id
      where 
        nc.nd = @nd
        and nz.done=1 
        -- and vi.sklad in (select sklad from #s)
				and nc.marsh= case when @type=3 then 0 else nc.marsh end;
		end

update #r set NCPriority=1
from #r 
inner join ncpriority on #r.datnom=ncpriority.datnom
		
select 	#r.isHeader, 
				#r.B_ID,
				#r.nNak,
				case when #r.isHeader=1 then '['+(select def.Reg_ID from def where def.pin=#r.b_id)+']:'+#r.Fam else #r.Fam end as [Name],
				#r.hitag,
				#r.zakaz,
				cast(#r.Rest as decimal(12,1)) [Rest],
				#r.tip,
				#r.stored,
				#r.depid,
				IIF(#r.isHeader=1,null, ns.TipName) as TipName,
				#r.datnom,
				(select count(a.datnom) from (select distinct datnom from #r) a) [cnt]
from
	 #r
	 left join nomen nm on nm.hitag=#r.hitag
	 left join nv_state ns on ns.tip=#r.tip
	 left join Deps on Deps.depid=#r.depid
order by #r.NCPriority desc, #r.tip desc,Deps.SeqNo,#r.b_id, #r.isHeader desc, nm.Name
END