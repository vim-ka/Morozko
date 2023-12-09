CREATE function NearLogistic.RoundToDec(@Dots int) 
returns int 
as 
begin
  declare @res int 
  set @res=ROUND(@Dots,-1)
  if @res=0 set @res=10
  else if @res<@dots set @res=@res+10
  Return @Res 
end