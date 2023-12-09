CREATE FUNCTION NearLogistic.WorkShift(@Dist decimal(10,3))
returns decimal(5,3)
as 
begin
  declare @Res decimal(5,3)
  
  if @Dist<=500 set @Res=1;
  else if @Dist<=650 set @Res=1.5;
  else if @Dist<=800 set @Res=2;
  else if @Dist<=1200 set @Res=3;
  else if @Dist<=1600 set @Res=4;
  else if @Dist<=2000 set @Res=5;
  else set @Res=6;
  
  Return @Res ;
end