CREATE PROCEDURE dbo._temp1
AS
DECLARE @OldPin INT, @NotUsedNom int
begin
  IF OBJECT_ID('tempdb..#t') IS NOT NULL DROP TABLE #t;
  CREATE TABLE #t(NewPin INT NOT NULL PRIMARY key, OldPin INT, Remark varchar(30));
  insert INTO #t(NewPin,OldPin,Remark) SELECT New_Pin, Pin, 'old data' FROM Morozdata..def WHERE New_Pin>0;


  DECLARE c0 CURSOR FAST_FORWARD for 
    SELECT DISTINCT d.pin 
      FROM morozdata..defcontract c 
      inner join morozdata..def d on iif(c.contrtip=1,d.ncod,d.pin)=c.pin
      WHERE c.Our_id>=22 AND d.pin NOT IN (SELECT oldpin FROM #t)
    UNION
    SELECT DISTINCT pin FROM morozdata..Comman WHERE Our_id>=22 AND pin NOT IN (SELECT oldpin FROM #t)
      ORDER BY pin;
  OPEN c0;
  FETCH NEXT FROM c0 INTO @OldPin;
  WHILE @@fetch_status=0 BEGIN
    SET @NotUsedNom=(SELECT TOP 1 newpin+1 FROM #t WHERE newpin+1 NOT IN (SELECT newpin FROM #t)); 
    INSERT INTO #t(NewPin,OldPin,remark) VALUES (@NotUsedNom, @OldPin, 'new data')
    FETCH NEXT FROM c0 INTO @OldPin;
  END;
  CLOSE c0;
  DEALLOCATE c0;
  SELECT * FROM #t;
END;