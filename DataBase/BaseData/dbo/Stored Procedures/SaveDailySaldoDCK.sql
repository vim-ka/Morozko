CREATE procedure dbo.SaveDailySaldoDCK @nd datetime
as
declare @nn bigint
begin
  begin try
  delete from DailySaldoDCK where ND=@ND;
  set @NN=dbo.InDatNom(99999, @nd);
   
  insert into DailySaldoDCK(Nd,B_ID, DCK, Debt, OverDue,Deep,OverUp17)
  select
    @ND as ND, a.b_id, a.dck, round(sum(a.Debt),2) debt, 
    round(sum(a.Overdue),2) overdue, 
    max(a.Deep) as Deep,
    round(sum(a.OverUp17),2) overUp17
  from
  (
  select
    NC.b_id, NC.DCK, NC.datnom,  
    nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0) as Debt, 0 as OverDue, 0 as OverUp17, 0 as Deep, nc.nd, nc.srok
  from nc
    left join Kassa1 k on 
      k.sourdatnom=nc.datnom 
      and iif(k.Bank_ID=0,k.nd, k.BankDay)<=@ND 
      and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND group by i.datnom) Z 
      on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 --and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 
  group by nc.b_id, nc.dck, NC.Datnom, Nc.sp,ISNULL(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)<>0

  union

  select
    NC.b_id, nc.dck, NC.datnom, 0 as Debt, 
    nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0) as OverDue,
    0 as OverUp17,
    cast( @ND - (nc.nd+nc.srok) as int) as Deep, nc.nd, nc.srok
  from nc
    left join Kassa1 k on 
      k.sourdatnom=nc.datnom 
      and iif(k.Bank_ID=0,k.nd, k.BankDay)<=@ND 
      and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND 
    group by i.datnom) Z on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 --and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 
    and nc.nd+nc.srok/* +15 */< @ND
  group by nc.b_id, nc.dck, NC.Datnom, Nc.sp,ISNULL(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)>0
  
  union
  
  select
    NC.b_id, nc.dck, NC.datnom, 0 as Debt, 
    0 as OverDue,
    isnull(nc.sp,0)-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0) as OverUp17,
    cast( @ND - (nc.nd+nc.srok) as int) as Deep, nc.nd, nc.srok
  from nc
    left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND 
    group by i.datnom) Z on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 --and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 
    and nc.nd+nc.srok+17 <= @ND
  group by nc.b_id, nc.dck, NC.Datnom, Nc.sp,ISNULL(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)>0
  
  ) a
  group by b_id,dck
  order by b_id,dck
  end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid)
  end catch  
END