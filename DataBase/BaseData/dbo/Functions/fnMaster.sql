create function fnMaster(@Pin int) returns int
as
begin
  declare @m int  
  set @m=(select master from def where pin=@pin);
  if isnull(@m,0)=0 set @m=@pin;
  return @m;
end;