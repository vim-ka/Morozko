CREATE PROCEDURE warehouse.terminal_CheckBarcodeZakaz_del
@barcode varchar(20),
@mhid int
AS
BEGIN
	declare @res int
  declare @msg varchar(500)
  declare @body varchar(20)
  declare @pref int 
  declare @nd datetime
  declare @nom int
  declare @hitag int
  declare @kol int
  declare @nzID int
  declare @hasWeight bit
  declare @weight int
   
  set @res=0
  set @msg=''
  set @pref=cast(left(@barcode,2) as int)
 
  if @pref=10
  begin
    set @body=substring(@barcode,3,len(@barcode)-3)    
    set @nd=cast(substring(@body,1,2)+'.'+substring(@body,3,2)+'.'+substring(@body,5,2) as datetime)
    set @nom=cast(substring(@body,len(@body)-3,4) as int)
    set @res=isnull([dbo].InDatNom(@nom,@nd),0)
  end
  --else
  		--set @msg='Некорректный штрихкод'
  
  --/*
  if @res=0 and @msg=''
  begin
  	if object_id('tempdb..#barcode') is not null drop table #barcode
    create table #barcode(barcode varchar(20),hitag int, kol int)
  	
    insert into #barcode
    select barcode, hitag, 1 from dbo.nomen where isnull(barcode,'')<>''
    union 
    select barcodeMinP, hitag, minp from dbo.nomen where isnull(barcodeMinP,'')<>''
    
    select @hitag=hitag,
    			 @kol=kol,
           @hasWeight=cast(iif(substring(barcode,len(barcode)-5,5)='00000',1,0) as bit),
           @weight=substring(@barcode,len(@barcode)-5,5)
    from #barcode
    where left(@barcode,7)=left(barcode,7)
    
    if isnull(@hitag,0)>0
    begin
    	select @res=datnom, @nzID=nzID
      from (
    	select top 1 c.datnom, z.nzid
      from dbo.nc c 
      inner join dbo.nvZakaz z on c.datnom=z.datnom
      where c.mhid=@mhid
      			and z.hitag=@hitag
            and z.done=0
            and z.zakaz<>0
      order by z.Done,c.datnom desc) a
      
    end
    else
  		set @msg='Некорректный штрихкод'
        
    if @res>0 set @msg=cast(isnull(@hitag,0) as varchar)+';'+cast(isnull(@kol,0) as varchar)+';'
    									 +cast(isnull(@nzID,0) as varchar)+';'+cast(iif(isnull(@hasWeight,0)=1,isnull(@weight,0),0) as varchar)
    else set @msg='Некорректный штрихкод'
    if object_id('tempdb..#barcode') is not null drop table #barcode
  end
  --*/
  
  
  select @res [res], @msg [msg]
END