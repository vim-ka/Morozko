CREATE PROCEDURE LoadData.UnnamedSuperProcedure2 @nd0 datetime, @nd1 datetime
AS
BEGIN
  set transaction isolation level read uncommitted 
  declare
  	@dn1 int,
    @dn2 int
    
  set @dn1 = dbo.InDatNom(0000, @nd0)
  set @dn2 = dbo.InDatNom(9999, @nd1)    
    
  select 
  al.sv_ag_id,    
  n.Ngrp,  
  f.pin,
  sum(iif(v.weight=0, n.Netto, v.weight)*(nv.kol - nv.Kol_B)) wgt -- вес по продажам минус возвраты
  from
  dbo.nv nv
  inner join dbo.nc nc on nc.datnom = nv.datnom  
  inner join dbo.DefContract dc on dc.dck = nc.dck
  inner join dbo.AgentList al on al.AG_ID = dc.ag_id
  inner join dbo.visual v on v.id = nv.TekID
  inner join dbo.def f on f.ncod=v.ncod
  inner join dbo.nomen n on n.hitag = nv.hitag    
  where
  nv.datnom >= @dn1 and nv.datnom <= @dn2
  group by al.sv_ag_id, n.ngrp, f.pin
  having sum(iif(v.weight = 0, n.Netto, v.weight)*(nv.kol-nv.Kol_B)) <> 0
  and n.ngrp <> 0 
  order by al.sv_ag_id, n.ngrp


END