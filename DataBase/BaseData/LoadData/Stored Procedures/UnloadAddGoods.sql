CREATE PROCEDURE [LoadData].UnloadAddGoods @NDStart datetime, @NDEnd datetime, @Our_ID int
AS
BEGIN
  select c.datnom as addvk,
         dbo.DatNomInDate(c.datnom) as addND,
         dbo.InNNak(c.datnom) as addNom,
         c.fam,
         c.sp as addSP,
         c.refdatnom as vk,
         dbo.DatNomInDate(c.refdatnom) as ND,
         dbo.InNNak(c.refdatnom) as Nom,
         cr.SP
  from nc c join nc cr on c.refdatnom=cr.datnom
  where c.ND>=@NDStart and c.ND<=@NDEnd and c.OurID=@Our_ID
        and isnull(c.refdatnom,0)>0 and c.SP>0
END