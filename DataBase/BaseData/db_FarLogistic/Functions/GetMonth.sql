CREATE FUNCTION db_FarLogistic.GetMonth (@i int,@s float = 1)
RETURNS @t table (c int)
as
begin
while @s<=4096
begin
if @s=@i-(@i^(cast(@s as int)))
  begin
  	insert into @t values (cast(log(@s,2) as int))
  end
  set @s=@s*2
end

return
end