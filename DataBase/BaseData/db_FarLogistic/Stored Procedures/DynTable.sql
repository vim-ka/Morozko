CREATE PROCEDURE db_FarLogistic.DynTable
@str varchar(1000),
@sep varchar(1)
AS
BEGIN
	declare @sql varchar(3000)
	set @sql='select '+replace(@str,@sep,' union all select ')
  exec(@sql)
END