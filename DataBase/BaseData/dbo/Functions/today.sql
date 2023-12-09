﻿CREATE FUNCTION today () RETURNS datetime
AS
BEGIN
  return DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0);
END