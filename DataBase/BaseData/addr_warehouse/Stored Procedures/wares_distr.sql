CREATE PROCEDURE addr_warehouse.wares_distr 
@ncom int
AS
BEGIN
--  TRUNCATE TABLE addr_warehouse.tabletemp --для отладки
--  TRUNCATE TABLE addr_warehouse.aw_distr --для отладки  
  
  declare @sklad int
  declare @needvol numeric(10, 5)
  declare @tekid int
  declare @hitag int
  declare @kol int
  declare @vol numeric(10, 5)
  declare @cell_id int
  declare @w_cell_idx_freevol numeric(10, 5)
  declare @id int
  declare @kol_ int
  declare @kol_distr int  
  declare @volminp numeric(10, 5)
  declare @minp int
  declare @sumvol numeric(10, 5)
  declare @ost int
  declare @cnt int
  declare @skl_exist int
  declare @w_cell int
  declare @tempid int  
  
  DECLARE cur_ncom CURSOR FAST_FORWARD FOR 
  select i.id, i.hitag, i.kol, i.sklad, 
  n.volminp * i.kol needvol,
  n.volminp, i.minp
  from dbo.inpdet i
  inner join dbo.nomen n on n.hitag = i.hitag
  where i.ncom = @ncom
--  and i.hitag  <> 10662
  and not EXISTS(select * from addr_warehouse.aw_distr d where d.ncom = i.ncom and d.hitag = i.hitag)
  order by i.hitag

  /*select @cnt = count(*) from addr_warehouse.aw_distr where ncom = @ncom
  if @cnt > 0
  begin
    DEALLOCATE cur_ncom
    return
  end*/

  set @sumvol = 0
  begin try
  OPEN cur_ncom
--  print 'open cur_ncom'
  FETCH NEXT FROM cur_ncom into @tekid, @hitag, @kol, @sklad, @needvol, @volminp, @minp
  WHILE @@FETCH_STATUS = 0
  BEGIN
    select @skl_exist = count(*) from addr_warehouse.aw_cells c
	where c.skg = (select skg from dbo.skladlist where skladno = @sklad)
	if @skl_exist = 0
    begin
	  print 'код прихода:' + convert(varchar, @ncom) + 
      ' код склада: ' + convert(varchar, @sklad) + ': не создана структура склада!'
      CLOSE cur_ncom
	  DEALLOCATE cur_ncom
      return      
    end
    
    if @volminp = 0 --если параметр 'объем минимальной партии' не установлен, валим все в ярус Х0
    begin
   	  print 'код прихода:' + convert(varchar, @ncom) + 
      ' код товара: ' + convert(varchar, @hitag) + ' объем минимальной партии равен 0!'

      --поиск ячейки в зонах временного хранения Х0
      select @w_cell = min(w.w_cell), @tempid = min(w.id)
      from addr_warehouse.aw_wares w
      left join addr_warehouse.aw_cells c on c.id = w.w_cell
      where c.skg = (select skg from dbo.skladlist where skladno = @sklad)
      and w.w_cell_idx_freevol >= @volminp
      and c.cell_fl = 1 --X0
      and c.cell_blocked = 0
      
      set @id = @tempid
      
      update addr_warehouse.aw_wares set w_hitag = @hitag, w_kol = w_kol + @kol, w_vol = w_vol + @needvol,
      w_cell_idx_freevol = w_cell_idx_freevol - @needvol
      where id = @id
      
	  select @cell_id = w_cell from addr_warehouse.aw_wares where id = @id 
      
	  insert into addr_warehouse.aw_distr(ncom, hitag, kol, sklad, cell_id, txt)
      VALUES(@ncom, @hitag, @kol, @sklad, @id, 'full')
      
      print 'код прихода: ' + convert(varchar, @ncom) + 
      ' код товара: ' + convert(varchar, @hitag) +
      ' св. объем ячейки: ' + convert(varchar, @w_cell_idx_freevol) + 
      ' требуемый объем: ' + convert(varchar, @needvol) + 
      ' адрес: ' + addr_warehouse.CellAddress(@cell_id)
      
      FETCH NEXT FROM cur_ncom into @tekid, @hitag, @kol, @sklad, @needvol, @volminp, @minp	  
      continue
    end
    
    set @id = addr_warehouse.FindCell(@hitag, @sklad)
    if @id = -1
    begin
      print 'код прихода:' + convert(varchar, @ncom) + 
      ' не удалось найти ячейку для товара: ' + convert(varchar, @hitag)
      
      --insert into addr_warehouse.aw_distr(ncom, hitag, kol, sklad, cell_id, txt)
      --VALUES(@ncom, @hitag, @kol, @sklad, @id, 'не удалось найти ячейку для товара');
      
      FETCH NEXT FROM cur_ncom into @tekid, @hitag, @kol, @sklad, @needvol, @volminp, @minp	  
      continue
    end

    select @w_cell_idx_freevol = w_cell_idx_freevol from addr_warehouse.aw_wares
    where id = @id 
    
    if @w_cell_idx_freevol >= @needvol --если можно разместить полностью
    begin
      update addr_warehouse.aw_wares set w_hitag = @hitag, w_kol = w_kol + @kol, w_vol = w_vol + @needvol,
      w_cell_idx_freevol = w_cell_idx_freevol - @needvol
      where id = @id
      
	  select @cell_id = w_cell from addr_warehouse.aw_wares where id = @id 
      
	  insert into addr_warehouse.aw_distr(ncom, hitag, kol, sklad, cell_id, txt)
      VALUES(@ncom, @hitag, @kol, @sklad, @id, 'full')
      
      print 'код прихода: ' + convert(varchar, @ncom) + 
      ' код товара: ' + convert(varchar, @hitag) +
      ' св. объем ячейки: ' + convert(varchar, @w_cell_idx_freevol) + 
      ' требуемый объем: ' + convert(varchar, @needvol) + 
      ' адрес: ' + addr_warehouse.CellAddress(@cell_id)
    end

    if @w_cell_idx_freevol < @needvol --если нельзя разместить полностью
    begin
	  print convert(varchar, @hitag) + ': ' + convert(varchar, @sklad) + ': ' + 
      convert(varchar, @w_cell_idx_freevol) + '<' + convert(varchar, @needvol) + 
      ' ячейка: ' + convert(varchar, @id) + 
      ' volminp: ' + convert(varchar, @volminp)
      
      set @kol_distr = 0
      set @ost = @kol
      while @ost > 0 --пока не разместим все необходимое количество
      begin
        --считаем сколько можно разместить
        if @w_cell_idx_freevol >= @volminp
          set @kol_ = floor(@w_cell_idx_freevol / @volminp)
        else
        begin
          set @id = addr_warehouse.FindCell(@hitag, @sklad)
  		  select @cell_id = w_cell from addr_warehouse.aw_wares where id = @id
          select @w_cell_idx_freevol = w_cell_idx_freevol from addr_warehouse.aw_wares
          where id = @id
          
          print convert(varchar, @hitag) + ': ' + convert(varchar, @sklad) + ': ' + 
          convert(varchar, @w_cell_idx_freevol) + ' новая ячейка: ' + convert(varchar, @id) + 
          ' volminp: ' + convert(varchar, @volminp)
          
          continue --по идее не должен вообще сюда попадать :-)
        end
        
        if @kol_ > 0
        begin
          if @kol_ > @ost
            set @kol_ = @ost
              
          update addr_warehouse.aw_wares set w_hitag = @hitag, w_kol = w_kol + @kol_, 
          w_vol = w_vol + (@volminp * @kol_), 
          w_cell_idx_freevol = w_cell_idx_freevol - (@volminp * @kol_)
          where id = @id
              
          set @kol_distr = @kol_distr + @kol_
          set @ost = @kol - @kol_distr
          
          print 'kol_: ' + convert(varchar, @kol_) + ' kol_distr: ' + convert(varchar, @kol_distr) +
          ' ost: ' + convert(varchar, @ost)
          
          insert into addr_warehouse.aw_distr(ncom, hitag, kol, sklad, cell_id, txt)
          values(@ncom, @hitag, @kol_, @sklad, @id, 'part')
  		  
          set @id = addr_warehouse.FindCell(@hitag, @sklad)

          select @w_cell_idx_freevol = w_cell_idx_freevol from addr_warehouse.aw_wares
          where id = @id
        end
      end 
    end
    FETCH NEXT FROM cur_ncom into @tekid, @hitag, @kol, @sklad, @needvol, @volminp, @minp
  END;
  
  CLOSE cur_ncom
  DEALLOCATE cur_ncom
  end try
  begin catch
--    print 'catch close cur_ncom'
    CLOSE cur_ncom
    DEALLOCATE cur_ncom
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
  end catch
END