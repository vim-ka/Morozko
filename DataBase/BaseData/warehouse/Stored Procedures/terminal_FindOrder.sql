CREATE PROCEDURE warehouse.terminal_FindOrder
@datnom int
AS
BEGIN
  select c.datnom,
  			 iif(c.mhid=0,r.RegionID,c.mhid) [mhid],
         cast(min(cast(z.done as int)) as bit) [done]
  from dbo.nc c
  join dbo.def d on d.pin=c.b_id
  join dbo.regions r on r.reg_id=d.reg_id
  join dbo.nvzakaz z on z.datnom=c.datnom
  where c.datnom=@datnom
  group by c.datnom, iif(c.mhid=0,r.RegionID,c.mhid) 			
END