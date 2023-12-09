CREATE FUNCTION addr_warehouse.CalcCellFreeVol(@w_cell int)
RETURNS numeric(10, 5)
AS
BEGIN
  declare @cell_free_vol numeric(10, 5)
  
  select @cell_free_vol = 
	case when t.stl_tip = 1 then
	(select w_cell_idx_freevol from addr_warehouse.aw_wares where w_cell = t.id)
	when t.stl_tip = 0 then
	(select sum(w_cell_idx_freevol) from addr_warehouse.aw_wares where w_cell = t.id) end
  from
	(
	select s.stl_num, s.stl_tip, c.id
	from addr_warehouse.aw_cells c
	left join addr_warehouse.aw_stls s on s.id = c.stl_id
	where c.id = @w_cell
	) t
	left join addr_warehouse.aw_stls st on st.stl_num = t.stl_num
	left join addr_warehouse.aw_wares w on w.w_cell = t.id
  group by 
	t.stl_tip, 
	t.id
    
  return round(@cell_free_vol, 3)
END