CREATE PROCEDURE dbo.NaklPerebros
AS
declare @ND datetime
BEGIN   
  begin TRANSACTION;                            
  create table #TempTable (DatNom int)
  
  set @ND=convert(char(10), getdate(),104);
                                 
  insert into #TempTable (DatNom) 
  select DatNom  
  from NC
  where tomorrow=1 and DatNom<1001120000
  
 
  DECLARE @DatNom int, @newDatNom int
  DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR SELECT DatNom FROM #TempTable

  OPEN @CURSOR 

  FETCH NEXT FROM @CURSOR INTO @DatNom
  WHILE @@FETCH_STATUS = 0
  BEGIN  
    set @newdatnom = 1 + isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));
                     
     
    update NC set datnom=@newDatNom, Tomorrow=0, ND=@ND, Tm=convert(char(8), getdate(),108),
                  Printed=0
    where datnom=@DatNom
    update NV set datnom=@newDatNom where datnom=@DatNom
    
  
    exec MovePlataTomorrow @datnom, @newdatnom          
     
    FETCH NEXT FROM @CURSOR INTO  @DatNom
  END
  
  CLOSE @CURSOR 
  deallocate @CURSOR
  Commit;
END