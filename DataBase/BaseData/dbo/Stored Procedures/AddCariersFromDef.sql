CREATE PROCEDURE dbo.AddCariersFromDef
@pin int,
@crID int out
AS
BEGIN
	insert into Carriers(pin,
  										 crName,
                       UrArrd,
                       FactAddr,
                       crInn,
                       crKpp,
                       Bank_id,
                       Phone,
                       crOGRN,
                       crORGNDate,
  										 crRs)
  select pin,
  			 brName,
         brAddr,
         gpAddr,
         brInn,
         brKpp,
         Bank_ID,
         brPhone,
         OGRN,
         OGRNDate,
         brRs
  from def 
  where pin=@pin 
  
  set @crID=(select scope_identity())
END