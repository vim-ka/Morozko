CREATE procedure SkladPrepareList @SkladList varchar(200),  @nd datetime
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
  
  select e.*, IIF(e.isHeader=1,null, ns.TipName) as TipName 
  from (

      -- Заголовок заказа (клиент):
      SELECT distinct
        cast(1 as bit) isHeader,  
        nc.B_ID,
        null as Nnak,
		nc.fam +' ('+ d.Dname+')' as Name, 
        null as hitag,
        null as Zakaz,
        null as Rest,
        10 as tip, null as stored,
        d.DepID
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

        UNION ALL
      
      -- Детализация заказа:
      SELECT
        cast(0 as bit) isHeader,  
        nc.b_id,
        nc.datnom % 10000 as Nnak,
		nm.name,
        nz.hitag,
        nz.Zakaz,
        A.Rest,
        10 as tip, null as stored,
        l.DepID
      FROM  
        nvzakaz nz
        inner join (
          select hitag, sum(v.morn-v.sell+v.isprav-v.remov-v.rezerv) as Rest 
          from tdvi v 
            inner join #s on #s.sklad=v.sklad
          group by hitag
          ) A on A.Hitag=nz.hitag
        inner join nc on nc.datnom=nz.datnom
        inner join Nomen nm on nm.hitag=nz.hitag
        left join defcontract dc on nc.dck=dc.dck
        left join agentlist l on dc.ag_id=l.ag_id
      where 
        nc.nd = @ND
        and nz.done=0 

      union
      
      -- Заголовок продаж (клиент):
      SELECT distinct
        cast(1 as bit) isHeader,  
        nc.B_ID,
        null as Nnak,
		nc.fam as Name, 
        null as hitag,
        null as Zakaz,
        null as Rest,
        0 as tip, null as stored,
        d.DepID
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
      
      union

      -- Детализация заказа:
      
      SELECT
        cast(0 as bit) isHeader,  
        nc.b_id,
        nc.datnom % 10000 as Nnak,
		nm.name,
        nz.hitag,
        nz.Zakaz, 
        a.rest,
        0 as tip, nv.kol*vi.weight as Stored,
        l.DepID
      FROM  
        nvzakaz nz
        inner join nv on nv.datnom=nz.datnom and nv.hitag=nz.hitag
        inner join (select hitag, sum(v.morn-v.sell+v.isprav-v.remov-v.rezerv) as Rest from tdvi v group by hitag)A on A.Hitag=nz.hitag
        inner join nc on nc.datnom=nz.datnom
        inner join Nomen nm on nm.hitag=nz.hitag
        inner join tdvi vi on vi.id=nv.tekid
        inner join #s on #s.sklad=vi.sklad
        left join defcontract dc on nc.dck=dc.dck
        left join agentlist l on dc.ag_id=l.ag_id
      where 
        nc.nd = @nd
        and nz.done=1 
        
        /*
        
        
        
        inner join (select v.hitag, sum(v.morn-v.sell+v.isprav-v.remov) as Rest 
          from tdvi v 
          inner join #z on #z.hitag=v.hitag
          inner join #s on #s.sklad=v.sklad -- where v.sklad in (select sklad from #s) 
          group by v.hitag          
          ) W on w.hitag=#z.hitag
        inner join nomen nm on nm.hitag=#z.hitag

      union all

      -- Детализация заказа:
      SELECT 
        cast(0 as bit) isHeader, z.datnom % 10000 as Nnak,
        z.hitag, nc.fam as Name, z.Zakaz,
        null as Rest, 10 as tip, null as stored
      FROM  
        nvZakaz z
        inner join nomen nm on nm.hitag=z.hitag
        inner join nc on nc.datnom=z.datnom
      where z.datnom>=@nom0 and z.datnom<=@nom1 and z.Done=0
	  group by      
        z.datnom, z.hitag, nc.fam, z.Zakaz
        
      union all
        
      -- Заголовок продаж:
      SELECT 
        cast(1 as bit) isHeader,  null as Nnak,
        #p.hitag, nm.name, #p.Zakaz as Zakaz,
        null as Rest,  0 as tip, #p.stored
      FROM  
        #p
        inner join nomen nm on nm.hitag=#p.hitag
        
      union all 
      
      -- Детализация продаж:
      SELECT 
        cast(0 as bit) isHeader, z.datnom % 10000 as Nnak,
        z.hitag, nc.fam as Name, z.Zakaz,
        null as Rest,  0 as tip, nv.kol*v.weight as Stored
      FROM  
        nvZakaz z
        inner join nv on nv.datnom=z.datnom and nv.hitag=z.hitag
        inner join tdvi v on v.id=nv.tekid
        inner join nc on nc.datnom=z.datnom
      where z.datnom>=@nom0 and z.datnom<=@nom1 and z.Done=1
      group by z.datnom, z.hitag, nc.fam, z.Zakaz, nv.kol, v.weight
      */

        
)E left join nv_state ns on ns.tip=e.tip
order by e.tip desc,e.DepID desc,e.b_id, e.isHeader desc, e.Name
END