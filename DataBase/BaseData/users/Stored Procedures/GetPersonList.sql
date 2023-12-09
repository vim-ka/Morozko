CREATE PROCEDURE users.GetPersonList
AS
BEGIN
  select p_id, fio
  from dbo.person 
END