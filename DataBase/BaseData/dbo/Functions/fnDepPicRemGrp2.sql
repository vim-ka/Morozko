CREATE FUNCTION dbo.fnDepPicRemGrp2 (@DepID int, @rm1 varchar(10), @rm2 varchar(10)) returns smallint
AS
BEGIN
  declare @grp smallint; 
  declare @rm varchar(10);

  if @rm1<>'' and @rm2<>'' begin
    if len(@rm1)<=len(@rm2) set @rm=@rm1;
    else set @rm=@rm2;
  end;
  else begin
    if @rm1='' set @rm=@rm2; else set @rm=@rm1;
  end;

  set @Grp=isnull((select min(Grp) from guard.FMonitorTypes ft where @rm like ft.pattern),16)
  return @grp;
end;