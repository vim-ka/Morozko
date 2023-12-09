create procedure FillPlanSell
as
declare @WD int -- текущий день недели, 1-понедельник, 7-воскресенье
declare @StartDate datetime, @DaysNum int
begin
  set @wd=(select DATEPART(dw, dbo.today()));
  set @StartDate = DATEADD(month, -3, getdate());
  
  delete from PlanSell where nd<=@StartDate or Nd=dbo.today();

  insert into PlanSell(nd,dck,hitag,flgWeight,qty)
  select 
    dbo.today() as ND,
    nc.DCK,
    nv.hitag,
    nm.flgWeight,
    0.8*sum((nv.Kol-nv.kol_b)*iif(nm.flgWeight=0,1,iif(v.weight>0,v.weight,nm.netto))) as Qty
  from 
    nc
    inner join nv on nv.datnom=nc.datnom
    inner join visual v on v.id=nv.tekid
    inner join nomen nm on nm.hitag=nv.hitag
  where
    nc.ND>=@StartDate and nc.nd<dbo.today()
    and datepart(dw, nc.nd)=@WD
    and nc.actn=0 and nc.Tara=0 and nc.Frizer=0
  group by 
    nc.DCK, nv.hitag,  nm.flgWeight
  having 0.8*sum((nv.Kol-nv.kol_b)*iif(nm.flgWeight=0,1,iif(v.weight>0,v.weight,nm.netto)))>0;
  
  set @DaysNum  =(select count(distinct ND) 
  		from NC where nc.ND>=@StartDate and nc.nd<dbo.today()
	    and datepart(dw, nc.nd)=@WD);
  update PlanSell set qty = qty/@DaysNum where nd=dbo.today();
end;