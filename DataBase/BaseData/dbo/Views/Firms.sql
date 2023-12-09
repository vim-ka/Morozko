CREATE VIEW dbo.Firms 
AS  SELECT fc.Our_id, fc.OurName
    FROM FirmsConfig fc
   WHERE fc.OurName <> ''
     AND fc.Actual = 1