CREATE function warehouse.weight_gram_to_str (@value int)
returns varchar(10)
as
begin
declare @res varchar(10)
declare @hi int, @low int, @pref varchar(2)

set @hi=round(@value / 1000,0)
set @low=@value-@hi*1000
set @pref=case when @low<100 then '0'
							 when @low<10 then '00'
               else '' end

select @res=cast(@hi as varchar)+iif(@low>0,'.'+@pref+cast(@low as varchar),'')
return @res
end