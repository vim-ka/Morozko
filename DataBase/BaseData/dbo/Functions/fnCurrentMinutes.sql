CREATE FUNCTION fnCurrentMinutes() RETURNS smallint
-- Текущее время суток, выраженное в целых минутах, прошедших с полуночи.
-- Это число от 0 до 1439 (в сутках 1440 минут)
AS
BEGIN
  declare @fdt float;
  set @fdt=cast(GETDATE() as float)-0.000347208
  return round((@fdt-FLOOR(@fdt)+0.000001)*24*60,0)
END