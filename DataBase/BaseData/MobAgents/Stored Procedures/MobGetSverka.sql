CREATE PROCEDURE MobAgents.MobGetSverka @ag_id int, @NeedDay datetime
AS
BEGIN
  declare @NDY datetime
  set @NDY = dateadd(day, -1,  dbo.today())

--set transaction isolation level read uncommitted
declare @ndstart datetime
declare @dn0 int, @dn1 bigint
begin try
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

set @ndstart=dateadd(day,-1, @NeedDay)
set @dn0 = dbo.InDatNom(0000, @NeedDay)
set @dn1 = dbo.InDatNom(9999, @NeedDay)

  select n.* into #ncTemp from nc n
  where n.datnom>=@dn0 and n.dck in (select dck from #NeedDCK) /*and n.sp<>0*/ and n.tara=0 and n.frizer=0 and n.actn=0 

--**************начальное сальдо*************************
/*select d.dck as pin,
       @NeedDay as Nd,
       'startsaldo' as Rem,
       isnull((select sum(sp) as Sp from nc where dck =d.dck and nd<@ndstart and Tara!=1 and Frizer!=1 and Actn!=1),0) +
       isnull((select sum(izmen) as Izmen from  ncizmen where dck =d.dck and  nd<@ndstart),0) -
       isnull((select sum(plata) plata from kassa1 where dck =d.dck and nd<@ndstart and (act='ВЫ' or act='ВО') and oper=-2),0) as Debet,
       0 as Kredit
from defcontract d join def e on d.pin=e.pin                   
where d.dck in
  (select c.dck from defcontract c where c.ag_id=@ag_id
                or c.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0)
   union select b.add_dck from agaddbases b where b.ag_id=@ag_id and b.add_dck<>0)*/
   
--**************начальное сальдо*************************   
select c.dck as pin,
       @NeedDay as Nd,
       'startsaldo' as Rem,
       isnull(d.Debt,0) as Debet,
       0 as Kredit,
       '00:00:00' as tm
from defcontract c left join DailySaldoDCK d on c.dck=d.dck and d.ND=@ndstart
where c.dck in (select dck from #NeedDCK)
      

union
--**********************отгрузка*************************
/*select n.dck as pin,n.nd,
       case when n.sp>0 then 'РасхНакл №'+cast(dbo.InNnak(datnom) as varchar) 
                        else 'ВозвНакл №'+cast(dbo.InNnak(datnom) as varchar) end as Rem,
       n.sp as Debet,
       0 as Kredit,
       n.tm
from nc n where n.datnom>=@dn0 and n.dck in (select dck from #NeedDCK) and n.sp<>0 and n.tara=0 and n.frizer=0 and n.actn=0 
   
union*/

--**********************отгрузка*************************
select n.dck as pin,
       n.nd,
       'РасхНакл №'+cast(dbo.InNnak(datnom) as varchar) as Rem,
       n.sp + isnull(b.sp,0) as Debet,
       0 as Kredit,
       n.tm
from #ncTemp n left join (select nd.startdatnom, sum(nd.sp) as sp
                          from #ncTemp nd where nd.sp>0 and nd.refdatnom>0
                          group by nd.startdatnom) b on b.startdatnom=n.datnom
where n.sp>=0 and n.refdatnom=0

union

--**********************возвраты по накладным*************************
/*select n.dck as pin,
       n.nd,
       'ВозвНакл №'+--cast(dbo.InNnak(MIN(n.datnom)) as varchar) as Rem,
       
       stuff(
       (select ', '+cast(dbo.InNnak(t.datnom) as varchar) from #ncTemp t where t.dck=n.dck and n.nd=t.nd and t.sp<0 and t.remark<>'' order by 1
       for xml path('')),1,2,'') as Rem,
       
       sum(n.sp) as Debet,
       0 as Kredit,
       min(n.tm) as tm
from #ncTemp n where n.sp<0 and n.remark<>''
group by n.dck,n.nd

union*/

--**********************возвраты по актам *************************
select n.dck as pin,
       max(n.nd) as nd,
       iif(isnull(k.rk,0)=0,'Возврат без акта',
       'Акт №'+cast(isnull(k.rk,0) as varchar)+' от '+
       Format(r.nd, 'd', 'de-de')) as Rem,
       sum(n.sp) as Debet,
       0 as Kredit,
       min(n.tm) as tm
from #ncTemp n left join ReqReturnNCLink k on n.datnom=k.datnom
               left join Requests r on k.rk=r.rk      
where n.sp<0 and n.remark<>''
group by n.dck,isnull(k.rk,0), r.nd

union

--**********************вычерки*************************
select n.dck as pin,
       n.nd,
       'Вычерк №'+cast(dbo.InNnak(n.datnom) as varchar) 
       +' к накл.№'+cast(dbo.InNnak(n.refdatnom) as varchar)
       +' от '+convert(varchar, dbo.DatNomInDate(n.refdatnom),104) as Rem,
       n.sp as Debet,
       0 as Kredit,
       n.tm as tm
from #ncTemp n where n.sp<0 and n.remark=''

union

--***********************оплата*************************
select k.dck as pin,
       iif(isnull(k.Bank_id,0)<>0, k.BankDay, k.Nd) as Nd,
       iif(isnull(k.Bank_id,0)<>0, 'Оплата безнал.', 'Оплата нал.') as Rem,
       0 as Debet, sum(k.plata) as Kredit, k.tm
from kassa1 k 
where ((k.nd>=@NeedDay and isnull(k.Bank_id,0)=0) or
       (k.BankDay>=@NeedDay and isnull(k.Bank_id,0)<>0)) 
        and k.Oper=-2 and k.ACT='ВЫ' 
        and k.dck in (select dck from #NeedDCK)
group by k.dck,k.nd, k.tm,k.Bank_id, k.BankDay
having sum(k.plata)<>0

union
--*********************переоценка*************************
select i.dck as pin,i.nd,'ПереоцНакл №'+cast(Nnak as varchar) as Rem,i.izmen as Debit,0 as Kredit, i.tm 
from NCIzmen i
where i.nd>=@NeedDay and i.Izmen<>0 and i.dck in (select dck from #NeedDCK)

order by pin,nd,tm

drop table #NeedDCK
end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
  end catch

END