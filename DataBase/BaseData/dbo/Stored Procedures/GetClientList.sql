CREATE PROCEDURE dbo.GetClientList @ag_id int
AS
BEGIN

select d.pin,
       c.dck,
       c.Ag_id, 
       (case when d.shortfam is null then d.brName else d.shortfam end)+
       (case when c.Our_id = 6 then '(Л)'
             when c.Our_id = 7 then '(М)'
             when c.Our_id = 8 then '(К)'
        end)      
        as BrName,
       c.ContrName,
       (case when d.disab=1 then 'ЗАБЛОКИРОВАН' 
             when isnull(b.nddolg,0)>0 and isnull(b.nddolg,0)<4 then 'БЛОК Ч/З '+cast(5-b.nddolg as varchar)+' ДНЯ'   
             when isnull(b.nddolg,0)=4 then 'БЛОК Ч/З '+cast(5-b.nddolg as varchar)+' ДЕНЬ'           
             when isnull(b.nddolg,0)>=5 then 'БЛОК ВРЕМЕННО СНЯТ'
        else '' end) as Disab,
       isnull(B.Overdue,0) as Overdue,
       c.Extra,
       isnull(A.Duty,0) as Debit,
       c.Srok as Tara,--isnull(t.Tara,0) as Tara,
       c.[Limit],
       d.PosX,
       d.PosY,
       d.gpAddr,
       d.gpPhone,
       d.Contact,
       (case when (d.NeedSver = 1) then 'i' else '' end) as  NeedSver,
       (case when (d.Prior = 1) then 'p' else '' end) as Prior
from Def d JOIN DefContract c on d.pin=c.pin and c.ContrTip=2
           LEFT JOIN
           (select sum(Sp+Izmen)-sum(Fact)as Duty,dck 
            from nc
            where Tara!=1 and Frizer!=1 and Actn!=1
            group by dck) a on a.dck=c.dck
           LEFT JOIN
           (select cast((GETDATE()- max(ND+Srok) )as int) as NDDolg, dck,
                   sum(nc.SP+ISNULL(nc.izmen,0)-nc.Fact) as Overdue
            from nc
            where (RefDatNom=0 OR RefDatNom is null) and ND+Srok+1<GETDATE() and
                  (nc.SP+ISNULL(nc.izmen,0)-nc.Fact)>0  and Tara!=1 and Frizer!=1 and Actn!=1
            group by dck) b on b.dck=c.dck
            /*LEFT JOIN
            (select b_id,SUM(kol) as Tara from taradet group by b_id)t on t.b_id=d.pin*/
       
where c.ag_id=@ag_id or c.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0) or c.dck in (select b.add_dck from agaddbases b where b.ag_id=@ag_id and b.add_dck<>0)
union
select 99999 as pin,
       99999 as dck,
       0 as brAg_id, 
       'Конец рабочего дня' as BrName,
       '' as ContrName,
        '' as Disab,
       0 as Overdue,
       0 as Extra ,
       0 as Debit,
       0 as Tara,
       0 as Limit, 
       0 as PosX,
       0 as PosY,
       '' as gpAddr,
       '' as gpPhone,
       '' as Contact,
       '' as NeedSver,
       '' as Prior

END