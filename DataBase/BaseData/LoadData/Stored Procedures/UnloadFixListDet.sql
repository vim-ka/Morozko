CREATE PROCEDURE [LoadData].UnloadFixListDet @DateStart datetime, @DateEnd datetime, @Our_id int
AS
BEGIN
/**********************************накладные исправленные***************************/

 select i.ncid as IDIspr, 
        i.nd as DATEISPR, 
        c.ND as DATE,  
        c.TM as TIME,  
        c.datnom as CODE,  
        c.OurID as CODE_O, 
        case when isnull(f.master,0)>0 then f2.upin else f.upin end as CODE_K,  
        v.hitag as CODE_N,  
        sum(case when isnull(s.weight,0)=0 then (v.kol+isnull(z.kol,0)) else(v.kol+isnull(z.kol,0))*s.weight end) as KOL, 
        avg(v.price*(1.0+isnull(c.extra,0)/100)) as CENA,  
        sum((v.kol+isnull(z.kol,0))*v.price*(1.0+isnull(c.extra,0)/100)) as SUM,  
        sum((v.kol+isnull(z.kol,0))*v.cost) as SEB,  
        v.sklad as CODE_S,  
        case when v.sklad>90 then 1 else 0 end as ST  
  from ncedit i join nc c on i.datnom=c.datnom
                join nv v on c.datnom=v.datnom  
                left join agentlist a on c.Ag_id=a.ag_id  
                join def f on c.b_id=f.pin 
                join visual s on v.tekid=s.id 
                left join def f2 on f.master=f2.pin
                left join
                (select c.refdatnom, r.tekid, sum(r.kol) as kol from nv r join nc c on r.datnom=c.datnom 
                 where c.refdatnom in (select c.datnom from ncedit c where c.nd>=@DateStart and c.nd<=@DateEnd)
                 and isnull(c.remark,'')='' group by c.refdatnom, r.tekid) z on v.datnom=z.refdatnom and z.tekid=v.tekid
 where i.nd>=@DateStart and i.nd<=@DateEnd and c.OurId=@Our_id and c.Actn<>1 and c.Frizer<>1 and c.Tara<>1 and
      c.nd<>i.nd
 group by i.ncid,i.nd,c.ND,c.TM, c.datnom, c.OurID,f.master, f.upin, f2.upin, a.sv_ag_id,v.hitag,v.sklad 
 order by i.ncid
END