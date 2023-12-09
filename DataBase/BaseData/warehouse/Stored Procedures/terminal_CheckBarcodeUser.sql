CREATE PROCEDURE warehouse.terminal_CheckBarcodeUser
@barcode varchar(20)
AS
BEGIN
	declare @res int
  declare @msg varchar(500)
  declare @pref int 
  declare @spk int
  
  set @res=0
  set @msg=''
  set @pref=cast(left(@barcode,2) as int)
  set @spk=cast(substring(@barcode,3,len(@barcode)-3) as int)
  
  if @pref in (83,84) and @spk>0
  begin
  	select 	@res=isnull(spk,0),
    				@msg=isnull(FIO,'Некорректный штрихкод')
    from [dbo].SkladPersonal sp
    where spk=cast(substring(@barcode,3,len(@barcode)-3) as int)
    			and closed=0
  end
  else
  	set @msg='Некорректный штрихкод'
  
  select @res [res], @msg [msg]
END