CREATE PROCEDURE warehouse.add_mobiletermdata @tip int, @mhid int, @datnom int, @hitag int, @kol int, @spk int, @compname varchar(64)
AS
declare @curr_kol int
BEGIN
  -- считаем кол-во в штуках
  set @curr_kol = 0
  -- до сканирования
  select @curr_kol = isnull(kol, 0) from warehouse.sklad_mobiletermdata where tip = @tip and mhid = @mhid and datnom = @datnom and hitag = @hitag
  
  if @curr_kol = 0
  begin
	insert into warehouse.sklad_mobiletermdata(tip, mhid, datnom, hitag, kol, spk, compname)
	values(@tip, @mhid, @datnom, @hitag, @kol, @spk, @compname)  
  end
  else
  begin
  	update warehouse.sklad_mobiletermdata set kol = kol + @kol where tip = @tip and mhid = @mhid and datnom = @datnom and hitag = @hitag
  end
/*  --после сканирования
  select @curr_kol = isnull(kol, 0) from warehouse.sklad_mobiletermdata where tip = @tip and mhid = @mhid and datnom = @datnom and hitag = @hitag
  
  select @need_kol = cast(nv.kol as int) from nv inner join nc on nc.datnom = nv.datnom inner join nomen n on n.hitag = nv.hitag 
  where nv.datnom = @datnom and nv.hitag = @hitag and nc.mhid = @mhid
  
  if */
END