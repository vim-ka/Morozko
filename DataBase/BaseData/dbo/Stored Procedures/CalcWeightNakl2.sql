CREATE PROCEDURE dbo.CalcWeightNakl2 @day0 datetime, @day1 datetime
AS
BEGIN
  declare
  @dn0 int,
  @dn1 int
  
  set @dn0 = dbo.InDatNom(0000, @day0)
  set @dn1 = dbo.InDatNom(9999, @day1)
  
  create table #nkls(datnom int, massa numeric(10, 3))
  insert into #nkls
  select c.datnom, 
  case when dbo.DatNomInDate(c.datnom) = dateadd(Day,datediff(Day,0,getdate()),0) then isnull(sum(v.kol*(iif(vi.weight>0,vi.weight, isnull(n.netto,0)))),0)
  else isnull(sum(v.kol*(iif(vis.weight>0,vis.weight, isnull(n.netto,0)))),0) end massa
  from dbo.nc c
  inner join dbo.nv v on v.datnom = c.datnom
  inner join nomen n on v.hitag = n.hitag
  left join tdvi vi on v.tekid = vi.id 
  left join visual vis on v.tekid=vis.id
  where
  c.datnom >= @dn0 and c.datnom <= @dn1
  group by c.datnom
  
  
  
 /*declare @Massa numeric(10,3)

 if dbo.DatNomInDate(@DatNom) = dateadd(Day,datediff(Day,0,getdate()),0)

 select @Massa=isnull(sum(v.kol*(iif(vi.weight>0,vi.weight, isnull(n.netto,0)))),0) 
 from nv v left join nomen n on v.hitag=n.hitag
           left join tdvi vi on v.tekid=vi.id 
 where v.datnom=@DatNom   
 
 else
 
 select @Massa=isnull(sum(v.kol*(iif(vi.weight>0,vi.weight, isnull(n.netto,0)))),0) 
 from nv v left join nomen n on v.hitag=n.hitag
           left join visual vi on v.tekid=vi.id 
 where v.datnom=@DatNom */
 select * from #nkls
 drop table #nkls
END