CREATE PROCEDURE dbo.testproc3
@a int,
@b int out
AS
BEGIN
  if @a > 10 
    set @b = 1
  else
  	set @b = 0;
END