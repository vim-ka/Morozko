CREATE PROCEDURE NearLogistic.GetTableFromStrings 
@src VARCHAR(max),
@ColNames VARCHAR(500),
@ValueSeparator VARCHAR(1)=';',
@RowSeparator VARCHAR(1)='#',
@TableName VARCHAR(50)
AS 
BEGIN
  IF OBJECT_ID('tempdb..#TempSameTable') IS NOT NULL DROP TABLE #TempSameTable
  IF OBJECT_ID('tempdb..#TempSameTableColName') IS NOT NULL DROP TABLE #TempSameTableColName

  CREATE TABLE #TempSameTable (RowID INT IDENTITY(1,1))

  SELECT str [Columns] INTO #TempSameTableColName FROM dbo.string_to_int(@ColNames,@ValueSeparator,3) sti
  
  DECLARE @sql varchar(500)
  DECLARE @colName VARCHAR(50)
  
  DECLARE curColumns CURSOR FOR 
  SELECT Columns FROM #TempSameTableColName

  OPEN curColumns
  FETCH NEXT FROM curColumns INTO @colName

  WHILE @@fetch_status=0
  BEGIN
   SET @sql='alter table #TempSameTable add '+@colName+' sql_variant'
    
    EXEC(@sql)
    FETCH NEXT FROM curColumns INTO @colName
  END
  
  CLOSE curColumns
  DEALLOCATE curColumns

  SET @sql=''
  
  DECLARE @srcValues VARCHAR(500) 
  DECLARE @Columns VARCHAR(500)
  SET @Columns=REPLACE(@colNames,@ValueSeparator,',')

  DECLARE @col VARCHAR(500)
  DECLARE curValues CURSOR FOR 
  SELECT str FROM dbo.string_to_int(@src,@RowSeparator,3)

  OPEN curValues
  FETCH NEXT FROM curValues INTO @srcValues
  
  WHILE @@fetch_status=0
  BEGIN
    SELECT @col= 
    (SELECT iif(listpos=1,'[col'+CAST(listpos AS VARCHAR)+']',',[col'+CAST(listpos AS VARCHAR)+']')
    FROM dbo.string_to_int(@ColNames,@ValueSeparator,3)
    FOR XML PATH(''), type).value('.','varchar(max)')
   
    SET @sql='insert into #TempSameTable('+@Columns+') '
    SET @sql=@sql+'select * from (SELECT str [val], ''col''+cast(listpos as varchar) [col] FROM dbo.string_to_int('''+@srcValues+''','''+@ValueSeparator+''',3)) as src '
    SET @sql=@sql+'pivot(max(val) for col in ('+@col+')) as pvt'
    --PRINT @sql
    EXEC(@sql)
    FETCH NEXT FROM curValues INTO @srcValues
  END

  CLOSE curValues
  DEALLOCATE curValues

  SET @sql=''
  SET @sql='select '+@Columns+' into '+@TableName+' from #TempSameTable'
  --SET @sql='select '+@Columns+' from #TempSameTable'
  EXEC(@sql)

  DROP TABLE #TempSameTable
  DROP TABLE #TempSameTableColName
END