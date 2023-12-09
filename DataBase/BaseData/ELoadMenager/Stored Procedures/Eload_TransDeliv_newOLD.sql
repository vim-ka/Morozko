

CREATE PROCEDURE ELoadMenager.[Eload_TransDeliv_newOLD] 
@day0 datetime, 
@day1 datetime,
@ngrp int = 0
as
begin
  declare @datnom1 int, @datnom2 int
  set @datnom1=dbo.InDatnom(0,@day0)
  set @datnom2=dbo.InDatnom(9999,@day1)
   
 
  -- извлекаю важную информацию из накладных:
  create table #nc ([datnom] int, [sp] decimal(10,2), [sc] decimal(10,2), 
   				   [vmaster] int, [weight] decimal(10,3), [ag_id] int, [depid] int, [mhid] int);
  
  -- получается такая сильно усеченная по ширине таблица накладных:
  insert into #nc(DatNom,sp,sc,vmaster,weight,ag_id,depid,mhid)
  select  c.datnom, sum((1+c.extra/100)*v.kol*v.price), sum(v.kol*v.cost),case when d.vmaster=0 then d.pin else d.vmaster end as VMaster, c.weight, c.ag_id, s.depid,c.mhid
  from dbo.nc c
  join dbo.nv v with (index(nv_datnom_idx)) on v.datnom=c.datnom
  join dbo.nomen n on n.hitag=v.hitag
  join dbo.def d on d.pin=c.b_id 
  join dbo.agentlist a on a.ag_id=c.ag_id
  join dbo.agentList s on s.ag_id=a.sv_ag_id
  left join dbo.marsh m on c.mhid=m.mhid 
  where c.datnom>=@datnom1 and c.datnom<=@datnom2 and c.frizer=0 and c.tara=0 and c.stip<>4
        and c.weight<>0
        and (c.mhid>0 or (c.sp<0 and c.remark<>'')) and isnull(m.SelfShip,0)<>1
        and (n.ngrp in (select value [ngrp] from string_split(dbo.getgrchild(@ngrp),',')) or @ngrp=0)
  group by c.datnom, case when d.vmaster=0 then d.pin else d.vmaster end , c.weight, c.ag_id, s.depid,c.mhid      
        
    
  create index nc_ndm_idx on #nc(mhid);
  
  -- Теперь свернем ее по номерам маршрутов - это понадобится, чтобы рассчитать 
  -- полный вес каждого маршрута и соответственно долю каждой накладной:
  create table #s ([weight] decimal(12,3), [sp] decimal(10,2), [sc] decimal(10,2), [rashod] decimal(10,2), [kolnakl] int, [mhid] int, crid int);
    
  -- По-новой рассчитываю суммарный вес кажого маршрута за период:
  insert into #s(weight,sp,sc,rashod,kolnakl, mhid)  
  select sum(c.weight) [weight],
         sum(c.sp) [sp],
         sum(c.sc) [sc], 
  		 0 [rashod],
  		 count(c.datnom),
         c.mhid         
  from #nc c
  group by c.mhid
  order by c.mhid
  
  update #s set crid=isnull((select iif(crid<>7,0,7) from dbo.marsh m join dbo.vehicle v on v.v_id=m.v_id where m.mhid=#s.mhid),7)
  
  update #s set rashod=(select sum(m.oplatasum+m.percworkpay) from nearlogistic.nllistpaydet m where m.mhid=#s.mhid)

  -- Теперь выдергиваю отдельные накладные (интересует главным образом отдел!) 
  -- и для каждой считаю ее весовую долю общем весе маршрута, и пропорционально
  -- раскидываю на нее соотв. часть расходов по маршруту:

  select @day0 [day0],
         @day1 [day1],
         e.depid,
         e.crid,
         iif(e.crid=7,'Морозко','Сторонние') [crName],
         d.dname,
         sum(e.weight) [weight],
  		 round(sum(e.marshcount),1) [kolmarsh],
         round(sum(e.rashod),2) [rashod],
    	 round(sum(e.weight)/sum(e.koeff),1) [avgzagruz], sum(e.dots) [dots],
    	 round(sum(e.rashod)/sum(e.weight),3) [rashod1kg], round((sum(e.sp)-sum(e.sc))/sum(e.weight),3) [dohod1kg],
    	 round(sum(e.rashod)/sum(e.sp),3) [rashod1rub], round(sum(e.rashod)/sum(e.dots),2) [rashod1dot],
    	 round(sum(e.sp),2) [sp], round(sum(e.sc),2) [sc], 
         case when e.depid in (6,26) then 2 
    	 		  when e.depid in (43) then 3
    		  	  else 1 end [grp]
  from (
  
  select c.depid,
  			 #s.crid,
         sum(c.weight) [weight], 
         sum(c.weight)/#s.weight [partweight],
         sum(c.sp) [sp],
         #s.sp [totalsp],
         sum(c.sc) [sc], 
         #s.sc [totalsc], 
         round(sum(c.[weight] / #s.weight * #s.rashod),2) [rashod],
		 count(c.datnom) [ncnaklcount],
         #s.kolnakl [totalnakl], 
         round(1.0*count(c.datnom)/#s.kolnakl,3) [koeff],    
         count(distinct c.vmaster) [dots], count(distinct #s.mhid) [marshcount]
  from #nc c join #s on #s.mhid=c.mhid
      	group by c.depid, #s.sp, #s.sc, #s.kolnakl, #s.weight, #s.crid
        
        ) e
  join dbo.deps d on d.depid=e.depid
  group by e.depid, d.dname, case when e.depid in (6,26) then e.depid else 1 end,e.crid
  order by e.crid, grp,  e.depid
end;