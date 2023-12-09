

CREATE function NearLogistic.RoundToDecDown(@Dots int) 
returns int 
as 
begin
  declare @res int, @v int 
  if @Dots%10<>0 set @v=10 else set @v=0
  set @res=ROUND(@Dots,-1)
  if @res=0 set @res=10
  else if @res<@dots set @res=@res+10
  set @res=@res-@v
  Return @Res 
end