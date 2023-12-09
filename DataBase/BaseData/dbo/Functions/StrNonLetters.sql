CREATE FUNCTION dbo.StrNonLetters(@InputString nvarchar(4000))
RETURNS nvarchar(4000)
AS
begin

  declare @OutputString nvarchar(4000), @i int, @ch nchar

  set @i = 1
  set @OutputString = N''

  while @i <= len(@InputString)
  begin
    set @ch = SUBSTRING(@InputString, @i, 1)  
    if ascii(@ch) > 47 AND ASCII(@ch) < 58
    set @OutputString = @OutputString + @ch
    
    set @i = @i + 1
  end 
  return @OutputString
end