CREATE PROCEDURE NearLogistic.FinCalc @mhid int, @DelivPay money=0, 
@show bit=1,@total money=0 out  
AS
BEGIN
  
  select round(
               sum(iif(c.stip<>4, (1+c.extra/100)*(v.Price-v.Cost)*v.kol*100/(n.nds+100), 0))
               + sum(isnull(nz.MarjaZakaz,0)) 
               + isnull(db.dobiv,0) 
         ,2) as NacBezNDS,
         isnull(round(sum(case when c.stip<>4 then 0 else case when a.nds=0 then v.Price*(v.kol-v.kol_b)*a.ourperc/100 else v.Price*(v.kol-v.kol_b)*a.ourperc/(n.nds+100) end end),2),0) as Uslugi,
         isnull(bs.req_pay,0) AS UslugiDost,  
         isnull(round(sum(0.104*(1+(c.extra/100))*(v.Price-v.Cost)*v.kol),2),0) as OplTrud,
         isnull(round(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgStor*datediff(Day,d.datepost,c.nd)),2),0) as PayStor,
         isnull(round(sum(case when e.dfID=7 then 0 else 0.05*v.Cost*v.kol end),2),0) as AdmRash,
         isnull(round(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgDeliv),2),0) as PayLogBuy,
         (@DelivPay /*+ isnull(h.expense,0)+m.CalcDist*isnull(h.tariff1km,0)*/) as PayLogSaleSM,
         (case when t.ttID=4 then 0 else @DelivPay end) as PayLogSale,
         isnull(h.expense,0) as PostRash,
         (case when t.ttID=4 then @DelivPay - isnull(h.expense,0)-iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0))*isnull(h.tariff1km,0) else 0 end) as PayLogSaleOur,
         iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0))*isnull(h.tariff1km,0) as Gsm,

         cast(round(isnull(sum(case when c.stip<>4 
                                          then (1+c.extra/100)*(v.Price-v.Cost)*v.kol*100/(n.nds+100) 
                                          else 0 
                                      end)
                         + sum(isnull(nz.MarjaZakaz,0))
                        , 0)    --NacBezNDS
                    + isnull(round(sum(case when c.stip<>4 
                                            then 0 
                                            else case when a.nds=0 
                                                      then v.Price*(v.kol-v.kol_b)*a.ourperc/100 
                                                      else v.Price*(v.kol-v.kol_b)*a.ourperc/(n.nds+100) 
                                                  end 
                                        end), 2), 0)    --UslugiDost
                    - isnull(round(sum(case when e.dfID=7 
                                            then 0 
                                            else 0.05*v.Cost*v.kol 
                                        end), 2), 0)    --AdmRash
                    - isnull(round(sum(0.104*(1+(c.extra/100))*(v.Price-v.Cost)*v.kol), 2), 0)      --OplTrud
                    - isnull(round(sum((case when isnull(d.WEIGHT,0)<>0 
                                             then d.weight*v.kol 
                                             else n.netto*v.kol 
                                         end)*g.Cost1kgStor*datediff(Day,d.datepost,c.nd)),2),0)    --PayStor
                    - isnull(round(sum((case when isnull(d.WEIGHT,0)<>0 
                                             then d.weight*v.kol 
                                             else n.netto*v.kol 
                                         end)*g.Cost1kgDeliv),2),0)   --PayLogBuy
                    + isnull(bs.req_pay,0)
                   - @DelivPay        --PayLogSaleSM
              ,2) as float) as Total
  into #res
  from  marsh m 
            left join nc c on m.mhid=c.mhid
            left join nv v with(nolock, index(NV_Datnom_idx)) on c.datnom=v.datnom
            left join 
            (select v.datnom , sum((v.zakaz*v.price*(1+(c.extra/100))-v.zakaz*v.cost)*iif(n.flgweight=1,n.netto,1)*100/(n.nds+100)) as MarjaZakaz
             from nvzakaz v join nc c on v.datnom=c.datnom
                            join nomen n on v.hitag=n.hitag
             where v.done=0
             group by v.datnom) nz on nz.datnom=c.datnom
           
            left join nearlogistic.nltariffsdet dt on dt.nltariffparamsid=m.nltariffparamsiddrv
            left join nearlogistic.nltariffs t on t.nltariffsid=dt.nltariffsid 
            left join nomen n on v.hitag=n.hitag
            left join GR g on n.ngrp=g.ngrp
            left join vehicle h on m.v_id=h.v_id
            left join visual d on v.tekid=d.id
            left join def e on c.b_id=e.pin
            left join (select dck,BrMaster, NDS, sum(OurPerc) as OurPerc from DefconAppendix group by dck,BrMaster, NDS) a on iif(e.Master>0, e.Master, e.pin)=a.BrMaster and d.dck=a.dck
            left join (select bs.mhid, sum(bs.req_pay) as req_pay from nearlogistic.billsSum bs group by bs.mhid) bs on m.mhid=bs.mhid
            left join (select cmain.mhid ,sum((1+c1.extra/100)*r.Price*r.kol*100/(n.nds+100)) as dobiv
                       from  nc c1 join nv r with(nolock, index(NV_Datnom_idx)) on r.datnom=c1.datnom 
                                   join nomen n on r.hitag=n.hitag
                                   join nc cmain on c1.refdatnom=cmain.datnom  
                      where c1.refdatnom>0 and c1.sp>0 and c1.stip<>4 and cmain.mhid=@mhid
                      group by cmain.mhid) db on db.mhid=m.mhid

  where m.mhid=@mhid
  group by h.expense,h.tariff1km,iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)),t.ttID,bs.req_pay, db.dobiv
  
  
  insert into #res
  select 0.03*round(
                    sum(iif(c.stip<>4, (1+c.extra/100)*v.Price*v.kol*100/(n.nds+100), 0))
                    + sum(isnull(nz.MarjaZakaz,0))
                    + isnull(db.dobiv,0)
         ,2) as NacBezNDS,

         isnull(round(sum(case when c.stip<>4 then 0 else case when a.nds=0 then v.Price*(v.kol-v.kol_b)*/*a.ourperc*/10/100 else v.Price*(v.kol-v.kol_b)*/*a.ourperc*/10/(n.nds+100) end end),2),0) as Uslugi,
         isnull(bs.req_pay,0) AS UslugiDost,  
         0 as OplTrud,
         0 as PayStor,
         0 as AdmRash,
         0 as PayLogBuy,
         (@DelivPay /*+ isnull(h.expense,0)+m.CalcDist*isnull(h.tariff1km,0)*/) as PayLogSaleSM,
         (case when t.ttID=4 then 0 else @DelivPay end) as PayLogSale,
         isnull(h.expense,0) as PostRash, -- Постоянные расходы
         (case when t.ttID=4 then @DelivPay - isnull(h.expense,0)-iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0))*isnull(h.tariff1km,0) else 0 end) as PayLogSaleOur, -- Оплата труда
         iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0))*isnull(h.tariff1km,0) as Gsm,--ГСМ
         
         cast(round(
                    0.03*round(sum(iif(c.stip<>4, (1+c.extra/100)*v.Price*v.kol*100/(n.nds+100), 0))
                               + sum(isnull(nz.MarjaZakaz, 0))
                         ,2) 
                    + isnull(db.dobiv,0)*0.03
                    + isnull(round(sum(case when c.stip<>4 
                                            then 0 else 
                                                   case when a.nds=0 
                                                        then v.Price*(v.kol-v.kol_b)*/*a.ourperc*/10/100 
                                                        else v.Price*(v.kol-v.kol_b)*/*a.ourperc*/10/(n.nds+100) 
                                                    end 
                                             end)
                                   ,2), 
                             0)
                    + isnull(bs.req_pay,0)
                    - @DelivPay,
            2) as float) as Total
  from  marsh m 
            left join nc c on m.mhid=c.mhid
            left join nv v with(nolock, index(NV_Datnom_idx)) on c.datnom=v.datnom
            left join 
            (select v.datnom , sum((v.zakaz*v.price*(1+(c.extra/100)))*iif(n.flgweight=1,n.netto,1)*100/(n.nds+100)) as MarjaZakaz
             from nvzakaz v join nc c on v.datnom=c.datnom
                            join nomen n on v.hitag=n.hitag
             where v.done=0
             group by v.datnom) nz on nz.datnom=c.datnom
           
            left join nearlogistic.nltariffsdet dt on dt.nltariffparamsid=m.nltariffparamsiddrv
            left join nearlogistic.nltariffs t on t.nltariffsid=dt.nltariffsid 
            left join nomen n on v.hitag=n.hitag
            left join GR g on n.ngrp=g.ngrp
            left join vehicle h on m.v_id=h.v_id
            left join visual d on v.tekid=d.id
            left join def e on c.b_id=e.pin
            left join (select dck,BrMaster, NDS, sum(OurPerc) as OurPerc from DefconAppendix group by dck,BrMaster, NDS) a on iif(e.Master>0, e.Master, e.pin)=a.BrMaster and d.dck=a.dck
            left join (select bs.mhid, sum(bs.req_pay) as req_pay from nearlogistic.billsSum bs group by bs.mhid) bs on m.mhid=bs.mhid
            
            left join (select cmain.mhid ,sum((1+c1.extra/100)*r.Price*r.kol*100/(n.nds+100)) as dobiv
                       from  nc c1 join nv r with(nolock, index(NV_Datnom_idx)) on r.datnom=c1.datnom 
                                   join nomen n on r.hitag=n.hitag
                                   join nc cmain on c1.refdatnom=cmain.datnom  
                      where c1.refdatnom>0 and c1.sp>0 and c1.stip<>4 and cmain.mhid=@mhid
                      group by cmain.mhid) db on db.mhid=m.mhid
   
            
  where m.mhid=@mhid
  group by h.expense,h.tariff1km,iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)),t.ttID,bs.req_pay,db.dobiv
   
  
  select @total=total from #res
  if @show=1 select * from #res order by AdmRash desc  
END