CREATE FUNCTION Guard.StoI (@ss varchar(100)) returns int
AS
BEGIN
  declare @rez int, @ch char(1), @idx int
  set @idx=1;
  WHILE @idx<=len(@ss) and substring(@ss,@idx,1) in ('0','1','2','3','4','5','6','7','8','9')
  BEGIN
    set @idx=@idx+1
  END;
  if @idx>1 set @rez=cast(substring(@ss,1,@idx-1) as int) else set @rez=0;
  return @rez;
END