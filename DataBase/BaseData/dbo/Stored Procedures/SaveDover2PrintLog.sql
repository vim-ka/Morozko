CREATE procedure dbo.SaveDover2PrintLog @datnom int, @Op int, @dover_type int=0
AS
declare @MaxID smallint, @PrintCount SMALLINT, @DrID INT, @MhID int;
begin
  set @maxid=(select max(PrintCount) from Dover2printlog where datnom=@datnom);
  set @PrintCount=1+isnull(@maxid,0);
  SET @MhID=ISNULL((SELECT MhID FROM nc WHERE datnom=@datnom),0);
  SET @DrId=(SELECT DrId FROM Marsh where @MhID>0 AND mhid=@MHID);

  insert into Dover2PrintLog(datnom, Op, PrintCount, dover_type, MhID, 
    drID, DovStat, DovNom)
  values(@datnom, @Op, @PrintCount, @dover_type, @MhID, 
    ISNULL(@DrId,0), 1,  CAST(@datnom AS varchar)+'/'+cast(@PrintCount AS varchar));

  select scope_identity() as DplID, @PrintCount as PrintCount;

end;