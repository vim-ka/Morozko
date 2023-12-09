CREATE function fnMax3smallint (@n1 smallint, @n2 smallint, @n3 smallint) returns smallint
as
begin
  declare @rez int;
  set @rez=isnull(@n1, -32768);
  if @n2 is not null and @n2>@rez set @rez=@n2;
  if @n3 is not null and @n3>@rez set @rez=@n3;
  if @rez=-32768 set @rez=null;
  return @rez;
end;