CREATE PROCEDURE dbo.CalcBrExtra
AS
BEGIN
  declare @ND datetime
  set @ND = dbo.InDate(DATEADD(day,-day(DATEADD(MONTH,-1,GETDATE()))+1,DATEADD(MONTH,-1,GETDATE())))
  truncate table BrCalcExt; 
  insert into BrCalcExt (b_id,hitag,price,cost,kol,tmp,setextra, Ncod) 
  select nc.B_ID,
         nv.Hitag,
         avg(nv.price*(nc.Extra+100)/100) price,
         avg(nv.cost) cost,
         sum(nv.kol) as kol,
         sum(nv.kol)/(dbo.DaysInMonth(@ND)+Day(GETDATE()) ) as tmp,
         avg(case when nv.cost<>0 then (100*(nv.price-nv.cost)/NV.cost) else 0 end) as extra,
         (select max(v.ncod) from visual v where v.hitag=nv.hitag) as Ncod
  from nc,nv 
  where nc.DatNom=nv.datnom 
    and nc.nd>=@ND
    and nv.kol>0
  group by nc.B_ID,nv.Hitag
END