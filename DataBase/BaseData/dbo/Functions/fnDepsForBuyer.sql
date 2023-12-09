-- Список отделов для заданного покупателя
CREATE FUNCTION dbo.fnDepsForBuyer (@b_id int)
      RETURNS varchar(max)
AS
BEGIN
  DECLARE @ss varchar(max), @DName varchar(100), @DepID int
  
  DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
    select distinct deps.DepID, deps.DName 
    from  
      defcontract dc 
      inner join Agentlist A on A.ag_id=dc.ag_id
      inner join Deps on Deps.DepID=A.DepID
    where dc.pin = @B_ID
    order by deps.DepID
  
  OPEN cur
  set @ss=''
  FETCH NEXT FROM cur INTO @DepId, @DName;
  
  WHILE @@FETCH_STATUS = 0 BEGIN
    if @ss='' set @ss=@DName; else set @ss=@ss+'; '+@Dname;
    FETCH NEXT FROM cur INTO @DepId, @DName;
  END
  
  CLOSE cur;
  DEALLOCATE cur;
  
  return @ss;
end