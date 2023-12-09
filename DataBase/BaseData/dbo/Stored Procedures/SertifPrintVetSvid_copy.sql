CREATE PROCEDURE dbo.SertifPrintVetSvid_copy @DatNomStr varchar(300), @uin INT, @total BIT, @dt DATETIME, @Our_ID_Owner INT=0, @Our_IDSaller int=0
AS 
BEGIN 
set @dt = cast(convert(varchar, @dt, 104) as datetime)
declare @dtoday datetime
set @dtoday=dbo.today()


if object_id('tempdb..#DatnomList') is not null drop table #DatnomList
create table #DatnomList (datnom int)

/***********************************сегодня*********************************************/
if @dt = @dtoday
begin
  if isnull(@Our_IDSaller,0)=0 
    insert into #DatnomList (datnom) 
    select K as Datnom from dbo.Str2intarray(@DatNomStr)

  else
  insert into #DatnomList (datnom) 
      SELECT DISTINCT NC.Datnom 
      from NC 
      join nv on nc.datnom=nv.datnom
      join tdvi on nv.tekid=tdvi.id
      join defcontract dc on dc.dck = tdvi.dck
      where NC.ND=@dt 
        and dc.our_id=@Our_ID_Owner 
        AND NC.ourID=@Our_IDSaller 
        and NC.sp>0
        
        
select 
  t.NameCat2,
  cast(1 as int) as NumStr,
  t.Otm,
  t.Name_var,
  t.gpName,
  t.gpAddr,
  t.gpCity,
  t.gpStreet,
  t.Obl_ID,
  t.OblName,
  t.fio,
  t.tName,
  t.NumNak,
  t.DateNak,
  t.OurName,
  t.OurAdress,
  t.Our_id,
  t.VetCode,
  SUM(t.M) as M,
  SUM(t.W) as W
from
(
SELECT
  @dtoday as Date_vet_svid,
  STUFF((select ', ' + c.NameCat
  FROM SertifVetCat c where c.IdCat in (SELECT SertifVetCat.IdCat 
                                          FROM NC 
                                               JOIN NV ON NC.DatNom=NV.DatNom
                                               JOIN Nomen ON NV.hitag=Nomen.Hitag
                                               JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
                                               JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
                                               JOIN #DatnomList DL on NC.Datnom=DL.Datnom
                                           WHERE NC.SP > 0)


  for xml path(''))
  ,1,2,'') AS NameCat2,
  'Местность благополучна по особо опасным и карантинным болезням с/х животных и птиц.' as Otm,
  'реализации без ограничений' as Name_var,
  IIF(@total=0, Def.gpName,
  STUFF((select '; ' + d.gpName
    FROM Def d WHERE d.pin IN
    (SELECT def.pin
    FROM NC JOIN NV ON NC.DatNom = NV.DatNom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          JOIN tdVi ON NV.TekID = tdVi.id
          JOIN Nomen ON nv.hitag = Nomen.hitag
          JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
          JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
          JOIN Def ON Nc.B_ID = Def.pin
          JOIN #DatnomList DL on NC.Datnom=DL.Datnom
  WHERE NC.SP>0)
  for xml path(''))
  ,1,2,'') ) AS gpName, 
  IIF(@total=0, Def.gpAddr, '') AS gpAddr,
  STUFF((select '; ' + dbo.SertifCityFromAddr(D.gpAddr)
    FROM Def d WHERE d.pin IN
    (SELECT def.pin
    FROM NC JOIN NV ON NC.DatNom = NV.DatNom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          JOIN tdVi ON NV.TekID = tdVi.id
          JOIN Nomen ON nv.hitag = Nomen.hitag
          JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
          JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
          JOIN Def ON Nc.B_ID = Def.pin
          JOIN #DatnomList DL on NC.Datnom=DL.Datnom
  WHERE NC.SP>0)
  for xml path(''))
  ,1,2,'')  AS gpCity,  
   STUFF((select '; ' + dbo.SertifStreetFromAddr(D.gpAddr)
    FROM Def d WHERE d.pin IN
    (SELECT def.pin
    FROM NC JOIN NV ON NC.DatNom = NV.DatNom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          JOIN tdVi ON NV.TekID = tdVi.id
          JOIN Nomen ON nv.hitag = Nomen.hitag
          JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
          JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
          JOIN Def ON Nc.B_ID = Def.pin
          JOIN #DatnomList DL on NC.Datnom=DL.Datnom
  WHERE NC.SP>0)
  for xml path(''))
  ,1,2,'')  AS gpStreet,
  IIF(@total=0,
      CAST(Def.obl_ID AS varchar),
      STUFF((select ', ' + CAST(o.Obl_ID AS VARCHAR)
      FROM obl o WHERE o.Obl_ID in (SELECT Obl.Obl_ID 
                                      FROM NC
                                      JOIN Def ON Nc.B_ID = Def.pin
                                      JOIN Obl ON Def.Obl_ID = Obl.Obl_ID  
                                      JOIN #DatnomList DL on NC.Datnom=DL.Datnom
                                     WHERE NC.SP > 0)
      for xml path(''))
      ,1,2,'')) 
  AS Obl_Id,

  IIF(@total=0, (CASE WHEN NC.StfNom IS NOT NULL AND NC.StfNom <>'' THEN NC.StfNom ELSE CAST(dbo.InnNak(NC.datnom) AS VARCHAR) END), 
       STUFF((select ', ' + (CASE WHEN n.StfNom IS NOT NULL AND n.StfNom <>'' THEN n.StfNom ELSE CAST(dbo.InnNak(n.datnom) AS VARCHAR) END) --
        FROM NC n where n.Datnom in (SELECT NC.Datnom 
                                                FROM NC 
                                                JOIN NV ON NC.DatNom = NV.DatNom
                                                JOIN tdVi ON NV.TekID = tdVi.id
                                                JOIN Nomen ON nv.hitag = Nomen.hitag
                                                JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
                                                JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
                                                JOIN #DatnomList DL on NC.Datnom=DL.Datnom
                                               WHERE NC.SP > 0)
        for xml path(''))
        ,1,2,'') ) AS NumNak,
  '' AS OblName,
  usrpwd.fio,
  Trades.tName,
      (CASE WHEN NC.StfDate IS NOT NULL AND NC.StfDate <> '30.12.1899' 
        THEN NC.StfDate ELSE NC.ND END) AS DateNak,
  
  fc.OurName,
  fc.OurName AS OurGroupName,
  'г. Воронеж, ул. 45 Стрелковой Дивизии, 234' AS OurAdress,
  fc.Our_id,
  fc.VetCode,
  cast(CEILING(SUM(Nv.Kol/Nomen.minp)) AS INT) as M,
  SUM(Nv.Kol*iif(Nomen.flgWeight=0, Nomen.Netto,tdVi.Weight))
  +
  (select SUM(isnull(nvz.zakaz*nm.Netto,0))
   from nvzakaz nvz join nomen nm on nvz.hitag=nm.hitag
   where nvz.datnom=NC.datnom and nvz.Done=0
  ) as W
  
  FROM NC JOIN NV ON NC.DatNom = NV.DatNom
          JOIN #DatnomList DL on NC.Datnom=DL.Datnom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          JOIN tdVi ON NV.TekID = tdVi.id
          JOIN Nomen ON nv.hitag = Nomen.hitag
          JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
          JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
          JOIN Def ON Nc.B_ID = Def.pin
          JOIN usrPwd ON usrpwd.uin = @uin
          LEFT JOIN Trades ON usrpwd.trID = Trades.trID
  WHERE NC.SP>0 
   
GROUP BY 
  nc.DatNom,
  nc.ND,   nc.StfNom, NC.StfDate,
  Def.gpName,
  IIF(@total=0, Def.gpAddr, ''),
  Def.Obl_ID,
  usrpwd.fio, 
  Trades.tName,
  fc.Our_id, 
  fc.OurName,
  fc.VetCode,
  fc.FirmGroup 
  ) t
 group by
  t.NameCat2,
  t.Otm,
  t.Name_var,
  t.gpName,
  t.gpAddr,
  t.gpCity,
  t.gpStreet,
  t.Obl_ID,
  t.OblName,
  t.fio,
  t.tName,
  t.NumNak,
  t.DateNak,
  t.OurName,
  t.OurAdress,
  t.Our_id,
  t.VetCode
end
/************************************************************************/
  ELSE
begin
  if isnull(@Our_IDSaller,0)=0 
    insert into #DatnomList (datnom) 
    select K as Datnom from dbo.Str2intarray(@DatNomStr)
  else 
  insert into #DatnomList (datnom) 
      select DISTINCT NC.Datnom 
      from NC 
      join nv on nc.datnom=nv.datnom
      join visual on nv.tekid=visual.id
      join defcontract dc on dc.dck = visual.dck
      where NC.ND=@dt 
        and dc.our_id=@Our_ID_Owner 
        AND NC.ourID=@Our_IDSaller 
        and NC.sp>0
        
  select 
  t.NameCat2,
  cast(1 as int) as NumStr,
  t.Otm,
  t.Name_var,
  t.gpName,
  t.gpAddr,
  t.gpCity,
  t.gpStreet,
  t.Obl_ID,
  t.OblName,
  t.fio,
  t.tName,
  t.NumNak,
  t.DateNak,
  t.OurName,
  t.OurAdress,
  t.Our_id,
  t.VetCode,
  SUM(t.M) as M,
  SUM(t.W) as W
from
(
SELECT
  @dtoday as Date_vet_svid,
  STUFF((select ', ' + c.NameCat
  FROM SertifVetCat c where c.IdCat in (SELECT SertifVetCat.IdCat 
                                          FROM NC 
                                               JOIN NV ON NC.DatNom=NV.DatNom
                                               JOIN Nomen ON NV.hitag=Nomen.Hitag
                                               JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
                                               JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
                                               JOIN #DatnomList DL on NC.Datnom=DL.Datnom
                                           WHERE NC.SP > 0)


  for xml path(''))
  ,1,2,'') AS NameCat2,
  'Местность благополучна по особо опасным и карантинным болезням с/х животных и птиц.' as Otm,
  'реализации без ограничений' as Name_var,
  IIF(@total=0, Def.gpName,
  STUFF((select '; ' + d.gpName
    FROM Def d WHERE d.pin IN
    (SELECT def.pin
    FROM NC JOIN NV ON NC.DatNom = NV.DatNom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          JOIN visual ON NV.TekID = visual.id
          JOIN Nomen ON nv.hitag = Nomen.hitag
          JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
          JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
          JOIN Def ON Nc.B_ID = Def.pin
          JOIN #DatnomList DL on NC.Datnom=DL.Datnom
  WHERE NC.SP>0)
  for xml path(''))
  ,1,2,'') ) AS gpName, 

  IIF(@total=0, Def.gpAddr, '') AS gpAddr,
  STUFF((select '; ' + dbo.SertifCityFromAddr(D.gpAddr)
    FROM Def d WHERE d.pin IN
    (SELECT def.pin
    FROM NC JOIN NV ON NC.DatNom = NV.DatNom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          JOIN visual ON NV.TekID = visual.id
          JOIN Nomen ON nv.hitag = Nomen.hitag
          JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
          JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
          JOIN Def ON Nc.B_ID = Def.pin
          JOIN #DatnomList DL on NC.Datnom=DL.Datnom
  WHERE NC.SP>0)
  for xml path(''))
  ,1,2,'')  AS gpCity,  

 STUFF((select '; ' + dbo.SertifStreetFromAddr(D.gpAddr)
    FROM Def d WHERE d.pin IN
    (SELECT def.pin
    FROM NC JOIN NV ON NC.DatNom = NV.DatNom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          JOIN visual ON NV.TekID = visual.id
          JOIN Nomen ON nv.hitag = Nomen.hitag
          JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
          JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
          JOIN Def ON Nc.B_ID = Def.pin
          JOIN #DatnomList DL on NC.Datnom=DL.Datnom
  WHERE NC.SP>0)
  for xml path(''))
  ,1,2,'')  AS gpStreet,  

  IIF(@total=0,
      CAST(Def.Obl_ID AS VARCHAR),
      STUFF((select ', ' + CAST(o.Obl_ID AS VARCHAR)
      FROM obl o WHERE o.Obl_ID in (SELECT Obl.Obl_ID 
                                      FROM NC
                                      JOIN Def ON Nc.B_ID = Def.pin
                                      JOIN Obl ON Def.Obl_ID = Obl.Obl_ID  
                                      JOIN #DatnomList DL on NC.Datnom=DL.Datnom
                                     WHERE NC.SP > 0)
      for xml path(''))
      ,1,2,'')) 
  AS Obl_Id,
  
  IIF(@total=0, (CASE WHEN NC.StfNom IS NOT NULL AND NC.StfNom <>'' THEN NC.StfNom ELSE CAST(dbo.InnNak(NC.datnom) AS VARCHAR) END), 
       STUFF((select ', ' + (CASE WHEN n.StfNom IS NOT NULL AND n.StfNom <>'' THEN n.StfNom ELSE CAST(dbo.InnNak(n.datnom) AS VARCHAR) END) --
        FROM NC n where n.Datnom in (SELECT NC.Datnom 
                                                FROM NC 
                                                JOIN NV ON NC.DatNom = NV.DatNom
                                                JOIN visual ON NV.TekID = visual.id
                                                JOIN Nomen ON nv.hitag = Nomen.hitag
                                                JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
                                                JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
                                                JOIN #DatnomList DL on NC.Datnom=DL.Datnom
                                               WHERE NC.SP > 0)
        for xml path(''))
        ,1,2,'') ) AS NumNak,

  '' AS OblName,
  usrpwd.fio,
  Trades.tName,
  
      (CASE WHEN NC.StfDate IS NOT NULL AND NC.StfDate <> '30.12.1899' 
        THEN NC.StfDate ELSE NC.ND END) AS DateNak,
  
  fc.OurName,
  fc.OurName AS OurGroupName,
  'г. Воронеж, ул. 45 Стрелковой Дивизии, 234' AS OurAdress,
  fc.Our_id,
  fc.VetCode,
  cast(CEILING(SUM(Nv.Kol/Nomen.minp)) AS INT) as M,
  SUM(Nv.Kol*iif(Nomen.flgWeight=0, Nomen.Netto,visual.Weight)) as W
  
  FROM NC JOIN NV ON NC.DatNom = NV.DatNom
          JOIN #DatnomList DL on NC.Datnom=DL.Datnom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          JOIN visual ON NV.TekID = visual.id
          JOIN Nomen ON nv.hitag = Nomen.hitag
          JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
          JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
          JOIN Def ON Nc.B_ID = Def.pin
          JOIN usrPwd ON usrpwd.uin = @uin
          LEFT JOIN Trades ON usrpwd.trID = Trades.trID
  WHERE NC.SP>0
   
GROUP BY 
  nc.DatNom,
  nc.ND,   nc.StfNom, NC.StfDate,
  Def.gpName,
  Def.gpAddr,
  Def.Obl_ID,
  usrpwd.fio, 
  Trades.tName,
  fc.Our_id, 
  fc.OurName,
  fc.VetCode,
  fc.FirmGroup 
  ) t
 group by
  t.NameCat2,
  t.Otm,
  t.Name_var,
  t.gpName,
  t.gpAddr,
  t.gpCity,
  t.gpStreet,
  t.Obl_ID,
  t.OblName,
  t.fio,
  t.tName,
  t.NumNak,
  t.DateNak,
  t.OurName,
  t.OurAdress,
  t.Our_id,
  t.VetCode
 end
  DROP TABLE #DatnomList
END