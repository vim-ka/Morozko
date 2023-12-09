create procedure ReadArcVi @ND datetime
as
declare @N0 int
declare @N1 int
begin
  set @N0=dbo.InDatNom(1,@ND)
  set @N1=dbo.InDatNom(9999,@ND)
  
  select a.id, a.startid, a.ncom, a.ncod, a.hitag, a.price, a.cost, a.sklad, a.Mornrest as Morn,
   (select isnull(SUM(kol),0) from NV where datnom between @N0 and @N1 and tekid=a.id) as Sell,
   V.DatePost as SaveDate, 
   V.Start, V.StartThis, V.MinP, V.mpu, v.sert_id, V.Rang,
   (select isnull(sum(newkol-kol),0) from izmen I where I.ND=@ND and i.id=a.id and i.act='Испр') as Isprav,
   (select isnull(sum(kol-newkol),0) from izmen I where I.ND=@ND and i.id=a.id and i.act='Снят') as Remov,
   V.DateR, V.Srokh, V.Country, V.units, V.Locked, V.ncountry, V.Gtd, V.our_id, V.Weight, V.MeasId
  from morozArc..arcvi A inner join Visual V on V.ID=A.ID
  where 
    a.workdate=@ND
end