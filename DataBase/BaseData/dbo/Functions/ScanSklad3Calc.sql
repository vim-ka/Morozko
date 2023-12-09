CREATE FUNCTION dbo.ScanSklad3Calc(@marshnd datetime, @marsh int, @skg int
)
RETURNS int
AS
BEGIN
  declare
  @dtn1 int,
  @dtn2 int,
  @res int
  set @dtn1 = dbo.InDatNom(0, @marshnd)
  set @dtn2 = dbo.InDatNom(9999, @marshnd)
  select @res = 
  ROUND(sum(nv.kol * n.Brutto), 0)
  from nv
  inner join nomen n on n.hitag = nv.hitag 
  where datnom in
  (
  select datnom from nc 
  where datnom >= @dtn1 and datnom <= @dtn2
  and marsh = @marsh)
  and sklad in (select skladno from skladlist where skg = @skg)
  return @res
END