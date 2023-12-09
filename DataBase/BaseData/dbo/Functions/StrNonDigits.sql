CREATE FUNCTION dbo.StrNonDigits(@InputString nvarchar(4000))
RETURNS nvarchar(4000)
AS
begin

  declare @OutputString nvarchar(4000), @i int, @ch nchar

  set @i = 1
  set @OutputString = ''

  while @i <= len(@InputString)
  begin
    set @ch = SUBSTRING(@InputString, @i, 1)  
    if ascii(@ch) < 48 OR ASCII(@ch) > 57
    set @OutputString = @OutputString + @ch
    
    set @i = @i + 1
  end 
  return @OutputString
end