CREATE FUNCTION dbo.GetOldPriceCommanHitagDCK (@hitag int, @dck int, @isCost bit=0)
RETURNS money
AS
BEGIN
  declare @res money
  
  if exists(select 1 from Inpdet i inner join comman c on c.ncom=i.ncom where i.hitag=@hitag and c.dck=@dck)
  begin
  	if @isCost=0
    begin
      select  top 1 @res=iif(n.flgWeight=1,iif(i.weight=0,0,i.price/i.weight),i.price)
      from Inpdet i 
      inner join comman c on c.ncom=i.ncom
      inner join nomen n on n.hitag=i.hitag
      where c.dck=@dck
            and i.hitag=@hitag
      order by i.inId desc	
    end
    else
    begin
    	select  top 1 @res=iif(n.flgWeight=1,iif(i.weight=0,0,i.cost/i.weight),i.cost)
      from Inpdet i 
      inner join comman c on c.ncom=i.ncom
      inner join nomen n on n.hitag=i.hitag
      where c.dck=@dck
            and i.hitag=@hitag
      order by i.inId desc	
    end
  end
  else
  	set @res=0
    
  return @res
END