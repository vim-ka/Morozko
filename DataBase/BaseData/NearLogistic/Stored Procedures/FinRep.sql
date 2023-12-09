CREATE PROCEDURE [NearLogistic].FinRep @DateStart datetime, @DateEnd datetime
AS
BEGIN
  select m.mhid,
         m.marsh,
         m.nd,
         m.Direction,
         round(sum(case when c.stip<>4 then (v.Price-v.Cost)*v.kol*100/(n.nds+100) else 0 end),2) as NacBezNDS,
         round(sum(case when c.stip<>4 then 0 else case when a.nds=0 then v.Price*(v.kol-v.kol_b)*a.ourperc/100 else v.Price*(v.kol-v.kol_b)*a.ourperc/(n.nds+100) end end),2) as Uslugi,
         round(sum(0.104*(v.Price-v.Cost)*v.kol),2) as OplTrud,
         round(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgStor*datediff(Day,d.datepost,c.nd)),2) as PayStor,
         round(sum(case when e.dfID=7 then 0 else 0.05*v.Cost*v.kol end),2) as AdmRash,
         round(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgDeliv),2) as PayLogBuy,
         (s.DelivPay+isnull(h.expense,0)+m.CalcDist*isnull(h.tariff1km,0)) as PayLogSaleSM,
         (case when h.CrID<>7 then s.DelivPay else 0 end) as PayLogSale,
         isnull(h.expense,0) as PostRash,
         (case when h.CrID<>7 then 0 else s.DelivPay end) as PayLogSaleOur,
         m.CalcDist*isnull(h.tariff1km,0) as Gsm,
         round(sum(case when c.stip<>4 then (v.Price-v.Cost)*v.kol*100/(n.nds+100) else 0 end),2)
         +round(sum(case when c.stip<>4 then 0 else case when a.nds=0 then v.Price*(v.kol-v.kol_b)*a.ourperc/100 else v.Price*(v.kol-v.kol_b)*a.ourperc/(n.nds+100) end end),2)
         -isnull(h.expense,0)
         -round(sum(case when e.dfID=7 then 0 else 0.05*v.Cost*v.kol end),2) 
         -round(sum(0.104*(v.Price-v.Cost)*v.kol),2) 
         -round(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgStor),2) 
         -round(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgDeliv),2)
         -m.CalcDist*isnull(h.tariff1km,0)
         -s.DelivPay as Total
  from nc c join nv v on c.datnom=v.datnom
            join marsh m on c.nd=m.nd and c.marsh=m.marsh
            join nomen n on v.hitag=n.hitag
            join GR g on n.ngrp=g.ngrp
            left join vehicle h on m.v_id=h.v_id
            left join visual d on v.tekid=d.id
            join def e on c.b_id=e.pin
           left join (select dck,BrMaster, NDS, sum(OurPerc) as OurPerc from DefconAppendix group by dck,BrMaster, NDS) a on iif(e.Master>0, e.Master, e.pin)=a.BrMaster and d.dck=a.dck
            left join
            (select m.mhid, NearLogistic.Marsh1CalcFact(m.mhid) as DelivPay from Marsh m where m.nd>=@DateStart and m.nd<=@DateEnd) s on s.mhid=m.mhid
          
  where m.nd>=@DateStart and m.nd<=@DateEnd
  group by m.mhid, m.marsh, m.nd, m.Direction,h.expense,h.tariff1km,m.CalcDist,h.CrID, s.DelivPay
  
END