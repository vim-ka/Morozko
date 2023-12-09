CREATE function NearLogistic.get_range(@min int, @max int) 
returns @res table (num int)
begin
while (@min <= @max)  
begin
   insert into @res values(@min)
   set @min = @min + 1
end
return
end