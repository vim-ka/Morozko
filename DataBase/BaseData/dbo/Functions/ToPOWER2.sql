CREATE FUNCTION dbo.ToPOWER2 ( @Num int
)
RETURNS @Res table (Pwr int)
AS
BEGIN
  declare @i int

  set @i=0

  while @Num >= power(2,@i) 
  begin
    if power(2,@i) & @Num <>0 insert into @Res values (@i+1)
  
    set @i=@i+1
  end
	
  return
END