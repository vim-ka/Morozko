CREATE PROCEDURE [LoadData].ITRPGoods @DocType int, @DateStart datetime, @DateEnd datetime 
AS
BEGIN
declare @FirmGroup int
set @FirmGroup=7

 if @DocType = 1  
 --поступление 
 
 select 1 as VID, 
        c.[date] as DATE, 
        c.[time] as TIME,  
        c.ncom as CODE, 
        c.our_id as CODE_O, 
        (select d.pin from def d where d.ncod=c.ncod) as CODE_K, 
        c.DCK as CODE_D, 
        i.hitag as CODE_N, 
        i.kol as KOL, 
        i.cost as CENA, 
        i.summacost as SUM, 
        i.sklad as CODE_S,
        iif(t.ContrTip=5, 1, 0) as SafeCust    
 from comman c join inpdet i on c.ncom=i.ncom 
               left join FirmsConfig f on c.Our_ID=f.Our_id 
               left join DefContract  t on c.dck=t.dck
 where c.[date]>=@DateStart and c.[date]<=@DateEnd
       and f.FirmGroup in (7,10) --=@FirmGroup 
       and t.ContrTip=1
 order by c.[date],c.ncom   

else if @DocType = 2 
--Возврат поставщику

 select i.nd as DATE, 
        (select MIN(d.tm) from izmen d where d.nd=i.nd and d.dck=i.dck) as TIME, 
        0 as VID, 
        (select MIN(d.izmID) from izmen d where d.nd=i.nd and d.dck=i.dck and d.act='Снят') as CODE,  
        d.our_id as CODE_O, 
        f.pin as CODE_K, 
        i.dck as CODE_D, 
        0 as CODE_PR, 
        0 as KOM, 
        v.hitag as CODE_N, 
        i.kol-i.newkol as KOL, 
        i.cost as CENA,  
        (i.kol-i.newkol)*i.cost as SUM, 
        i.sklad as CODE_S, 
        i.izmID,
        iif(d.ContrTip=5, 1, 0) as SafeCust     
 from izmen i left join defcontract d on i.dck=d.dck  
              left join visual v on i.id=v.id 
              left join def f on f.ncod=d.pin 
              left join FirmsConfig m on d.Our_ID=m.Our_id 
 where i.nd>=@DateStart and i.nd<=@DateEnd and i.act='Снят'  
       and m.FirmGroup in (7,10) --=@FirmGroup
       and d.ContrTip=1
       
else if @DocType = 3 
--Корректировка цены поставщика

 select i.ND as DATE, 
        i.tm As TIME, 
        i.izmID as CODE, 
        c.our_id as CODE_O, 
        f.pin as CODE_K, 
        c.dck as CODE_D, 
        i.hitag as CODE_N, 
        i.kol as KOL, 
        i.cost as CENA_O, 
        i.newcost as CENA_N, 
        i.kol*i.newcost as SUM_N, 
        i.kol*i.cost as SUM_O, 
        i.sklad as CODE_S, 
        iif(s.Discard=1,1,0) as ST,
        iif(d.ContrTip=5, 1, 0) as SafeCust     
        --case when i.sklad>88 then 1 else 0 end as ST 
 from izmen i join comman c on c.ncom=i.ncom 
              join def f on f.ncod=c.ncod 
              left join IzmenReason r on r.irID=i.irID 
              join SkladList s on i.sklad=s.skladNo
              left join FirmsConfig m on c.Our_ID=m.Our_id 
              left join defcontract d on i.dck=d.dck  
 where i.nd>=@DateStart and i.ND<=@DateEnd and i.Act='ИзмЦ' and i.smi<>0 and i.Cost<>i.NewCost
       and m.FirmGroup in (7,10) --=@FirmGroup
       and d.ContrTip=1

else if @DocType = 4 
--Списания оприходования

 select i.ND as DATE, 
        i.tm As TIME, 
        i.izmID as CODE, 
        isnull(c.our_id,7) as CODE_O, 
        f.hitag as CODE_N, 
        i.newkol-i.kol as KOL, 
        i.sklad as CODE_S, 
        i.smi as SUM, 
        r.irID+2000 as COPE_P, 
        r.Reason as REAS, 
        iif(s.Discard=1,1,0) as ST,
        iif(d.ContrTip=5, 1, 0) as SafeCust     
        --(case when i.sklad>88 then 1 else 0 end) as ST 
 from izmen i join comman c on c.ncom=i.ncom 
              join visual f on f.ID=i.ID 
              left join IzmenReason r on r.irID=i.irID   
              join SkladList s on i.sklad=s.skladNo
              left join FirmsConfig m on c.Our_ID=m.Our_id 
              left join defcontract d on i.dck=d.dck  
 where i.nd>=@DateStart and i.ND<=@DateEnd and (i.Act='Испр' or i.Act='ИспВ') --and i.smi<>0  
       and m.FirmGroup in (7,10) --=@FirmGroup
       and d.ContrTip=1
       
 order by i.ND 
else if @DocType = 5 
--Перемещения 

 select i.ND as DATE, 
        i.tm As TIME, 
        i.izmID as CODE, 
        c.our_id as CODE_O, 
        f.hitag as CODE_N, 
        i.newkol as KOL, 
        i.newkol*i.price as SUM, 
        i.sklad as CODE_SO, 
        i.newsklad as CODE_SP, 
        iif(s.Discard=1,1,0) as ST,
        iif(d.ContrTip=5, 1, 0) as SafeCust    
        --(case when i.sklad>88 then 1 else 0 end) as ST 
 from izmen i join comman c on c.ncom=i.ncom 
              join visual f on f.ID=i.ID 
              left join IzmenReason r on r.irID=i.irID   
              join SkladList s on i.sklad=s.skladNo
              left join FirmsConfig m on c.Our_ID=m.Our_id 
              left join defcontract d on i.dck=d.dck  
 where i.nd>=@DateStart and i.ND<=@DateEnd and i.Act='Скла' --and i.smi<>0  
       and m.FirmGroup in (7,10) --=@FirmGroup
       and d.ContrTip=1
              
 order by i.ND 
else if @DocType = 6 
--Корректировки

 select i.ND as DATE, 
        i.TM As TIME, 
        i.NID as CODE, 
        c.ourid as CODE_O, 
        i.B_ID as CODE_K, 
        c.dck as CODE_D, 
        e.sv_ag_id as CODE_PR, 
        r.nrID as CODE_P, 
        r.ReasName as KOM, 
        i.Izmen as SUM, 
        2 as FLG,
        iif(d.ContrTip=5, 1, 0) as SafeCust     
 from NCizmen i join nc c on c.datnom=i.datnom 
                left join NCIzmenReason r on r.nrID=isnull(i.nrID,1)   
                join AgentList e on c.ag_id=e.ag_id 
                left join FirmsConfig f on c.OurID=f.Our_id 
                left join defcontract d on c.dck=d.dck  
 where i.nd>=@DateStart and i.ND<=@DateEnd 
       and f.FirmGroup in (7,10) --=@FirmGroup
       and d.ContrTip=1
 union  
 
 select i.ND as DATE, 
        '' As TIME, 
        i.IDCorr as CODE, 
        c.our_id as CODE_O, 
        f.pin as CODE_K, 
        c.dck as CODE_D, 
        8 as CODE_PR, 
        r.ccID+1000 as CODE_P, 
        r.ReasName as KOM, 
        i.Corr as SUM, 
        1 as FLG,
        iif(d.ContrTip=5, 1, 0) as SafeCust     
 from CommanCorr i join comman c on c.ncom=i.ncom 
                   join def f on f.ncod=c.ncod 
                   left join CommanCorrReason r on r.ccID=i.ccID
                   left join FirmsConfig m on c.Our_ID=m.Our_id
                   left join defcontract d on c.dck=d.dck      
 where i.nd>=@DateStart and i.ND<=@DateEnd 
       and m.FirmGroup in (7,10) --=@FirmGroup
       and d.ContrTip=1
                
END