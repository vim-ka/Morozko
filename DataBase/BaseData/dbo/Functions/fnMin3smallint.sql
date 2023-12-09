CREATE function fnMin3smallint (@n1 smallint, @n2 smallint, @n3 smallint) returns smallint
as
begin
  declare @rez smallint;
  set @rez=isnull(@n1, 32767);
  if @n2 is not null and @n2<@rez set @rez=@n2;
  if @n3 is not null and @n3<@rez set @rez=@n3;
  if @rez=32767 set @rez=null;
  return @rez;
end;