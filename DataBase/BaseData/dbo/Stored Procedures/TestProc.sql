CREATE PROCEDURE dbo.TestProc @max_i int
AS
BEGIN
  declare @i int
  set @i=1;
  while @i<=@max_i
  begin
    BEGIN TRANSACTION  
    EXEC [dbo].[ReCalcKassaHROFirms];
    Commit;
    set @i=@i+1;
  end
END