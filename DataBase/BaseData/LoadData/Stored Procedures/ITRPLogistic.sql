CREATE PROCEDURE [LoadData].ITRPLogistic @DateStart datetime, @DateEnd datetime
AS
BEGIN
 set transaction isolation level read uncommitted
 


 declare @StartDatnom int, @EndDatnom int
 set @StartDatnom=dbo.InDatNom(0,@DateStart);
 set @EndDatnom=dbo.InDatNom(9999,@DateEnd);

 
select t.nd, 
        t.marsh, 
        iif(t.Logistic=1, 100036, iif(t.Dep=0,257,t.Dep)) as Dep, 
        t.Pin, 
        t.BrName,
        t.DCK, 
        sum(t.Sm) as Sm, 
        sum(t.weight) as weight, 
        sum(t.StoimDost) as StoimDost, 
        t.kolvo,  
        t.Napr, 
        t.Comment,
        t.Dist,
        t.V_ID,
        t.Alien,
        t.Reg_ID,
        t.bReg_ID,
        t.Logistic,
        t.brNameC 
 from        
 (select c.nd, 
         c.marsh, 
         a.sv_ag_id as Dep, 
         ef.pin as Pin, 
         ef.brName,
         case when isnull((select max(c.dck) from defcontract c where c.pin=ef.pin and c.ContrTip=4),0)=0 
              then (select isnull(max(c.dck),0) from defcontract c where c.pin=ef.pin) 
              else (select isnull(max(c.dck),0) from defcontract c where c.pin=ef.pin and c.ContrTip=4) end as DCK, 
         sum(c.sp) as Sm, 
         sum(c.weight) as weight, 
         sum(iif(f.smw<>0,round((isnull(de.oplatasum,0)+isnull(de.bonus,0))*c.weight/f.smw,2),0)) as StoimDost, 
         1 as kolvo,  
         m.Driver as Napr, 
        'ТР: ' + cast((isnull(de.oplatasum,0)+isnull(de.bonus,0)) as varchar)+' Вес: '+cast(f.smw as varchar)+' Напр.: '+m.Driver+' Вод.: '+r.Fio as Comment,
         m.Dist,
         m.V_ID,
         iif(i.crID<>7, 1, 0) Alien,
         ef.Obl_ID as Reg_ID,
         b.Reg_ID bReg_ID,
         iif(c.stip=4, 1, 0) as Logistic,
         b.brName as brNameC
 from nc c join marsh m on c.mhid=m.mhid--c.nd=m.nd and c.marsh=m.marsh 
           --left join MarshoplDet d on m.nd=d.ndmarsh and m.marsh=d.marsh 
           left join [NearLogistic].nlListPayDet de on m.mhid=de.mhid
           join (select f1.mhid, sum(f1.weight) as smw from nc f1 group by f1.mhid) f on c.mhid=f.mhid
           join agentlist a on c.ag_id=a.ag_id 
           left join drivers r on m.drID=r.drID 
           join vehicle v on m.v_id=v.v_id 
           join carriers i on i.crID=v.crID 
           join Def ef on i.pin=ef.pin
           join def b on b.pin=c.b_id
 where c.datnom>=@StartDatnom and c.datnom<=@EndDatnom and c.marsh>0 and m.drID>0 
      and (i.crID=7 or /*isnull(d.VedNo,0)>0 or*/ isnull(de.ListNo,0)>0)
 group by c.nd, c.marsh, a.sv_ag_id, ef.pin, ef.brName, dck, de.oplatasum,de.bonus, f.smw, m.Driver, r.Fio, m.Dist, m.V_ID, i.crID, ef.Obl_ID, b.reg_id, c.stip,
          b.brName) t 
 group by t.nd,t.marsh,t.Dep,t.Pin,t.brName,t.DCK,t.kolvo,t.Napr,t.Comment,t.Dist,t.V_ID,t.Alien, t.Reg_ID, t.bReg_ID, t.Logistic, t.brNamec
 order by t.nd, t.marsh 

 
END