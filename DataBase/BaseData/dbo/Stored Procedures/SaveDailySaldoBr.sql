CREATE procedure dbo.SaveDailySaldoBr @nd datetime
as
declare @nn bigint
begin
  delete from DailySaldoBR where ND=@ND;
  set @NN=dbo.InDatNom(99999, @nd);
   
  insert into DailySaldoBR(Nd,B_ID,Debt, OverDue,Deep)
  select
    @ND as ND, a.b_id, round(sum(a.Debt),2) debt, 
    round(sum(a.Overdue),2) overdue, 
    max(a.Deep) as Deep
  from
  (
  select
    NC.b_id, NC.datnom,  
    nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0) as Debt,
    0 as OverDue,
    0 as OverUp17,
    0 as Deep,
    nc.nd,
    nc.srok
  from nc
    left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND group by i.datnom) Z 
      on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 --and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 
  group by nc.b_id,  NC.Datnom, Nc.sp,ISNULL(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)<>0

  union

  select
    NC.b_id, NC.datnom,
    0 as Debt, 
    nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0) as OverDue,
    0 as OverUp17,
    cast( @ND - (nc.nd+nc.srok) as int) as Deep, 
    nc.nd,
    nc.srok
  from nc
    left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND 
    group by i.datnom) Z on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 --and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 
    and nc.nd+nc.srok /* +15 */< @ND
  group by nc.b_id, NC.Datnom, Nc.sp,ISNULL(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)>0
  
  ) a
  group by b_id
  order by b_id
  
  
  
  /*insert into DailySaldoBR(Nd,B_ID,Debt, OverDue,Deep)
  select
    @ND as ND, a.b_id, round(sum(a.Debt),2) debt, 
    round(sum(a.Overdue),2) overdue, 
    max(a.Deep) as Deep
  from
  (
  select
    NC.b_id, NC.datnom,  
    nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0) as Debt, 0 as OverDue, 0 as Deep, nc.nd, nc.srok
  from nc
    left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND group by i.datnom) Z 
      on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 and nc.srok>0
  group by nc.b_id, NC.Datnom, Nc.sp,ISNULL(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)>0

  union

  select
    NC.b_id, NC.datnom, 0 as Debt, 
    nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0) as OverDue,
    cast( @ND - (nc.nd+nc.srok) as int) as Deep, nc.nd, nc.srok
  from nc
    left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND 
    group by i.datnom) Z on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 and nc.srok>0
    and nc.nd+nc.srok+1 /* +15 */<= @ND
*//*  group by nc.b_id, NC.Datnom, Nc.sp,ISNULL(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)>0
  ) a
  group by b_id
  order by b_id*/
  
END