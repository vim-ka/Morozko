CREATE PROCEDURE warehouse.terminal_CheckBarcodeMarsh
@barcode varchar(20)
AS
BEGIN
	declare @res int
  declare @msg varchar(500)
  declare @body varchar(20)
  declare @pref int 
  declare @nd datetime
  declare @nom int
   
  set @res=0
  set @msg=''
  set @pref=cast(left(@barcode,2) as int)
  
  if @pref in (10,12)
  begin
  	set @body=substring(@barcode,3,len(@barcode)-3)    
    set @nd=cast(substring(@body,1,2)+'.'+substring(@body,3,2)+'.'+substring(@body,5,2) as datetime)
  	set @nom=cast(substring(@body,len(@body)-3,4) as int)
    
    if @pref=10
    begin
			set @msg=[dbo].InDatNom(@nom,@nd)
      set @res=isnull((select iif(c.mhid=0,r.regionid,c.mhid) 
      								 from dbo.nc c 
      								 join dbo.def d on d.pin=c.b_id
                       join dbo.regions r on d.reg_id=r.reg_id
                       where datnom=@msg),0)
      if @res=0 set @msg='Маршрут не найден'
    end
    else
    begin
    	set @res=isnull((select mhid from dbo.marsh where nd=@nd and marsh=@nom),0)
      if @res=0 set @msg='Маршрут не найден'
    end
  end
  else
  	set @msg='Некорректный штрихкод'
  
  select @res [res], @msg [msg]
END