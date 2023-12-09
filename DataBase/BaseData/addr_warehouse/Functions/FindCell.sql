CREATE FUNCTION addr_warehouse.FindCell(@hitag int, @sklad int)
RETURNS int
AS
BEGIN
  declare @w_cell int
  declare @tempid int
  declare @id int
  declare @skg int
  declare @volminp numeric(10, 5)

  select @skg = skg from skladlist where skladno = @sklad
  select @volminp = volminp from dbo.Nomen where hitag = @hitag
  
  --первичный поиск: проверяем ярусы В,С
  select @w_cell = min(w.w_cell), @tempid = min(w.id)
  from addr_warehouse.aw_wares w
  left join addr_warehouse.aw_cells c on c.id = w.w_cell
  where (w.w_hitag = @hitag and w.w_cell_idx_freevol >= @volminp)
  and c.skg = @skg
  and c.cell_fl in (4, 5) -- B, C
  and c.cell_blocked = 0  
  
  set @id = @tempid
  if @w_cell is null
  begin
  	--поиск товара в ярусах А0, А1
    select @w_cell = min(w.w_cell), @tempid = min(w.id)
	from addr_warehouse.aw_wares w
    left join addr_warehouse.aw_cells c on c.id = w.w_cell
    where w.w_hitag = @hitag and w.w_cell_idx_freevol >= @volminp
    and c.skg = @skg
    and c.cell_fl in (2, 3) -- A0, A1
    and c.cell_blocked = 0    
    
    set @id = @tempid      
    if @w_cell is null
    begin
      --поиск свободной ячейки в A0, A1
      select @w_cell = min(w.w_cell), @tempid = min(w.id)
      from addr_warehouse.aw_wares w
      left join addr_warehouse.aw_cells c on c.id = w.w_cell
      where w.w_hitag is null and w.w_cell_idx_freevol >= @volminp
      and c.skg = @skg
      and c.cell_fl in (2, 3) -- A0, A1
      and c.cell_blocked = 0
      
      set @id = @tempid      
      if @w_cell is null
      begin
      	--повторный поиск в ярусах В, С
        select @w_cell = min(w.w_cell), @tempid = min(w.id)
		from addr_warehouse.aw_wares w
		left join addr_warehouse.aw_cells c on c.id = w.w_cell
		where w.w_hitag is null and w.w_cell_idx_freevol >= @volminp
		and c.skg = @skg
		and c.cell_fl in (4, 5) -- B, C
        and c.cell_blocked = 0

        set @id = @tempid              
        if @w_cell is null
        begin  
          --поиск ячейки в зонах временного хранения Х0
          select @w_cell = min(w.w_cell), @tempid = min(w.id)
          from addr_warehouse.aw_wares w
          left join addr_warehouse.aw_cells c on c.id = w.w_cell
          where c.skg = @skg
          and w.w_cell_idx_freevol >= @volminp
          and c.cell_fl = 1 --X0
          and c.cell_blocked = 0
          
          set @id = @tempid
        end
      end
    end
  end
      
  if @id is null
    set @id = -1
  return @id
END