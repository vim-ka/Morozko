CREATE PROCEDURE MobAgents.MobGetClientList @ag_id int
AS
BEGIN
--set transaction isolation level read uncommitted
declare @ND datetime, @NDY datetime
declare @SverkaCancel bit
declare @dn0 int, @dn1 bigint
declare @DelayBlockBuyer int
begin try
set @ND = dbo.today()
set @NDY = dateadd(day, -1,  dbo.today())
set @SverkaCancel = (select Merch from agentlist where ag_id=@ag_id)
set @dn0 = dbo.InDatNom(00000, @nd)
set @dn1 = dbo.InDatNom(99999, @nd)
set @DelayBlockBuyer =(select cast(val as int) from config where param='DelayBlockBuyer')


  create table #NeedDCK (dck int)
  
  insert into #NeedDCK (dck)
  select c.dck from defcontract c where c.ag_id=@ag_id or c.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0)
  union
  select b.add_dck from agaddbases b where b.ag_id=@ag_id and b.add_dck<>0
  
  
  if @ag_id = 243 
  insert into #NeedDCK (dck)
  select c.dck from defcontract c join dailysaldodck d on c.dck=d.dck and d.ND=@NDY
                                  join def f on c.pin=f.pin
  where d.Debt>0 and f.obl_id=1 and c.our_id<>23

  select c.* into #ncTemp from nc c join #NeedDCK nd on c.dck=nd.dck
  where c.Tara=0 and c.Frizer=0 and c.Actn=0 and
        ((c.datnom>=@dn0) or (c.SP+ISNULL(c.izmen,0)-c.Fact)>0)

select d.pin,
       c.dck,
       c.Ag_id, 
       (case when d.shortfam is null then d.brName else d.shortfam end)+
       '('+fc.OurAbbreviature+
       (case when fc.NDS = 1 and c.NDS = 1 then '-НДС' 
             when fc.NDS = 1 and isnull(c.NDS,0)=0 then '-БЕЗ НДС'        
             else ''
        end)           
       +')'
        
       as BrName,
       c.ContrName,
       (case when c.disab=1 then 'ЗАБЛОКИРОВАН' 
             when isnull(b.nddolg,0) > 0 and isnull(b.nddolg,0)<@DelayBlockBuyer then 'БЛОК Ч/З '+cast(@DelayBlockBuyer-b.nddolg as varchar)+' ДН.'   
             when isnull(b.nddolg,0) = @DelayBlockBuyer then 'БЛОК ЗАВТРА'           
             when isnull(b.nddolg,0) > @DelayBlockBuyer then 'БЛОК ВРЕМЕННО СНЯТ'
             when isnull(b.nddolg,-1) = 0 then 'ПРОСРОЧКА ЗАВТРА'   
             when isnull(b.nddolg,0) <= -1 then 'ПРОСРОЧКА Ч/3 '+cast(abs(b.nddolg) as varchar)+' ДН.'   
        else '' end) as Disab,
       isnull(b1.Overdue,0) as Overdue,    
       isnull(c.Extra,0) as Extra,
       isnull(s.Debt,0) + isnull(a.Duty,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0)  as Debit,
       c.Srok as Srok,
       isnull(c.[Limit],0) as Limit,
       d.PosX,
       d.PosY,
       d.gpAddr,
       d.gpPhone,
       d.Contact,
       (case when (@SverkaCancel = 1)  then ''
             when (d.NeedSver = 1) then 'i' 
             else '' end) as  NeedSver, 
       (case when (d.Prior = 1) then 'p' else '' end) as Prior,
       (case when (fc.NDS = 1)  then 'n' else '' end) as NDS,
       'Код точки: '+cast(d.pin as varchar(6))+' код договора: '+cast(c.dck as varchar(6)) as Remark
from Def d JOIN DefContract c on d.pin=c.pin and c.ContrTip = 2
           join FirmsConfig fc on c.Our_id=fc.Our_id
           join #NeedDCK e on c.dck=e.dck
           LEFT JOIN
           (select nc.DCK, sum(nc.Sp) as Duty
            from #ncTemp nc
            where nc.datnom>=@dn0
            group by nc.DCK) a on a.dck=c.dck
           LEFT JOIN
           (select DCK, sum(Plata) as Plata 
            from kassa1
            where nd>=@ND and oper=-2 and act='ВЫ'
            group by dck) k on k.dck=c.dck 
           LEFT JOIN
           (select DCK, sum(Izmen) as IzmenSP
            from NCIzmen
            where nd>=@ND 
            group by dck) i on i.dck=c.dck  
           LEFT JOIN DailySaldoDck s on c.dck=s.dck and s.ND=@NDY 
           LEFT JOIN
           (select nc.DCK,
                   cast(max(@ND - (nc.ND+nc.Srok))as int) as NDDolg, 
                   sum(nc.SP+ISNULL(nc.izmen,0)-nc.Fact) as Overdue
            from #ncTemp nc
            where (nc.SP+ISNULL(nc.izmen,0)-nc.Fact)>0
                  and nc.ND+nc.Srok-7 < @ND --начинаем информировать о просрочке за 7 дней
            group by nc.dck) b on b.dck=c.dck
           LEFT JOIN
           (select nc.DCK,
                   sum(nc.SP+ISNULL(nc.izmen,0)-nc.Fact) as Overdue
            from #ncTemp nc
            where (nc.SP+ISNULL(nc.izmen,0)-nc.Fact)>0
                  and nc.ND+nc.Srok+1 <= @ND 
            group by nc.dck) b1 on b1.dck=c.dck
            
       
where d.Actual=1 and c.Actual=1

union

select 99998 as pin,
       99998 as dck,
       0 as brAg_id, 
       'РАЗБЛОКИРОВКА ТОЧЕК' as BrName,
       '' as ContrName,
        '' as Disab,
       0 as Overdue,
       0 as Extra,
       0 as Debit,
       0 as Srok,
       0 as Limit, 
       0 as PosX,
       0 as PosY,
       '' as gpAddr,
       '' as gpPhone,
       '' as Contact,
       '' as NeedSver,
       '' as Prior,
       '' as NDS,
       '' as Remark
       
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
       0 as Srok,
       0 as Limit, 
       0 as PosX,
       0 as PosY,
       '' as gpAddr,
       '' as gpPhone,
       '' as Contact,
       'i' as NeedSver,
       '' as Prior,
       '' as NDS,
       '' as Remark

drop table #NeedDCK
end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
  end catch

END