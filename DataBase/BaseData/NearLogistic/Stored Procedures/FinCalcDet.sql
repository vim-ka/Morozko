CREATE PROCEDURE [NearLogistic].FinCalcDet @mhid int, @DelivPay money=0 
AS
BEGIN
 declare @Weight float
 
 set @Weight =  round((select sum(dbo.CalcWeightNakl(t.datnom)) from nc t, marsh a where t.nd=a.nd and t.marsh=a.marsh and a.mhid=@mhid),2)


  select dbo.InNnak(c.datnom) as NNak,
         c.datnom,
         c.ND,   
         e.gpName,
         case when c.stip=4 then 'услуги логистики' 
              when c.actn=1 then 'акция'
              else 'реализация' end as actn, 
         round(sum(case when c.stip<>4 then (v.Price-v.Cost)*v.kol*100/(n.nds+100) else case when a.nds=0 then v.Price*(v.kol-v.kol_b)*a.ourperc/100 else v.Price*(v.kol-v.kol_b)*a.ourperc/(n.nds+100) end end),2) as NacBezNDS,
         round(sum(0.104*(v.Price-v.Cost)*v.kol),2) as OplTrud,
         round(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgStor*datediff(Day,d.datepost,c.nd)),2) as PayStor,
         round(sum(case when e.dfID=7 then 0 else 0.05*v.Cost*v.kol end),2) as AdmRash,
         round(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgDeliv),2) as PayLogBuy,
         round((@DelivPay*dbo.CalcWeightNakl(c.datnom)/@Weight+isnull(h.expense,0)*dbo.CalcWeightNakl(c.datnom)/@Weight
                +m.CalcDist*isnull(h.tariff1km,0)*dbo.CalcWeightNakl(c.datnom)/@Weight),2) as PayLogSaleSM,
         round((case when h.CrID<>7 then @DelivPay*dbo.CalcWeightNakl(c.datnom)/@Weight else 0 end),2) as PayLogSale,
         round(isnull(h.expense,0)*dbo.CalcWeightNakl(c.datnom)/@Weight,2) as PostRash,
         round((case when h.CrID<>7 then 0 else @DelivPay*dbo.CalcWeightNakl(c.datnom)/@Weight end),2) as PayLogSaleOur,
         round(m.CalcDist*isnull(h.tariff1km,0)*dbo.CalcWeightNakl(c.datnom)/@Weight,2) as Gsm,
         
         round(sum(case when c.stip<>4 then (v.Price-v.Cost)*v.kol*100/(n.nds+100) else case when a.nds=0 then v.Price*(v.kol-v.kol_b)*a.ourperc/100 else v.Price*(v.kol-v.kol_b)*a.ourperc/(n.nds+100) end end)
         -(sum(case when e.dfID=7 then 0 else 0.05*v.Cost*v.kol end)) 
         -(sum(0.104*(v.Price-v.Cost)*v.kol)) 
         -(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgStor)) 
         -(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgDeliv))
         -(m.CalcDist*isnull(h.tariff1km,0)
         +isnull(h.expense,0)
         +@DelivPay)*dbo.CalcWeightNakl(c.datnom)/@Weight,2) as Total
  from nc c join nv v on c.datnom=v.datnom
            join marsh m on c.mhid=m.mhid
            join nomen n on v.hitag=n.hitag
            join GR g on n.ngrp=g.ngrp
            left join vehicle h on m.v_id=h.v_id
            left join visual d on v.tekid=d.id
            join def e on c.b_id=e.pin
            left join (select dck,BrMaster, NDS, sum(OurPerc) as OurPerc from DefconAppendix group by dck,BrMaster, NDS) a on iif(e.Master>0, e.Master, e.pin)=a.BrMaster and d.dck=a.dck
  where m.mhid=@mhid
  group by c.datnom,c.nd,c.actn,c.stip,e.gpName,h.expense,h.tariff1km,m.CalcDist,h.CrID
  
END