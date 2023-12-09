CREATE PROCEDURE dbo.CorrectNegID
AS
declare @NewID INT, @var1 int
BEGIN
      
  begin TRANSACTION
    DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
    	SELECT id 
    	FROM dbo.tdvi where id<0 order by id;
    
    OPEN cur
    
    FETCH NEXT FROM cur INTO @var1
    
    WHILE @@FETCH_STATUS = 0 BEGIN
            
      set @NewID=(select max(id) from tdvi)+1;
      update tdvi set ID=@NewID where ID=@var1;
      update izmen set NewID=@NewID where NewID=@var1;
      update nv set TekID=@NewID where TekID=@var1;
      update nvzakaz set ID=@NewID where ID=@var1;
            
    	FETCH NEXT FROM cur INTO @var1
    
    END
    
    CLOSE cur
    DEALLOCATE cur

    commit transaction;
end;