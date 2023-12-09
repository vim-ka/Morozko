CREATE function fnMin3date (@d1 datetime, @d2 datetime, @d3 datetime) returns datetime
as
begin
  declare @dd datetime;

  set @dd=isnull(@d1, '22001231');

  if @dd>isnull(@d2, '22001231') set @dd=@d2;
  if @dd>isnull(@d3, '22001231') set @dd=@d3;
  if @dd>='22001231' set @dd=null;

  return @dd;
end;