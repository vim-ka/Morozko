CREATE PROCEDURE warehouse.terminal_CheckBarcodeSklad
@barcode varchar(20)
AS
BEGIN
	declare @res int
  declare @msg varchar(500)
  declare @pref int 
  
  set @res=0
  set @msg=''
  set @pref=cast(left(@barcode,2) as int)
  
  if @pref in (33,34)
  begin
  	if @pref=33
    	set @msg=isnull(cast(cast(substring(@barcode,3,len(@barcode)-1) as int) as varchar(50)),'')
    else 
    	set @msg=
      isnull(stuff((
      select N','+cast(skladno as varchar(50))
      from [dbo].SkladList 
      where skg=cast(substring(@barcode,3,len(@barcode)-3) as int)
     	for xml path(''), type).value('.','varchar(max)'),1,1,''),'')
    set @res=iif(@msg='',0,1)
  end
  else
  	set @msg='Некорректный штрихкод'
  
  select @res [res], @msg [msg]
END