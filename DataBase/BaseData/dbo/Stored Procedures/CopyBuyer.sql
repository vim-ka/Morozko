CREATE PROCEDURE dbo.CopyBuyer
as
BEGIN
  
  DECLARE @CopyPin int;
  DECLARE @id int;

  DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR SELECT * FROM CopyDef

  OPEN @CURSOR
  
  FETCH NEXT FROM @CURSOR INTO @id, @CopyPin
  select * into #Temp from Def where pin=@CopyPin and tip=1
  update #Temp set VMaster=@CopyPin
  update #Temp set pin=(SELECT max(pin)+1 FROM Def where tip=1)
  insert into Def select * from #Temp
  
  FETCH NEXT FROM @CURSOR INTO @id, @CopyPin
  WHILE @@FETCH_STATUS = 0
  BEGIN

    truncate table #Temp
    insert into #Temp select * from Def where pin=@CopyPin and tip=1
    update #Temp set VMaster=@CopyPin
    update #Temp set pin=(SELECT max(pin)+1 FROM Def where tip=1)
    insert into Def select * from #Temp
  
    FETCH NEXT FROM @CURSOR INTO @id, @CopyPin
  END
  
  CLOSE @CURSOR
  
END