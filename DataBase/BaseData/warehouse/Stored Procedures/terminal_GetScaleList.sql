CREATE PROCEDURE warehouse.terminal_GetScaleList
AS
BEGIN
  select [id],
  			 [ip],
  			 [name],
         [descr]+'['+[ip]+']' [descr],
  			 row_number() over(order by name) [RowID] 
  from maindata.warehouse.ScaleList
END