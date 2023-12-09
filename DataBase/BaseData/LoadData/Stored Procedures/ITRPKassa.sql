CREATE PROCEDURE [LoadData].ITRPKassa @DateStart datetime, @DateEnd datetime
AS
BEGIN
 SET NOCOUNT ON
 select k.nd as DATE, 
        k.tm as TIME, 
        k.oper as N_OPER, 
        k.stnom-100*Round(k.stnom/100,0,1) as N_POPER, 
        k.kassID as CODE, 
        k.Our_ID as CODE_O, 
        k.KassaNo as CODE_KS, 
        k.bank_id as CODE_B,  
        case  
          when isnull(l.ag_id,0)>0 and k.stnom-100*Round(k.stnom/100,0,1)=1 then l.sv_ag_id 
          when isnull(l.ag_id,0)>0 then l.DepID 
          when k.oper = -2 then (select sv_ag_id from agentlist where ag_id=(select isnull(t.ag_id,0) from DefContract t where t.dck=k.dck))  
          else k.DepID   
        end as CODE_PR, 
        l.ag_id, 
        k.Remark as PRIM, 
        k.plata as SUM, 
        o.rashflag as Fl_Rashod, 
        case when k.oper=-2 and k.op>1000 then 1 else 0  
        end as TA, 
        case when k.oper=-2 then (select isnull(master,0) from def where pin=b_id) else 0 end as CODE_S,  
        case when k.bank_id>0 then 1 else 0 end as BANK,  
        case when k.oper=-2 then b_id   
             when k.oper=-1 then (select e.pin from def e where e.ncod=k.ncod)  
        end as CODE_K, 
        k.DCK as CODE_D, 
        case when p.DepID=26 then 3086 --Рестория
             when p.DepID=27 then 227 --СВ-Сервис
             when (k.op>1000) then (select max(l.p_id) from agentlist l where l.ag_id=(k.Op-1000))
             else k.p_id end as CODE_FL,
        isnull(k.RealOper,0) as LV
        into #KassaITRPTemp
 from kassa1 k join ksoper o on k.oper=o.oper
               left join person p on k.p_id=p.p_id 
               left join (select p_id, ag_id, sv_ag_id, DepID from agentlist) l on p.p_id=l.p_id 
               join (select min(a1.ag_id) as ag_ids, a1.p_id as p_ids from agentlist a1 group by p_id) t2 on isnull(l.ag_id,0)=t2.ag_ids
 where k.nd>=@DateStart and k.nd<=@DateEnd
 order by DATE,TIME 
 
 select * from #KassaITRPTemp order by DATE,TIME 
 
END