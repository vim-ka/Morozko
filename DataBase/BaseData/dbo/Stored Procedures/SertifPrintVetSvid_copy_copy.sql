CREATE PROCEDURE dbo.SertifPrintVetSvid_copy_copy @DatNomStr varchar(300), @uin INT, @total BIT, @dt DATETIME, @Our_ID_Owner INT=0, @Our_IDSaller int=0
AS 
BEGIN 
set @dt = cast(convert(varchar, @dt, 104) as datetime)
declare @dtoday datetime
set @dtoday=dbo.today()


if object_id('tempdb..#DatnomList') is not null drop table #DatnomList
create table #DatnomList (datnom int)

if object_id('tempdb..#NVtemp') is not null drop table #NVtemp
create table #NVtemp (DatNom INT, TekID INT, Hitag INT, Price MONEY,
  Cost MONEY, Kol DECIMAL(10,3), Kol_B DECIMAL(10,3), Sklad SMALLINT, BasePrice Money,
  Remark VARCHAR(80), tip TINYINT, Meas TINYINT, DelivCancel BIT, OrigPrice DECIMAL(10,2), ag_id INT)

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
        

---------------------------------------------------------------------------------------

INSERT INTO #NVtemp
  SELECT nv.DatNom, nv.TekID, nv.Hitag, nv.Price, nv.Cost,
  nv.Kol, nv.Kol_B, nv.Sklad, nv.BasePrice, nv.Remark,
  nv.tip, nv.Meas, nv.DelivCancel, nv.OrigPrice, nv.ag_id
  FROM nv 
  JOIN #DatnomList dl ON NV.DatNom = dl.datnom

	insert into #NVtemp
  select z.datnom,
         -1,
         z.Hitag,
         0,
         0,
         z.Zakaz,
         0,
         z.skladNo,
         0,
         '',
         0,
         0,
         cast(0 as bit),
         0,
         z.AuthorOP
  from nvZakaz z
  JOIN #DatnomList dl ON z.datnom = dl.datnom
  WHERE z.Done = 0
-------------------------------------------------------------------------------------------
        


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
                                               LEFT JOIN #NVtemp ON NC.DatNom=#NVtemp.DatNom
                                               LEFT JOIN Nomen ON #NVtemp.hitag=Nomen.Hitag
                                               LEFT JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
                                               LEFT JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
                                               LEFT JOIN #DatnomList DL on NC.Datnom=DL.Datnom
                                           WHERE NC.SP > 0)


  for xml path(''))
  ,1,2,'') AS NameCat2,
  'Местность благополучна по особо опасным и карантинным болезням с/х животных и птиц.' as Otm,
  'реализации без ограничений' as Name_var,
  IIF(@total=0, Def.gpName,
  STUFF((select '; ' + d.gpName
    FROM Def d WHERE d.pin IN
    (SELECT def.pin
    FROM NC JOIN #NVtemp ON NC.DatNom = #NVtemp.DatNom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          JOIN Nomen ON #NVtemp.hitag = Nomen.hitag
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
    FROM NC JOIN #NVtemp ON NC.DatNom = #NVtemp.DatNom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          JOIN Nomen ON #NVtemp.hitag = Nomen.hitag
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
    FROM NC JOIN #NVtemp ON NC.DatNom = #NVtemp.DatNom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          JOIN Nomen ON #NVtemp.hitag = Nomen.hitag
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
                                                JOIN #NVtemp ON NC.DatNom = #NVtemp.DatNom
                                                JOIN Nomen ON #NVtemp.hitag = Nomen.hitag
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
  cast(CEILING(SUM(#NVtemp.Kol/Nomen.minp)) AS INT) as M,
  isnull(SUM(#NVtemp.Kol*iif(Nomen.flgWeight=0 or #nvTemp.Tekid=-1, Nomen.Netto,tdvi.Weight)),0)
  as W
  
  FROM NC JOIN #NVtemp ON NC.DatNom = #NVtemp.DatNom
          JOIN #DatnomList DL on NC.Datnom=DL.Datnom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          LEFT JOIN tdVi on #NVTemp.TekID=tdVi.Id
          JOIN Nomen ON #NVtemp.hitag = Nomen.hitag
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
      LEFT join visual on nv.tekid=visual.id
      join defcontract dc on dc.dck = visual.dck
      where NC.ND=@dt 
        and dc.our_id=@Our_ID_Owner 
        AND NC.ourID=@Our_IDSaller 
        and NC.sp>0
        
---------------------------------------------------------------------------------------
INSERT INTO #NVtemp
  SELECT nv.DatNom, nv.TekID, nv.Hitag, nv.Price, nv.Cost,
  nv.Kol, nv.Kol_B, nv.Sklad, nv.BasePrice, nv.Remark,
  nv.tip, nv.Meas, nv.DelivCancel, nv.OrigPrice, nv.ag_id
  FROM nv 
  JOIN #DatnomList dl ON NV.DatNom = dl.datnom

	insert into #NVtemp
  select z.datnom,
         -1,
         z.Hitag,
         0,
         0,
         z.Zakaz,
         0,
         z.skladNo,
         0,
         '',
         0,
         0,
         cast(0 as bit),
         0,
         z.AuthorOP
  from nvZakaz z
  JOIN #DatnomList dl ON z.datnom = dl.datnom
  WHERE z.Done = 0
---------------------------------------------------------------------------------------

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
                                               JOIN #NVtemp ON NC.DatNom=#NVtemp.DatNom
                                               JOIN Nomen ON #NVtemp.hitag=Nomen.Hitag
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
    FROM NC JOIN #NVtemp ON NC.DatNom = #NVtemp.DatNom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          LEFT JOIN visual ON #NVtemp.TekID = visual.id
          JOIN Nomen ON #NVtemp.hitag = Nomen.hitag
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
    FROM NC JOIN #NVtemp ON NC.DatNom = #NVtemp.DatNom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          LEFT JOIN visual ON #NVtemp.TekID = visual.id
          JOIN Nomen ON #NVtemp.hitag = Nomen.hitag
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
    FROM NC JOIN #NVtemp ON NC.DatNom = #NVtemp.DatNom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          LEFT JOIN visual ON #NVtemp.TekID = visual.id
          JOIN Nomen ON #NVtemp.hitag = Nomen.hitag
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
                                                JOIN #NVtemp ON NC.DatNom = #NVtemp.DatNom
                                                LEFT JOIN visual ON #NVtemp.TekID = visual.id
                                                JOIN Nomen ON #NVtemp.hitag = Nomen.hitag
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
  cast(CEILING(SUM(#NVtemp.Kol/Nomen.minp)) AS INT) as M,
  isnull(SUM(#NVtemp.Kol*iif(Nomen.flgWeight=0 or #nvTemp.Tekid=-1, Nomen.Netto,visual.Weight)),0) as W


  FROM NC JOIN #NVtemp ON NC.DatNom = #NVtemp.DatNom
          JOIN #DatnomList DL on NC.Datnom=DL.Datnom
          JOIN FirmsConfig fc ON NC.OurID=fc.Our_id
          LEFT JOIN visual ON #NVtemp.TekID = visual.id
          JOIN Nomen ON #NVtemp.hitag = Nomen.hitag
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
 END 
  SELECT * FROM #NVtemp
  DROP TABLE #DatnomList
  DROP TABLE #NVtemp
END