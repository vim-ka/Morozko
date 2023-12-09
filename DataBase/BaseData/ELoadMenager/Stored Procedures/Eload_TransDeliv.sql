CREATE PROCEDURE ELoadMenager.[Eload_TransDeliv] 
@day0 datetime, 
@day1 datetime,
@ngrp int = 0
as
begin
  declare @datnom1 int, @datnom2 int
  set @datnom1=dbo.InDatnom(0,@day0)
  set @datnom2=dbo.InDatnom(9999,@day1)
   
 
  -- извлекаю важную информацию из накладных:
  create table #nc ([nd] datetime, [datnom] int, [sp] decimal(10,2), [sc] decimal(10,2), 
    							  [vmaster] int, [weight] decimal(10,3), [marsh] int, [ndm] varchar(30), 
                    [ag_id] int, [depid] int, [mhid] int);
  
  -- получается такая сильно усеченная по ширине таблица накладных:
  insert into #nc(nd,DatNom,sp,sc,vmaster,weight,marsh,ndm,ag_id,depid,mhid)
  select c.nd, c.datnom, c.sp, c.sc, case when d.vmaster=0 then d.pin else d.vmaster end as VMaster,
    		 c.weight, isnull(m.marsh,0) as marsh, convert(varchar,c.nd)+'-'+cast(isnull(m.marsh,0) as varchar(3)) [ndm],
    		 c.ag_id, s.depid,c.mhid
  from dbo.nc c
 -- join dbo.nv v with (index(nv_datnom_idx)) on v.datnom=c.datnom
 --join dbo.nomen n on n.hitag=v.hitag
  join dbo.def d on d.pin=c.b_id 
  join dbo.agentlist a on a.ag_id=c.ag_id
  join dbo.agentList s on s.ag_id=a.sv_ag_id
  left join Marsh m on c.mhid=m.mhid
  where c.datnom>=@datnom1 and c.datnom<=@datnom2 and c.frizer=0 and c.tara=0 and c.stip<>4
        and c.weight<>0
        and (isnull(m.marsh,0)>0 or (c.sp<0 and c.remark<>'')) and isnull(m.SelfShip,0)<>1
    --    and (n.ngrp in (select value [ngrp] from string_split(dbo.getgrchild(@ngrp),',')) or @ngrp=0)
    
  create index nc_ndm_idx on #nc(NDM);
  
  -- Теперь свернем ее по номерам маршрутов - это понадобится, чтобы рассчитать 
  -- полный вес каждого маршрута и соответственно долю каждой накладной:
  create table #s ([nd] datetime, [marsh] int, [ndm] varchar(30), [weight] decimal(12,3), 
  								 [sp] decimal(10,2), [sc] decimal(10,2), [rashod] decimal(10,2), [kolnakl] int);
    
  -- По-новой рассчитываю суммарный вес кажого маршрута за период:
  insert into #s(nd,marsh, NDM, weight,sp,sc,rashod,kolnakl)  
  select c.nd, c.marsh, convert(varchar,c.nd)+'-'+cast(c.marsh as varchar(3)) [ndm],
    		 sum(c.weight) [weight], 
             sum(c.sp) [sp],
             sum(c.sc) [sc], 
    		 isnull(case when m.nd<='20120212' then m.oplatasum else m.oplatasum+m.percworkpay end,0) [rashod],
    		 count(c.datnom)
  from #nc c
  left join nearlogistic.nllistpaydet m on m.mhid=c.mhid
  group by c.nd, c.marsh, isnull(case when m.nd<='20120212' then m.oplatasum else m.oplatasum+m.percworkpay end,0)
  order by c.nd, c.marsh;

  -- Теперь выдергиваю отдельные накладные (интересует главным образом отдел!) 
  -- и для каждой считаю ее весовую долю общем весе маршрута, и пропорционально
  -- раскидываю на нее соотв. часть расходов по маршруту:

  select @day0 [day0], @day1 [day1], e.depid, d.dname, sum(e.weight) [weight],
    		 round(sum(e.koeff),1) [kolmarsh], round(sum(e.rashod),2) [rashod],
    		 round(sum(e.weight)/sum(e.koeff),1) [avgzagruz], sum(e.dots) [dots],
    		 round(sum(e.rashod)/sum(e.weight),3) [rashod1kg], round((sum(e.sp)-sum(e.sc))/sum(e.weight),3) [dohod1kg],
    		 round(sum(e.rashod)/sum(e.sp),3) [rashod1rub], round(sum(e.rashod)/sum(e.dots),2) [rashod1dot],
    		 round(sum(e.sp),2) [sp], round(sum(e.sc),2) [sc], 
         case when e.depid in (6,26) then 2 
    		 		  when e.depid in (43) then 3
    		  	  else 1 end [grp]
  from (select c.depid, sum(c.weight) [weight], sum(c.weight)/#s.weight [partweight], sum(c.sp) [sp], #s.sp [totalsp],
        		   sum(c.sc) [sc], #s.sc [totalsc], round(sum(c.[weight] / #s.weight * #s.rashod),2) [rashod],
        			 count(c.datnom) [ncnaklcount], #s.kolnakl [totalnakl], round(1.0*count(c.datnom)/#s.kolnakl,3) [koeff],    
        			 count(distinct c.vmaster) [dots], count(distinct #s.ndm) [marshcount]
      	from #nc c 
      	join #s on #s.ndm=c.ndm
      	group by c.depid, #s.sp, #s.sc, #s.kolnakl, #s.weight) e
  join dbo.deps d on d.depid=e.depid
  group by e.depid, d.dname, case when e.depid in (6,26) then e.depid else 1 end
  order by grp,  e.depid
end;