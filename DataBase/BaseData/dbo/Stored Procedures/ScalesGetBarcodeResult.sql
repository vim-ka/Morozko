CREATE PROCEDURE dbo.ScalesGetBarcodeResult
@barcode varchar(50),
@isSklad bit,
@id int output,
@msg varchar(200) output 
AS
BEGIN
	declare @code varchar(47)
  set @code=substring(@barcode,3,len(@barcode)-3)
  set @id=convert(int,@code)
  print @id
  
  if isnull(@id,0)=0
  begin
  	set @msg='Неопознанный штрихкод'
		set @id=-1
  end
  else
  begin
    if patindex('34%',@barcode)<>0
    begin
      --складская группа
      if exists(select 1 from dbo.SkladGroups where skg=@id) and @isSklad=1
      	set @msg=(select SkladList from dbo.SkladGroups where skg=@id)
      else
      begin
      	set @id=-1
        set @msg=iif(@isSklad=1,'Неизвестная складская группа','Требуется штрихкод сотрудника')
      end   
    end
    
    if patindex('83%',@barcode)<>0 or patindex('84%',@barcode)<>0
    begin
      --складской сотрудник
      if exists(select 1 from dbo.SkladPersonal where spk=@id) and @isSklad=0
      	set @msg=(select FIO from dbo.SkladPersonal where spk=@id)
      else
      begin
      	set @id=-1
        set @msg=iif(@isSklad=0,'Неизвестный сотрудник','Требуется штрихкод складской группы')
      end
    end
  end
END