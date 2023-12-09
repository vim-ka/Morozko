create function fnMax3date (@d1 datetime, @d2 datetime, @d3 datetime) returns datetime
as
begin
  declare @dd datetime;

  set @dd=isnull(@d1, '19000101');

  if @dd<isnull(@d2, '19000101') set @dd=@d2;
  if @dd<isnull(@d3, '19000101') set @dd=@d3;
  if @dd<='19000101' set @dd=null;

  return @dd;
end;