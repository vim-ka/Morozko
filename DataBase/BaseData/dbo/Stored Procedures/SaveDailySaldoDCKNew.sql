

CREATE procedure SaveDailySaldoDCKNew @nd datetime
as
declare @nn int
begin
  delete from DailySaldoDCK where ND=@ND;
  set @NN=dbo.InDatNom(9999, @nd);
  
  insert into DailySaldoDCK(Nd,B_ID, DCK, Debt, OverDue,Deep,OverUp17)
  select
    @ND as ND, a.b_id, a.dck, round(sum(a.Debt),2) debt, 
    round(sum(a.Overdue),2) overdue, 
    max(a.Deep) as Deep,
    round(sum(a.OverUp17),2) overUp17
  from
  (
  select
    t.pin as b_id,
    t.DCK,
    isnull(c.sp,0)-isnull(k.plata,0)+isnull(Z.NzIz,0) as Debt,
    0 as OverDue,
    0 as OverUp17,
    0 as Deep
  from DefContract t
    left join (select nc.dck, sum(NC.sp) as sp from NC where nc.datnom<=@NN and nc.b_id>0 and nc.tara=0 and nc.frizer=0 and nc.actn=0 group by nc.dck) c on c.dck=t.dck
    left join (select k.dck, sum(k.plata) as plata from Kassa1 k cross apply (select Isnull(Frizer,0)as Friz, DatNom from NC where NC.DatNom=k.SourDatNom and isnull(NC.Frizer,0)=0) a 
               where k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО') group by k.dck) k on k.dck=t.dck
    left join (select i.dck, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND group by i.dck) Z on Z.dck=t.dck
  where t.ContrTip=2

  union

  select NC.b_id,
         nc.dck,
         0 as Debt, 
         nc.sp-sum(isnull(k.plata,0))+isnull(Z.NzIz,0) as OverDue,
         0 as OverUp17,
         cast(@ND - (nc.nd+nc.srok) as int) as Deep
  from nc
    left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND 
    group by i.datnom) Z on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 and nc.srok>0
    and nc.nd+nc.srok+1 /* +15 */<= @ND
  group by nc.b_id, nc.dck, Nc.sp,isnull(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+isnull(Z.NzIz,0)>0
  
  union
  
  select NC.b_id,
         nc.dck,
         0 as Debt, 
         0 as OverDue,
         nc.sp-sum(isnull(k.plata,0))+isnull(Z.NzIz,0) as OverUp17,
         cast( @ND - (nc.nd+nc.srok) as int) as Deep
  from nc
    left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND 
    group by i.datnom) Z on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 and nc.srok>0
    and nc.nd+nc.srok+17 <= @ND
  group by nc.b_id, nc.dck, Nc.sp,isnull(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+isnull(Z.NzIz,0)>0
  ) a
  group by b_id,dck
  order by b_id,dck
END