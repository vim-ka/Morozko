CREATE FUNCTION dbo.gettabspace (@i int)
RETURNS varchar(50)
AS
BEGIN
  declare @res varchar(50)
	declare @j int
	set @j=1
	set @res=''
	while @j<=@i 
	begin
		set @res=@res+'  '
		set @j=@j+1
	end
	return @res
END