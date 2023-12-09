CREATE PROCEDURE dbo.SertifPrintVetPril @DatNomStr varchar(300), @dt DATETIME, @Our_ID_Owner INT=0, @Our_IDSaller int=0
AS 
BEGIN 
set @dt = cast(convert(varchar, @dt, 104) as datetime)

if object_id('tempdb..#DatnomList') is not null drop table #DatnomList
create table #DatnomList (datnom int)

if object_id('tempdb..#NVtemp') is not null drop table #NVtemp
create table #NVtemp (DatNom INT, TekID INT, Hitag INT, Price MONEY,
  Cost MONEY, Kol DECIMAL(10,3), Kol_B DECIMAL(10,3), Sklad SMALLINT, BasePrice Money,
  Remark VARCHAR(80), tip TINYINT, Meas TINYINT, DelivCancel BIT, OrigPrice DECIMAL(10,2), ag_id INT)

if @Our_IDSaller=0 
begin
  insert into #DatnomList (datnom) 
  select K as Datnom from dbo.Str2intarray(@DatNomStr)
end  
else 
begin
  IF @dt = dbo.today()
    begin
      insert into #DatnomList (datnom) 
      --select Datnom from NC where ND=@dt and ourID=@Our_IDSaller and sp>0 end
      SELECT DISTINCT NC.Datnom 
      from NC 
      join nv on nc.datnom=nv.datnom
      join tdvi on nv.tekid=tdvi.id
      join defcontract dc on dc.dck = tdvi.dck
      where NC.ND=@dt 
        and dc.our_id=@Our_ID_Owner 
        AND NC.ourID=@Our_IDSaller 
        and NC.sp>=0
    end
  ELSE 
    begin
      insert into #DatnomList (datnom) 
      select DISTINCT NC.Datnom 
      from NC 
      join nv on nc.datnom=nv.datnom
      join visual on nv.tekid=visual.id
      join defcontract dc on dc.dck = visual.dck
      where NC.ND=@dt 
        and dc.our_id=@Our_ID_Owner 
        AND NC.ourID=@Our_IDSaller 
        and NC.sp>=0
    end
end  


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


if object_id('tempdb..#tempPril') is not null drop table #tempPril
create table #tempPril(IdCat int, ProducerID int, 
                       month1 int, month2 int, year1 int, year2 INT,
                       Date1 DATETIME, Date2 DATETIME,      
                       NameCat VARCHAR(256), N_vet_svid VARCHAR(50), Date_vet_svid DATETIME,  
                       Lab_issl VARCHAR(8000), LabIssl VARCHAR(8000), 
                       otm VARCHAR(256), ProducerName VARCHAR(50), 
                       ProducerAddr VARCHAR(200), Code VARCHAR(50))


IF @dt = dbo.today()
BEGIN
insert into #tempPril(IdCat, ProducerID, 
                       Date1, Date2,      
                       NameCat, N_vet_svid, 
                       Date_vet_svid, Lab_issl, LabIssl, otm, 
                       ProducerName, ProducerAddr, Code)
  SELECT DISTINCT  
  temp.IdCat, 
  iif (temp.ProducerID IS NOT NULL, temp.ProducerID, 0),
  --MIN(temp.DATER) AS Date1,
  --MAX(temp.DATER) AS Date2,   
    IIF(MIN(temp.DATER)>'01.01.2002',MIN(temp.DATER),NULL) AS Date1,
    IIF(MAX(temp.DATER)>'01.01.2002',MAX(temp.DATER),NULL) AS Date2, 
  temp.NameCat,
  temp.N_vet_svid,
  temp.Date_vet_svid,
  temp.Lab_issl,
  temp.LabIssl,
  temp.Otm,
  temp.ProducerName,
  temp.ProducerAddr,
  temp.Code

FROM
  (select
  tdvi.DATER,
  SVC.IdCat, 
  SVC.NameCat,
  SertifVetSvid.N_vet_svid,
  SertifVetSvid.Date_vet_svid,
  SertifVetSvid.Lab_issl,
  SertifLabIssl.LabIssl,
  SertifVetSvid.Otm,
  Pr.ProducerID,
  Pr.ProducerName,
  Pr.ProducerAddr,
  ProducerCode.Code
FROM NC
  JOIN #NVtemp ON NC.DatNom = #NVtemp.DatNom
  LEFT JOIN tdVi ON #NVtemp.TekID = tdVi.id
  LEFT JOIN Inpdet ON tdVi.startid = Inpdet.id
  --LEFT JOIN InpdetVetSvid ON Inpdet.Id = InpdetVetSvid.Id AND NC.OurID = iif(@Our_IDSaller=0, InpdetVetSvid.Ourid,  NC.OurID)
  LEFT JOIN InpdetVetSvid ON tdVi.startid = InpdetVetSvid.Id AND NC.OurID = iif(@Our_IDSaller=0, InpdetVetSvid.Ourid,  NC.OurID)
  LEFT JOIN SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Is_Del = 0 AND SertifVetSvid.Our_id = iif(@Our_IDSaller=0, InpdetVetSvid.Ourid,  @Our_ID_Owner) --NC.OurID 
  LEFT JOIN SertifLabIssl ON InpdetVetSvid.IdIs = SertifLabIssl.IdIs AND SertifVetSvid.Is_Del = 0 AND SertifVetSvid.Our_id = iif(@Our_IDSaller=0, InpdetVetSvid.Ourid,  @Our_ID_Owner) --NC.OurID 
  JOIN Nomen ON #NVtemp.hitag = Nomen.hitag
  JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
  JOIN SertifVetCat SVC ON SertifNomenVetCat.IdCat = SVC.IdCat
  --LEFT JOIN Producer Pr ON Inpdet.ProducerID = Pr.ProducerID
  LEFT JOIN Producer Pr ON IIF(Inpdet.ProducerID IS NOT NULL, Inpdet.ProducerID, tdvi.ProducerID) = Pr.ProducerID
  LEFT JOIN ProducerCode ON InpdetVetSvid.ProducerCodeId = ProducerCode.ProducerCodeId
  JOIN #DatnomList DL on NC.Datnom=DL.Datnom
WHERE --NC.datnom = @datnomPril
      NC.SP >= 0
 -- AND NC.nd BETWEEN iif(tdvi.DATER IS NOT NULL, tdvi.DATER, '30.12.1899') AND iif(tdvi.SROKH IS NOT NULL, tdvi.SROKH, '01.01.2050') --NC.nd BETWEEN tdvi.DATER AND tdvi.SROKH
) temp
GROUP BY 
temp.IdCat,
temp.ProducerID,
temp.NameCat,
temp.N_vet_svid,
temp.Date_vet_svid,
temp.Lab_issl,
temp.LabIssl,
temp.Otm,
temp.ProducerName,
temp.ProducerAddr,
temp.Code
END

ELSE

BEGIN
insert into #tempPril(IdCat, ProducerID, 
                       Date1, Date2,      
                       NameCat, N_vet_svid, 
                       Date_vet_svid, Lab_issl, LabIssl, otm, 
                       ProducerName, ProducerAddr, Code)

SELECT DISTINCT  
  temp.IdCat, 
  iif (temp.ProducerID IS NOT NULL, temp.ProducerID, 0),
  --MIN(temp.DATER) AS Date1,
  --MAX(temp.DATER) AS Date2,   
    IIF(MIN(temp.DATER)>'01.01.2002',MIN(temp.DATER),NULL) AS Date1,
    IIF(MAX(temp.DATER)>'01.01.2002',MAX(temp.DATER),NULL) AS Date2, 
  temp.NameCat,
  temp.N_vet_svid,
  temp.Date_vet_svid,
  temp.Lab_issl,
  temp.LabIssl,
  temp.Otm,
  temp.ProducerName,
  temp.ProducerAddr,
  temp.Code
 
FROM
  (select
  visual.DATER,
  SVC.NameCat,
  SertifVetSvid.N_vet_svid,
  SertifVetSvid.Date_vet_svid,
  SertifVetSvid.Lab_issl,
  SertifLabIssl.LabIssl,
  SertifVetSvid.Otm,
  Pr.ProducerID, 
  SVC.IdCat, 
  Pr.ProducerName,
  Pr.ProducerAddr,
  ProducerCode.Code
FROM NC
  JOIN #NVtemp ON NC.DatNom = #NVtemp.DatNom
  LEFT JOIN visual ON #NVtemp.TekID = visual.id
  LEFT JOIN Inpdet ON visual.startid = Inpdet.id 
  --LEFT JOIN InpdetVetSvid ON Inpdet.Id = InpdetVetSvid.Id  AND NC.OurID = iif(@Our_IDSaller=0, InpdetVetSvid.Ourid,  NC.OurID)
  LEFT JOIN InpdetVetSvid ON visual.startid = InpdetVetSvid.Id  AND NC.OurID = iif(@Our_IDSaller=0, InpdetVetSvid.Ourid,  NC.OurID)
  LEFT JOIN SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Is_Del = 0 AND SertifVetSvid.Our_id = iif(@Our_IDSaller=0, InpdetVetSvid.Ourid,  @Our_ID_Owner) --NC.OurID 
  LEFT JOIN SertifLabIssl ON InpdetVetSvid.IdIs = SertifLabIssl.IdIs AND SertifVetSvid.Is_Del = 0 AND SertifVetSvid.Our_id = iif(@Our_IDSaller=0, InpdetVetSvid.Ourid,  @Our_ID_Owner) --NC.OurID 
  JOIN Nomen ON #NVtemp.hitag = Nomen.hitag
  JOIN SertifNomenVetCat ON Nomen.hitag = SertifNomenVetCat.Hitag
  JOIN SertifVetCat SVC ON SertifNomenVetCat.IdCat = SVC.IdCat
  --LEFT JOIN Producer Pr ON Inpdet.ProducerID = Pr.ProducerID
  LEFT JOIN Producer Pr ON IIF(Inpdet.ProducerID IS NOT NULL, Inpdet.ProducerID, visual.ProducerID) = Pr.ProducerID
  LEFT JOIN ProducerCode ON InpdetVetSvid.ProducerCodeId = ProducerCode.ProducerCodeId
  JOIN #DatnomList DL on NC.Datnom=DL.Datnom
WHERE --NC.datnom = @datnomPril
      NC.SP >= 0
 -- AND NC.nd BETWEEN iif(visual.DATER IS NOT NULL, visual.DATER, '30.12.1899') AND iif(visual.SROKH IS NOT NULL, visual.SROKH, '01.01.2050') --NC.nd BETWEEN visual.DATER AND visual.SROKH
) temp
GROUP BY 
temp.IdCat,
temp.ProducerID,
temp.NameCat,
temp.N_vet_svid,
temp.Date_vet_svid,
temp.Lab_issl,
temp.LabIssl,
temp.Otm,
temp.ProducerName,
temp.ProducerAddr,
temp.Code
END
  

if object_id('tempdb..#tempDater') is not null drop table #tempDater
create table #tempDater(IdCat int, ProducerID int, month1 int, month2 int, year1 int, year2 INT)
insert into #tempDater
SELECT IdCat, ProducerId, 
       MONTH(MIN(#tempPril.Date1)) AS month1,    
       MONTH(MAX(#tempPril.Date2)) AS month2,
       YEAR(MIN(#tempPril.Date1)) AS year1,
       YEAR(MAX(#tempPril.Date2)) AS year2
  FROM #tempPril
GROUP BY #tempPril.IdCat, #tempPril.ProducerId  


UPDATE #tempPril 
   SET #tempPril.[month1] = #tempDater.[month1],
       #tempPril.[month2] = #tempDater.[month2],
       #tempPril.[year1] = #tempDater.[year1],
       #tempPril.[year2] = #tempDater.[year2]
   FROM #tempPril 
   JOIN #tempDater ON #tempPril.[IdCat] = #tempDater.[IdCat] 
                  AND #tempPril.[ProducerID] = #tempDater.[ProducerID]


SELECT DISTINCT 
  #tempPril.IdCat, 
  #tempPril.ProducerID,
  #tempPril.month1 AS month1,
  #tempPril.month2 AS month2,
  #tempPril.year1 AS year1,  
  #tempPril.year2 AS year2,  
  #tempPril.NameCat,
  #tempPril.N_vet_svid,
  #tempPril.Date_vet_svid,
  #tempPril.Lab_issl,
  #tempPril.LabIssl,
  #tempPril.Otm,
  #tempPril.ProducerName,
  #tempPril.ProducerAddr,
  #tempPril.Code,
  #tempPril.Date1,
  #tempPril.Date2


FROM #tempPril


drop table #tempPril
drop table #tempDater
drop table #DatnomList
DROP TABLE #NVtemp

END