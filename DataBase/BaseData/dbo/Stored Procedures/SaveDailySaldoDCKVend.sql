CREATE procedure dbo.SaveDailySaldoDCKVend @nd datetime
as
declare @nn int
begin
  begin try
  delete from DailySaldoDCKVend where ND=@ND;
  
  insert into DailySaldoDCKVend(Nd, pin, DCK, Cred, OverDueCredit, DeepCredit)
  select
    @ND as ND,
    a.ncod,
    a.dck,
    round(sum(a.Cred),2) Cred, 
    round(sum(a.OverdueCredit),2) overdueCredit, 
    max(a.DeepCredit) as DeepCredit
  from
  (
  select
    C.ncod, 
    C.DCK, 
    C.ncom,  
    c.summacost-sum(isnull(k.plata,0))+isnull(z.CommanCorr,0)+isnull(zi.IzmC,0)+isnull(zs.Snyat,0) as Cred,
    0 as OverDueCredit,
    0 as DeepCredit,
    c.[date],
    c.srok
  from comman c
    left join Kassa1 k on k.nnak=c.ncom and iif(k.Bank_ID=0,k.nd, k.BankDay)<=@ND  and k.oper=-1 --and k.Act in ('ВЫ','ВО')
    left join (select i.ncom, sum(i.corr) as CommanCorr from CommanCorr i where i.nd<=@ND group by i.ncom) z on z.ncom=c.ncom
    left join (select i.ncom, sum(i.smi) as IzmC from izmen i where i.Nd <=@ND and i.Act='ИзмЦ' and i.smi<>0 group by i.ncom) zi on zi.ncom=c.ncom
    left join (select i.ncom, sum(i.smi) as Snyat from izmen i where i.Nd <=@ND and i.Act='Снят' and i.smi<>0 group by i.ncom) zs on zs.ncom=c.ncom
  where
    c.[date]>'20050101' and c.[date]<=@Nd and c.ncod>0 
  group by c.ncod, c.dck, C.ncom, c.summacost,isnull(z.CommanCorr,0),isnull(zi.IzmC,0),isnull(zs.Snyat,0), c.[date], c.srok
  having abs(c.summacost-sum(isnull(k.plata,0))+isnull(z.CommanCorr,0)+isnull(zi.IzmC,0)+isnull(zs.Snyat,0))>0.01

  union

   select
    C.ncod,
    c.dck, 
    C.Ncom,
    0 as Cred, 
    c.summacost-sum(isnull(k.plata,0))+isnull(z.CommanCorr,0)+isnull(zi.IzmC,0)+isnull(zs.Snyat,0) as OverDueCredit,
    cast( @ND - (c.[date]+c.srok) as int) as DeepCredit,
    c.[date],
    c.srok
  from comman c left join Kassa1 k on  k.nnak=c.ncom  and iif(k.Bank_ID=0,k.nd, k.BankDay)<=@ND  and k.oper=-1 --and k.Act in ('ВЫ','ВО')
    left join (select i.ncom, sum(i.corr) as CommanCorr from CommanCorr i where i.nd<=@ND group by i.ncom) Z on z.ncom=c.ncom
    left join (select i.ncom, sum(i.smi) as IzmC from izmen i where i.Nd<=@ND and i.Act='ИзмЦ' and i.smi<>0 group by i.ncom) zi on zi.ncom=c.ncom
    left join (select i.ncom, sum(i.smi) as Snyat from izmen i where i.Nd<=@ND and i.Act='Снят' and i.smi<>0 group by i.ncom) zs on zs.ncom=c.ncom
  where
    c.[date]>'20050101' and c.[date]<=@Nd and c.ncod>0 
    and c.[date]+c.srok/* +15 */< @ND
 group by c.ncod, c.dck, C.ncom, c.summacost,isnull(z.CommanCorr,0),isnull(zi.IzmC,0),isnull(zs.Snyat,0), c.[date], c.srok
 having abs(c.summacost-sum(isnull(k.plata,0))+ISNULL(z.CommanCorr,0)+isnull(zi.IzmC,0)+isnull(zs.Snyat,0))>0.01
  
  ) a
  group by Ncod,dck
  having round(sum(a.Cred),2)<>0 
  order by Ncod,dck
  end try
  begin catch
    insert into ProcErrors(errnum, errmess, procname) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid)
  end catch  
END