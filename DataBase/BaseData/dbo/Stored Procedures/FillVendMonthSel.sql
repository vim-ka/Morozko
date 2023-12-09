CREATE PROCEDURE dbo.FillVendMonthSel @start datetime,@finish datetime
AS
BEGIN
  declare @ND datetime
  
  select distinct
     case 
       when len(CAST(MONTH(ND) as varchar))=1 THEN 
                 '01.0'+CAST(MONTH(ND) as varchar)+'.'+CAST(YEAR(ND) as varchar) 
       else  
                '01.'+ CAST(MONTH(ND) as varchar)+'.'+CAST(YEAR(ND) as varchar) 
     end as ND
     into #TempTable
  from NC
  where Nd>=@start and ND<@finish
  order by ND
  
  DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR SELECT Cast(ND as Datetime) FROM #TempTable

  OPEN @CURSOR 

  FETCH NEXT FROM @CURSOR INTO  @ND
  exec CalcVendMonth @ND

  WHILE @@FETCH_STATUS = 0
  BEGIN
    FETCH NEXT FROM @CURSOR INTO @ND
    exec CalcVendMonth @ND
  END
  
  CLOSE @CURSOR 
  
  
  select Cast(ND as Datetime) --,DATEADD(day,-day(DATEADD(MONTH,1,@ND))+1,DATEADD(MONTH,1,@ND))
  from #TempTable
END