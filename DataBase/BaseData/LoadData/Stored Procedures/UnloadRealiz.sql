CREATE PROCEDURE LoadData.UnloadRealiz @DateStart datetime, @DateEnd datetime, @our_id int, @datnom int=0, @pin int=0
AS
BEGIN
  set transaction isolation level read uncommitted
  declare @datnomStart int, @datnomEnd int
  
  set @datnomStart = dbo.InDatNom(0,@DateStart)
  set @datnomEnd = dbo.InDatNom(9999,@DateEnd)
  

  if @datnom = 0 --выгрузка за период
  
  select c.ND as DATE,  
         c.TM as TIME,  
         case when sum(v.kol)>0 then 0 else 2 end as VID,  
         c.datnom as CODE,  
         c.OurID as CODE_O, 
         --case when isnull(f.master,0)>0 then f2.upin else f.upin end as CODE_K,
         iif((dc.NeedCK=1 or dc.BnFlag=1),iif(isnull(f.master,0)>0,f2.upin, f.upin),59579) as CODE_K, 
         a.sv_ag_id as CODE_PR,  
         v.hitag as CODE_N,  

         SUM(case when isnull(s.weight,0)=0 then v.kol
             when isnull(s.weight,0)<>0 and n.flgWeight=0 then v.kol*round(s.weight/n.netto,2)
             else v.kol*s.weight END) as KOL,

         iif((dc.NeedCK=1 or dc.BnFlag=1),  avg(v.price*iif(isnull(s.weight,0)=0, 1, 1.0*IIF(n.flgWeight=0,n.netto,1)/s.weight)*(1.0+isnull(c.extra,0)/100)), round(avg(v.cost*1.01),2)) as CENA,  
         iif((dc.NeedCK=1 or dc.BnFlag=1),  sum(v.kol*v.price*(1.0+isnull(c.extra,0)/100)),round(sum(v.kol*v.cost*1.01),2)) as SUM,  
         sum(v.kol*v.cost) as SEB,  
         v.sklad as CODE_S,  
         c.stfnom,
         c.stfdate,
         case when (v.sklad>90) and (v.sklad<100) then 1 else 0 end as ST,
         round(sum(v.kol*v.price*(1.0+isnull(c.extra,0)/100)-v.kol*v.price*(1.0+isnull(c.extra,0)/100)/(1.0+n.nds/100.0)),2) as NDS,
         iif( (c.sp>=0) and (c.datnom<>c.startdatnom), c.startdatnom, c.refdatnom) as REFCODE,
         cast(iif(v.hitag = 2296, 1, 0) as bit) as SERV,
         c.stfnom as LNUMBER,
         --f.brINN, 
         iif((dc.NeedCK=1 or dc.BnFlag=1),f.brINN, '366402584177') as brINN,
         n.name
  from nc c join nv v with(nolock, index(NV_Datnom_idx)) on c.datnom=v.datnom  
            left join agentlist a on c.Ag_id=a.ag_id  
            join def f on c.b_id=f.pin 
            join visual s on v.tekid=s.id 
            left join def f2 on f.master=f2.pin
            join nomen n on v.hitag=n.hitag
            join defcontract dc on c.dck=dc.dck
  where c.datnom>=@datnomStart and c.datnom<=@datnomEnd and v.kol<>0 and c.ourid=@our_id and c.Actn<>1 and c.Frizer<>1 and c.Tara<>1 and c.STip not in (2,3,4) 
        and (c.b_id in (select pin from def where master=@pin or pin=@pin) or @pin=0) and c.DayShift=0 and c.DayShift=0 
        AND v.kol>0
         --and (dc.NeedCK=1 or dc.BnFlag=1)         
         --and c.b_id in (51867,52624)
         /* and c.datnom in 
         (1807110550,
1807130113,
1807180609,
1809100075,
1809250005,
1807120340,
1809070106,
1808290021,
1809030018,
1809030031,
1809120017,
1809120020)*/

  group by c.ND,c.TM, c.datnom, c.OurID,f.master, f.upin, f2.upin, a.sv_ag_id,v.hitag,c.stfnom,c.stfdate,v.sklad, c.refdatnom, c.sp,c.startdatnom, f.brINN, n.name,
           dc.NeedCK, dc.BnFlag
  order by c.datnom 
  
  else if @datnom > 0 --выгрузка выбранного поступления
 /* select c.ND as DATE,  
         c.TM as TIME,  
         case when sum(v.kol)>0 then 0 else 2 end as VID,  
         c.datnom as CODE,  
         c.OurID as CODE_O, 
         --case when isnull(f.master,0)>0 then f2.upin else f.upin end as CODE_K,
         iif((dc.NeedCK=1 or dc.BnFlag=1),iif(isnull(f.master,0)>0,f2.upin, f.upin),59579) as CODE_K, 
         a.sv_ag_id as CODE_PR,  
         v.hitag as CODE_N,  

         SUM(case when isnull(s.weight,0)=0 then v.kol
             when isnull(s.weight,0)<>0 and n.flgWeight=0 then v.kol*round(s.weight/n.netto,2)
             else v.kol*s.weight END) as KOL,

         iif((dc.NeedCK=1 or dc.BnFlag=1),  avg(v.price*iif(isnull(s.weight,0)=0, 1, 1.0*IIF(n.flgWeight=0,n.netto,1)/s.weight)*(1.0+isnull(c.extra,0)/100)), round(avg(v.cost*1.01),2)) as CENA,  
         iif((dc.NeedCK=1 or dc.BnFlag=1),  sum(v.kol*v.price*(1.0+isnull(c.extra,0)/100)),round(sum(v.kol*v.cost*1.01),2)) as SUM,  
         sum(v.kol*v.cost) as SEB,  
         v.sklad as CODE_S,  
         c.stfnom,
         c.stfdate,
         case when (v.sklad>90) and (v.sklad<100) then 1 else 0 end as ST,
         round(sum(v.kol*v.price*(1.0+isnull(c.extra,0)/100)-v.kol*v.price*(1.0+isnull(c.extra,0)/100)/(1.0+n.nds/100.0)),2) as NDS,
         iif( (c.sp>=0) and (c.datnom<>c.startdatnom), c.startdatnom, c.refdatnom) as REFCODE,
         cast(iif(v.hitag = 2296, 1, 0) as bit) as SERV,
         c.stfnom as LNUMBER,
         --f.brINN, 
         iif((dc.NeedCK=1 or dc.BnFlag=1),f.brINN, '366402584177') as brINN,
         n.name
  from nc c join nv v with(nolock, index(NV_Datnom_idx)) on c.datnom=v.datnom  
            left join agentlist a on c.Ag_id=a.ag_id  
            join def f on c.b_id=f.pin 
            join visual s on v.tekid=s.id 
            left join def f2 on f.master=f2.pin
            join nomen n on v.hitag=n.hitag
            join defcontract dc on c.dck=dc.dck
  where c.datnom=@datnom and v.kol<>0 and c.ourid=@our_id and c.Actn<>1 and c.Frizer<>1 and c.Tara<>1 and c.STip not in (2,3,4) 
        and c.DayShift=0 and c.Tomorrow=0 
        and v.kol>0
         --and (dc.NeedCK=1 or dc.BnFlag=1)         
         --and c.b_id in (51867,52624)
         /* and c.datnom in 
         (1807110550,
1807130113,
1807180609,
1809100075,
1809250005,
1807120340,
1809070106,
1808290021,
1809030018,
1809030031,
1809120017,
1809120020)*/

  group by c.ND,c.TM, c.datnom, c.OurID,f.master, f.upin, f2.upin, a.sv_ag_id,v.hitag,c.stfnom,c.stfdate,v.sklad, c.refdatnom, c.sp,c.startdatnom, f.brINN, n.name,
           dc.NeedCK, dc.BnFlag
  order by c.datnom 
*/

   select c.ND as DATE,  
           c.TM as TIME,  
           iif(sum(v.kol)>0,0,2) as VID,  
           c.datnom as CODE,  
           c.OurID as CODE_O, 
           iif(isnull(f.master,0)>0,f2.upin, f.upin) as CODE_K,  
           a.sv_ag_id as CODE_PR,  
           v.hitag as CODE_N,  
           sum(case when isnull(s.weight,0)=0 then v.kol else v.kol*s.weight end) as KOL, 
           avg(v.price*(1.0+isnull(c.extra,0)/100)) as CENA,  
           sum(v.kol*v.price*(1.0+isnull(c.extra,0)/100)) as SUM,  
           sum(v.kol*v.cost) as SEB,  
           v.sklad as CODE_S,  
           c.stfnom,
           c.stfdate,
           case when (v.sklad>90) and (v.sklad<100) then 1 else 0 end as ST, 
           round(sum(v.kol*v.price*(1.0+isnull(c.extra,0)/100)-v.kol*v.price*(1.0+isnull(c.extra,0)/100)/(1.0+n.nds/100.0)),2) as NDS,
           c.refdatnom as REFCODE,
           cast(iif(v.hitag = 2296, 1, 0) as bit) as SERV,
           c.stfnom as LNUMBER,
           f.brINN
    from nc c join nv v on c.datnom=v.datnom  
              left join agentlist a on c.Ag_id=a.ag_id  
              join def f on c.b_id=f.pin 
              join visual s on v.tekid=s.id 
              left join def f2 on f.master=f2.pin
              join nomen n on v.hitag=n.hitag
    where c.datnom=@datnom and v.kol<>0 and c.ourid=@our_id and c.Actn<>1 and c.Frizer<>1 and c.Tara<>1 
    group by c.ND,c.TM, c.datnom, c.OurID,f.master,  f.upin, f2.upin, a.sv_ag_id,v.hitag,c.stfnom,c.stfdate,v.sklad, c.refdatnom, f.brINN  
    order by c.datnom 
    
    else
    
    select c.ND as DATE,  
         c.TM as TIME,  
         case when sum(v.kol)>0 then 0 else 2 end as VID,  
         c.datnom as CODE,  
         c.OurID as CODE_O, 
         59579 as CODE_K,  
         a.sv_ag_id as CODE_PR,  
         v.hitag as CODE_N,  
         sum(case when isnull(s.weight,0)=0 then v.kol else v.kol*s.weight end) as KOL, 
         round(avg(v.cost*1.01),2) as CENA,  
         round(sum(v.kol*v.cost*1.01),2) as SUM,  
         sum(v.kol*v.cost) as SEB,  
         v.sklad as CODE_S,  
         c.stfnom,
         c.stfdate,
         case when (v.sklad>90) and (v.sklad<100) then 1 else 0 end as ST,
         round(sum(v.kol*v.price*(1.0+isnull(c.extra,0)/100)-v.kol*v.price*(1.0+isnull(c.extra,0)/100)/(1.0+n.nds/100.0)),2) as NDS,
         iif((c.sp>=0) and (c.datnom<>c.startdatnom), c.startdatnom, c.refdatnom) as REFCODE,
         cast(iif(v.hitag = 2296, 1, 0) as bit) as SERV,
         c.stfnom as LNUMBER,
         '366402584177' as brINN --   a f.brINN
  from nc c join nv v on c.datnom=v.datnom  
            left join agentlist a on c.Ag_id=a.ag_id  
            join def f on c.b_id=f.pin 
            join visual s on v.tekid=s.id 
            left join def f2 on f.master=f2.pin
            join nomen n on v.hitag=n.hitag
            join defcontract dc on c.dck=dc.dck
  where c.datnom>=@datnomStart and c.datnom<=@datnomEnd and v.kol<>0 and c.ourid=@our_id and c.Actn<>1 and c.Frizer<>1 and c.Tara<>1 and c.STip not in (2,3,4) 
        and (dc.NeedCK=0 and dc.BnFlag=0)         
        and (c.b_id in (select pin from def where master=@pin or pin=@pin) or @pin=0)
        --and c.b_id in (44162)-- 57173,57808,59582,59575,58568,25205,50760,47363,50638)
        -- and c.datnom in (1809110034)
        
  group by c.ND,c.TM, c.datnom, c.OurID, a.sv_ag_id,v.hitag,c.stfnom,c.stfdate,v.sklad, c.refdatnom, c.sp,c.startdatnom
  order by c.datnom 
    
END