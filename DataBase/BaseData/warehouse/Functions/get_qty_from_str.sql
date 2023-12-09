CREATE function warehouse.get_qty_from_str(@qty varchar(10), @minp int, @flgweight bit)
returns decimal(15,3)
as 
begin
declare @res decimal(15,3)
set @res=0
declare @PlusPos decimal(15,3)
if @flgweight=0
begin
  set @PlusPos=charindex('+',@qty)
  if @PlusPos=0 set @res=cast(@qty as float) * @minp
  else set @res=cast(left(@qty,@PlusPos-1) as float) * @minp + cast(right(@qty,len(@qty)-@PlusPos) as float)
end
else set @res=cast(@qty as decimal(15,3))
return @res
end