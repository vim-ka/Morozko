CREATE PROCEDURE SavePsScoresHist
AS
BEGIN

  INSERT INTO 
  dbo.PsScoresHist
 (
  ND,
  P_ID,
  StID,
  Must,
  OverMust
  ) 
 select 
   dbo.today(),
   P_ID,
   StID,
   Must,
   OverMust
 from psscores 
 where StID = 1 and must<>0

  
END