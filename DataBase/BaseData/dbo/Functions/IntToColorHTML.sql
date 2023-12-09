CREATE FUNCTION dbo.IntToColorHTML (@clr int)
RETURNS varchar(7)
AS
BEGIN
  declare @res varchar(7)
  declare @r varchar(2)
  declare @g varchar(2)
  declare @b varchar(2)
  set @res=''
  if @clr<>0
  begin
  	set @res=replace(sys.fn_varbintohexstr(convert(binary(3),@clr)),'0x','')
    set @r=right(@res,2)
    set @b=left(@res,2)
    set @g=left(right(@res,4),2)
    set @res='#'+@r+@g+@b
  end
  else 
  	set @res='#000000';
  return @res
END