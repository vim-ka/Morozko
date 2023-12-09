CREATE FUNCTION [LoadData].GetAddAg_ID (@ag_id int, @dck int) RETURNS int
AS
BEGIN
  declare @add_ag_id int
  set @add_ag_id=isnull(
  (select min(a.ag_id) 
  from AgAddBases a
  where (a.add_ag_id=@ag_id or add_dck=@dck) and a.ag_id in (161,252,223,309,303,183,251))
  ,@ag_id);
  
  Return @add_ag_id
END