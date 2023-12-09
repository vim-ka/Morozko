CREATE FUNCTION addr_warehouse.CellShortAddress(@cell_id int)
RETURNS varchar(8)
AS
BEGIN
  return isnull((select convert(varchar(2), (select stl_num from addr_warehouse.aw_stls where id = stl_id)) + ':' +
		convert(varchar(2), cell_column)  + ':' +
    convert(varchar(2), (select fl_type_name from addr_warehouse.aw_fl_types 
			where id = addr_warehouse.aw_cells.cell_fl))
    from addr_warehouse.aw_cells
    where id = @cell_id), '__:__:__')
END