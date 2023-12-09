CREATE PROCEDURE dbo.pFDistTr @plannd datetime, @dist numeric(10, 2), @p_id int
AS 
BEGIN
-- эта фигня пока еще юзается в программе ГыСыМэ, потом грохнем
  DECLARE @cnt int
  select @cnt = count(*) from dbo.FDistTrTemp where plannd = @plannd and p_id = @p_id
  if @cnt > 0
  	update dbo.FDistTrTemp set dist = @dist where p_id = @p_id and plannd = @plannd
  else
  	insert into dbo.FDistTrTemp(plannd, dist, p_id) values(@plannd, @dist, @p_id)
END