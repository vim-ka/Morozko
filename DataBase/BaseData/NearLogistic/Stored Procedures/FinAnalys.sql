CREATE PROCEDURE [NearLogistic].FinAnalys @NDBegin datetime, @NDEnd datetime
AS
BEGIN
set transaction isolation level READ UNCOMMITTED
begin tran
  declare @Weight float

  create table #tbTemp (ND datetime, marsh int, datnom Bigint, b_id int, weight NUMERIC(10,3),
                        gpName varchar(150), NacBezNDS money,Total money,
                        transp_rash money, weight_marsh numeric(10,3))

  insert into #tbTemp 
  select c.ND,  
       c.marsh,
       c.DatNom,
       c.b_id, 
       c.weight,
       e.gpName,
       round(sum(case when c.stip<>4 then (v.Price-v.Cost)*v.kol*100/(n.nds+100) else case when a.nds=0 then v.Price*(v.kol-v.kol_b)*a.ourperc/100 else v.Price*(v.kol-v.kol_b)*a.ourperc/(n.nds+100) end end),2) as NacBezNDS,
       round(sum(case when c.stip<>4 then (v.Price-v.Cost)*v.kol*100/(n.nds+100) else case when a.nds=0 then v.Price*(v.kol-v.kol_b)*a.ourperc/100 else v.Price*(v.kol-v.kol_b)*a.ourperc/(n.nds+100) end end)
       -(sum(case when e.dfID=7 then 0 else 0.05*v.Cost*v.kol end)) 
       -(sum(0.104*(v.Price-v.Cost)*v.kol)) 
       -(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgStor)) 
       -(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgDeliv))
       ,2) as Total,
       isnull(o.oplatasum+o.oplataother,0),isnull(o.weight,0)
  from nc c join nv v on c.datnom=v.datnom
            join nomen n on v.hitag=n.hitag
            join GR g on n.ngrp=g.ngrp
            left join visual d on v.tekid=d.id
            join def e on c.b_id=e.pin
            left join (select dck,BrMaster, NDS, sum(OurPerc) as OurPerc from DefconAppendix group by dck,BrMaster, NDS) a on iif(e.Master>0, e.Master, e.pin)=a.BrMaster and d.dck=a.dck
            left join marshopldet o on o.ndmarsh=c.ND and o.marsh=c.marsh
  where c.ND>=@NDBegin and c.ND<=@NDEnd and c.sp>0 and e.worker=0
  group by c.nd,c.datnom,c.stip,e.gpName,c.marsh,
           c.b_id, c.weight,o.oplatasum,o.oplataother,o.weight
  order by c.b_id                       
  
  select t.b_id, t.gpName, 
          round(sum(case
             when t.weight_marsh = 0 then t.total
             else t.total-t.weight*t.transp_rash/t.weight_marsh end),2) as Total
  from #tbTemp t
  group by t.b_id, t.gpName                         
  order by Total
    
  
  
-- set @Weight =  round((select sum(dbo.CalcWeightNakl(t.datnom)) from nc t, marsh a where t.nd=a.nd and t.marsh=a.marsh and a.mhid=@mhid),2)


  /*select c.ND,   
         e.gpName,
         round(sum(case when c.stip<>4 then (v.Price-v.Cost)*v.kol*100/(n.nds+100) else case when a.nds=0 then v.Price*(v.kol-v.kol_b)*a.ourperc/100 else v.Price*(v.kol-v.kol_b)*a.ourperc/(n.nds+100) end end),2) as NacBezNDS,
         
         round(sum(case when c.stip<>4 then (v.Price-v.Cost)*v.kol*100/(n.nds+100) else case when a.nds=0 then v.Price*(v.kol-v.kol_b)*a.ourperc/100 else v.Price*(v.kol-v.kol_b)*a.ourperc/(n.nds+100) end end)
         -(sum(case when e.dfID=7 then 0 else 0.05*v.Cost*v.kol end)) 
         -(sum(0.104*(v.Price-v.Cost)*v.kol)) 
         -(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgStor)) 
         -(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgDeliv))
         -(m.CalcDist*isnull(h.tariff1km,0)
         +isnull(h.expense,0)
  --       -sum(NearLogistic.Marsh1CalcFact(m.mhid)*(c.weight)/m.weight)),2) as Total
--         -sum(NearLogistic.Marsh1CalcFact(m.mhid)*dbo.CalcWeightNakl(c.datnom)/m.weight)),2) as Total

         ),2) as Total
  from nc c join nv v on c.datnom=v.datnom
            join marsh m on c.nd=m.nd and c.marsh=m.marsh
            join nomen n on v.hitag=n.hitag
            join GR g on n.ngrp=g.ngrp
            left join vehicle h on m.v_id=h.v_id
            left join visual d on v.tekid=d.id
            join def e on c.b_id=e.pin
            left join DefconAppendix a on iif(e.Master>0, e.Master, e.pin)=a.BrMaster and d.dck=a.dck
  where m.ND>=@NDBegin and m.ND<=@NDEnd
  group by m.mhid,c.nd,c.datnom,c.stip,e.gpName,h.expense,h.tariff1km,m.CalcDist,h.CrID
  order by e.gpName*/
commit tran  
END