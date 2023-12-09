CREATE PROCEDURE dbo.ProcessUnits @ucID INT, @hitag INT, @unid INT, @unid2 INT,
                                  @k DECIMAL(15,7), 
                                  @isdel BIT
AS
DECLARE @ErrReg INT, @tranName VARCHAR(12)
SET @tranname= 'ProcessUnits'

BEGIN TRAN @tranname
	SET @ErrReg=0
 
  DECLARE @del BIT
  IF @ucid = 0  --вставить
  BEGIN
  
  if object_id('tempdb..#tempUC') is not null drop table #tempUC
  create table #tempUC(ucID INT, hitag INT ,Unid INT, Unid2 INT, K DECIMAL(15,7))  
  
  INSERT INTO #tempUC(ucID, hitag, Unid, Unid2, K)
    SELECT uc.ucID, uc.Hitag, uc.Unid, uc.Unid2, uc.K
      FROM dbo.UnitConv uc
     WHERE uc.Hitag = @hitag 
       AND uc.Unid = @unid 


      DECLARE @tempucID INT, @tmpUnid2 INT, @tmpK DECIMAL(15,7)
      DECLARE C cursor fast_forward local 
      for select #tempUC.ucID, #tempUC.unid2, #tempUC.K from #tempUC      
      open C 
      fetch next from C 
      into @tempucID, @tmpUnid2, @tmpK          
      while @@FETCH_STATUS = 0
      begin
        INSERT INTO dbo.unitConv(hitag, Unid, Unid2, K)
          SELECT @hitag, @unid2, 
                 @tmpUnid2, @tmpK / @K
          FROM #tempUC 
          WHERE #tempUC.ucID = @tempucID
          
          SET @ErrReg=@ErrReg+@@error;
        
        INSERT INTO dbo.unitConv(hitag, Unid, Unid2, K)
          SELECT @hitag, @tmpUnid2, @unid2,  
                 @K / @tmpK
          FROM #tempUC 
          WHERE #tempUC.ucID = @tempucID
          
          SET @ErrReg=@ErrReg+@@error;
        
        fetch next from C 
        into @tempucID, @tmpUnid2, @tmpK   
      end     
      CLOSE C;
      DEALLOCATE C; 

   
   INSERT INTO dbo.unitConv(hitag, Unid, Unid2, K)
    VALUES(@hitag, @Unid, @unid2, @K)

   SET @ErrReg=@ErrReg+@@error;

   INSERT INTO dbo.unitConv(hitag, Unid, Unid2, K)
    VALUES(@hitag, @Unid2, @unid, 1.0/@K)

   SET @ErrReg=@ErrReg+@@error;

  END



  ELSE IF @isdel = 0 --редактировать
  BEGIN
    UPDATE dbo.unitConv 
       SET dbo.unitConv.k = @K
     WHERE dbo.unitConv.ucID = @ucID
 
     SET @ErrReg=@ErrReg+@@error;
 
    UPDATE dbo.unitConv
       SET dbo.unitConv.k = 1.0/@K
     WHERE dbo.unitConv.hitag = @hitag
       AND dbo.unitConv.Unid = @unid2
       AND dbo.unitConv.Unid2 = @unid

     SET @ErrReg=@ErrReg+@@error;

  END
  ELSE
  BEGIN --удалить/восстановить
    SET @del = (SELECT 1 - dbo.unitConv.isdel                                   
                  FROM dbo.unitConv 
                 WHERE dbo.unitConv.ucID = @ucID) 

    UPDATE dbo.unitConv
       SET dbo.unitConv.isdel = @del
     WHERE dbo.unitConv.ucID = @ucID

    SET @ErrReg=@ErrReg+@@error;
 
    UPDATE dbo.unitConv  
       SET dbo.unitConv.isdel = @del
     WHERE dbo.unitConv.hitag = @hitag
       AND dbo.unitConv.Unid = @unid2 
       AND dbo.unitConv.Unid2 = @unid  

    SET @ErrReg=@ErrReg+@@error;
    
  END


if @ErrReg=0 
begin
	commit tran @tranname
	select '' as [Res]    
end
else
begin
	rollback tran @tranname
  declare @msg varchar(500)
  set @msg= 'Во время выполнения произошла ошибка'
  select @msg as [Res]
PRINT @ErrReg
end