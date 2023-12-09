CREATE PROCEDURE dbo.GetFirms
AS
  SELECT f.Our_id, f.OurName 
    FROM firms f
  ORDER BY f.OurName ASC