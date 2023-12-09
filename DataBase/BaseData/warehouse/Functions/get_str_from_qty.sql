CREATE function warehouse.get_str_from_qty (@flgweight bit, @qty decimal(15,4), @minp int)
returns nvarchar(50)
as
begin
	declare @res nvarchar(50) =N'', @box int =0, @units int =0
  if @flgweight=1 set @res=warehouse.weight_gram_to_str(round(@qty*1000,0))+' кг'
  else
  begin
  	set @box=floor(@qty/@minp); set @units=round(@qty-@box*@minp,0);
    set @res=iif(@box>0,cast(@box as nvarchar),'')+iif(@units>0,'+'+cast(@units as nvarchar),'');
  end
  return @res;
end