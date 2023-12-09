CREATE VIEW dbo.firms_for_income 
AS /*
select fc.our_id [id], 
       fc.ourname [list]
from dbo.firmsconfig fc 
join firmsgroup fg on fc.our_id=fg.firmsgroupid
where fc.Actual=1
*/

SELECT
  fc.FirmGroup AS id
 ,fc.OurName AS list
FROM dbo.FirmsConfig fc
INNER JOIN dbo.FirmsGroup fg
  ON fc.Our_id = fg.FirmsGroupID
WHERE fc.Actual = 1
AND fc.Our_id NOT IN(14,25)