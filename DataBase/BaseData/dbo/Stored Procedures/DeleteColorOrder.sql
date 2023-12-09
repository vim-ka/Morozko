CREATE PROCEDURE dbo.DeleteColorOrder
@mp varchar(500)
AS
BEGIN
  declare @sql varchar(max)
  
  set @sql='delete from mtprior where mp in ('+@mp+')'
  exec(@sql)
END