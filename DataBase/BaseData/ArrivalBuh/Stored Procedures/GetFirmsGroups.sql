CREATE PROCEDURE ArrivalBuh.GetFirmsGroups
AS
BEGIN
  select FirmsGroupID [ID],
  		 FirmsGroupName [List]
  from FirmsGroup
  where FirmsGroupID<>9
END