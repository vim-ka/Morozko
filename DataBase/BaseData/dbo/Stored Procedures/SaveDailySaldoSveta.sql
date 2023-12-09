CREATE procedure SaveDailySaldoSveta @nd datetime
as
declare @nn int
begin
  delete from DailySaldoSveta where ND=@ND;
  set @NN=dbo.InDatNom(9999, @nd);
  
/*create table DailySaldoSveta(Nd datetime, B_ID int, DCK int, Debt decimal(12,2),
  Overdue decimal(12,2), Deep int,
  OverUp17 decimal(12,2),
  OverUp10 decimal(12,2),
  OverUp0 decimal(12,2))
*/  
  insert into DailySaldoSveta(Nd,B_ID, DCK, Debt, OverDue,Deep,OverUp17, OverUp10,OverUp0)
  select
    @ND as ND, a.b_id, a.dck, round(sum(a.Debt),2) debt, 
    round(sum(a.Overdue),2) overdue, 
    max(a.Deep) as Deep,
    round(sum(a.OverUp17),2) overUp17,
    round(sum(a.OverUp10),2) overUp10,
    round(sum(a.OverUp0),2) overUp0
  from
  (
  select
    NC.b_id, NC.DCK, NC.datnom,  
    nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0) as Debt, 0 as OverDue, 
    0 as OverUp17, 0 as OverUp10, 0 as OverUp0, 
    0 as Deep, nc.nd, nc.srok
  from nc
    left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND group by i.datnom) Z 
      on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 
  group by nc.b_id, nc.dck, NC.Datnom, Nc.sp,ISNULL(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)>0

  union

  select
    NC.b_id, nc.dck, NC.datnom, 0 as Debt, 
    nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0) as OverDue,
    0 as OverUp17, 0 as OverUp10, 0 as OverUp0, 
    cast( @ND - (nc.nd+nc.srok) as int) as Deep, nc.nd, nc.srok
  from nc
    left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND 
    group by i.datnom) Z on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 
    and nc.nd+nc.srok+1 /* +15 */<= @ND
  group by nc.b_id, nc.dck, NC.Datnom, Nc.sp,ISNULL(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)>0
  
  union
  
  select
    NC.b_id, nc.dck, NC.datnom, 0 as Debt, 
    0 as OverDue,
    nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0) as OverUp17,
    0 as OverUp10, 0 as OverUp0,     
    cast( @ND - (nc.nd+nc.srok) as int) as Deep, nc.nd, nc.srok
  from nc
    left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND 
    group by i.datnom) Z on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 
    and nc.nd+nc.srok+17 <= @ND
  group by nc.b_id, nc.dck, NC.Datnom, Nc.sp,ISNULL(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)>0
  
  union
  
  select
    NC.b_id, nc.dck, NC.datnom, 0 as Debt, 
    0 as OverDue,
    0 as OverUp17,
    nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0) as OverUp10,
    0 as OverUp0,     
    cast( @ND - (nc.nd+nc.srok) as int) as Deep, nc.nd, nc.srok
  from nc
    left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND 
    group by i.datnom) Z on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0
    and nc.nd+nc.srok+10<=@ND and nc.nd+nc.srok+17>@ND
  group by nc.b_id, nc.dck, NC.Datnom, Nc.sp,ISNULL(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)>0
  
  union
  
  select
    NC.b_id, nc.dck, NC.datnom, 0 as Debt, 
    0 as OverDue,
    0 as OverUp17,
    0 as OverUp10,
    nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0) as OverUp0,
    cast( @ND - (nc.nd+nc.srok) as int) as Deep, nc.nd, nc.srok
  from nc
    left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
    left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND 
    group by i.datnom) Z on Z.datnom=nc.datnom
  where
    nc.datnom<=@NN and nc.b_id>0 and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 
    and nc.nd+nc.srok+0 <= @ND and nc.nd+nc.srok+10>@ND
  group by nc.b_id, nc.dck, NC.Datnom, Nc.sp,ISNULL(Z.NzIz,0), nc.nd, nc.srok
  having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)>0
  
  ) a
  group by b_id,dck
  order by b_id,dck
END