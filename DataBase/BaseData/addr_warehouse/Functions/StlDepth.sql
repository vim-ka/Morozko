CREATE FUNCTION addr_warehouse.StlDepth(@stl_id int)
RETURNS int
AS
BEGIN
  declare @stl_depth int
    
  select @stl_depth = max(s.stl_depth) from addr_warehouse.aw_stls s where s.stl_num =
    (select stl_num from addr_warehouse.aw_stls where id = @stl_id)
    
  return @stl_depth
END