CREATE PROCEDURE warehouse.terminal_checkbarcodezakaz
@barcode varchar(20),
@nzid int
AS
BEGIN
	declare @res int
  declare @msg varchar(500)
  declare @barcode_orig varchar(20)
  declare @barcode_orig_minp varchar(20)
  declare @erreg int
 	declare @body varchar(20)
  declare @nd datetime
  declare @nom int
  set @res=0
  set @erreg=0
  set @msg=''
 
  select @barcode_orig=left(isnull(n.barcode,''),20),
  			 @barcode_orig_minp=left(isnull(n.barcodeMinP,''),20)
  from dbo.nvzakaz z
  join dbo.nomen n on z.hitag=n.hitag  
  where z.nzid=@nzid
  
  if len(isnull(@barcode_orig,''))>5 or left(@barcode,2)='10' or len(isnull(@barcode_orig_minp,''))>5
  begin
  	if left(@barcode,2)='10'
    begin
    	--поиск накладной
       set @body=substring(@barcode,3,len(@barcode)-3)    
    	 set @nd=cast(substring(@body,1,2)+'.'+substring(@body,3,2)+'.'+substring(@body,5,2) as datetime)
    	 set @nom=cast(substring(@body,len(@body)-3,4) as int)
    	 
       set @res=isnull([dbo].InDatNom(@nom,@nd),0)
    end
    else
    begin
    	--сравнение шк товара
      if left(@barcode,7)=left(@barcode_orig,7) or left(@barcode,7)=left(@barcode_orig_minp,7)
      begin
      	if substring(@barcode_orig,len(@barcode_orig)-5,5)='00000'
        set @res=cast(substring(@barcode,len(@barcode_orig)-5,5) as int)
      end
      else set @erreg=@erreg+2
    end
  end
  else set @erreg=@erreg+1
  
    
  if (@erReg & 1)<>0 set @msg=@msg+'Некорректный штрихкод БД'
  if (@erReg & 2)<>0 set @msg=@msg+'Штрихкоды не совпадают'
  
  select @res [res], @msg [msg]
END