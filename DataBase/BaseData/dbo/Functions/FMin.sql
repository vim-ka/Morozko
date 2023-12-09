create function FMin(@a float, @b float ) returns float -- float без указания точности это float(53) = double precision.
as
begin
  declare @R float;
  if @a<@b set @R=@a; else set @R=@b;
  return @R;
end;