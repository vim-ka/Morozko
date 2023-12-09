CREATE PROCEDURE dbo.GetCurrentNCDet_copy
@datnom BIGINT,
@isGroup bit=0,
@b_id int=0,
@dt1 datetime='20010101',
@dt2 datetime='20010101'  
as
if @isGroup=0
begin
	if @datnom=dbo.InDatNom(@datnom%10000,getdate())
	begin
		select distinct*, case when y.pics>0 then cast(1 as bit) else cast(0 as bit) end [x] from (
		select 	nv.datnom, 
						nv.Hitag, 
						nv.tekid, 
						n.name, 
						nv.Price, 
						nv.cost, 
						nv.Kol, 
						nv.Kol_B,
						ve.fam, 
						t.Country,
						isnull(t.sert_id,0) [sert_id],

            InpdetVetSvid.VetId AS Id_vet_svid,
            InpdetVetSvid.VetUuid, 

						--case when n.flgWeight=1 then t.weight*nv.kol else n.Netto*nv.kol end Ves,
            nv.kol * IIF(nv.unid=1, 1, isnull(UnitConv.k, n.netto)) ves,
						nv.Sklad, 
						nv.OrigPrice, 
						nv.ag_id,
						d.pin, 
						d.gpName, 
						d.gpAddr, 
						m.Marsh, 
						c.RemarkOP,
						f.OurName,
						(select count(a.sert_id) from SertifPic a where a.sert_id=t.sert_id and a.isdel=0) as Pics,
            convert(VARCHAR, Inpdet.nd, 104) + ', ' + cast (inpdet.ncom AS VARCHAR) AS DateCom
		from nv 
		left join tdvi t on t.ID=nv.tekID
    --left join visual t on t.ID=nv.tekID
    LEFT JOIN Inpdet ON t.startid = Inpdet.id 
		left join vendors ve on t.ncod=ve.ncod 
		left join nomen n on n.hitag=nv.hitag 
		left join nc c on c.datnom=nv.datnom
		left join def d on c.b_id=d.pin 
		left join FirmsConfig f on c.OurID=f.Our_id
    LEFT JOIN InpdetVetSvid ON Inpdet.Id = InpdetVetSvid.Id AND C.OurID = InpdetVetSvid.OurID
    LEFT JOIN SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Our_id = InpdetVetSvid.OurID AND SertifVetSvid.Is_Del = 0
    LEFT JOIN Marsh m ON c.mhID = m.mhid
    LEFT JOIN units on units.unid = nv.unid
    LEFT JOIN UnitConv ON nv.hitag = UnitConv.Hitag 
                      AND UnitConv.unid = nv.unid AND UnitConv.unid2 = 1   --для перевода в кг
		where nv.datnom=@datnom 
					and d.tip=1
					and nv.kol>0
		union all
    select 	z.datnom, 
						z.Hitag, 
						0 [tekid], 
						n.name, 
						z.Price, 
						z.cost, 
						z.Zakaz, 
						0 [kol_b],
						'' [fam], 
						'' [country],
						isnull((select top 1 tdvi.sert_id from tdvi where tdvi.hitag=z.hitag),0) [sert_id],

       InpdetVetSvid.VetId AS Id_vet_svid,
       InpdetVetSvid.VetUuid, 
						z.zakaz*ISNULL(UnitConv.k, 1) [ves], 
						0 [sklad], 
						null [origprice], 
						null [ag_id],
						0 [pin], 
						'' [gpname], 
						'' [gpaddr], 
						0 [Marsh], 
						'' [remarkop],
						'' [ourname],
						(select count(a.sert_id) from SertifPic a where a.sert_id=(select top 1 tdvi.sert_id from tdvi where tdvi.hitag=z.hitag) and a.isdel=0) [pics],
            convert(VARCHAR, Inpdet.nd, 104) + ', ' + cast (inpdet.ncom AS VARCHAR) AS DateCom
    from nvZakaz z 
    left join nomen n on n.hitag=z.Hitag
    LEFT JOIN Inpdet ON n.hitag = Inpdet.hitag
    LEFT JOIN tdVi ON tdVi.startid = Inpdet.id
    --LEFT JOIN visual ON Visual.startid = Inpdet.id
    LEFT JOIN NV ON NV.TekID = tdVi.id
    --LEFT JOIN NV ON NV.TekID = Visual.id
    LEFT JOIN NC ON NC.DatNom = NV.DatNom
    LEFT JOIN InpdetVetSvid ON Inpdet.Id = InpdetVetSvid.Id AND NC.OurID = InpdetVetSvid.OurID
    LEFT JOIN SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Our_id = InpdetVetSvid.OurID AND SertifVetSvid.Is_Del = 0
    LEFT JOIN units on units.unid = nv.unid
    LEFT JOIN UnitConv ON nv.hitag = UnitConv.Hitag 
                      AND UnitConv.unid = nv.unid AND UnitConv.unid2 = 1   --для перевода в кг
    where z.datnom= @datnom
    			and z.Done=0			
          
          ) y
	end
	else
	begin
		select distinct*, case when y.pics>0 then cast(1 as bit) else cast(0 as bit) end [x] from (
		select 	nv.datnom, 
						nv.Hitag, 
						nv.tekid, 
						n.name, 
						nv.Price, 
						nv.cost, 
						nv.Kol, 
						nv.Kol_B,
						ve.fam, 
						t.Country,
						isnull(t.sert_id,0) [sert_id],

       InpdetVetSvid.VetId AS Id_vet_svid,
       InpdetVetSvid.VetUuid, 
						--case when n.flgWeight=1 then t.weight*nv.kol else n.Netto*nv.kol end Ves,
            nv.kol*ISNULL(UnitConv.k, 1) ves,
						nv.Sklad, 
						nv.OrigPrice, 
						nv.ag_id,
						d.pin, 
						d.gpName, 
						d.gpAddr, 
						m.Marsh, 
						c.RemarkOP,
						f.OurName,
						(select count(a.sert_id) from SertifPic a where a.sert_id=t.sert_id and a.isdel=0) as Pics,
            convert(VARCHAR, Inpdet.nd, 104) + ', ' + cast (inpdet.ncom AS VARCHAR) AS DateCom
		from nv 
		left join visual t on t.ID=nv.tekID
    --LEFT JOIN tdVi ON NV.TekID = tdVi.id
    --LEFT JOIN Inpdet ON tdVi.startid = Inpdet.id
    LEFT JOIN Inpdet ON t.startid = Inpdet.id
		left join vendors ve on t.ncod=ve.ncod 
		left join nomen n on n.hitag=nv.hitag 
		left join nc c on c.datnom=nv.datnom
		left join def d on c.b_id=d.pin 
		left join FirmsConfig f on c.OurID=f.Our_id
    LEFT JOIN InpdetVetSvid ON Inpdet.Id = InpdetVetSvid.Id AND C.OurID = InpdetVetSvid.OurID
    LEFT JOIN SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Our_id = InpdetVetSvid.OurID AND SertifVetSvid.Is_Del = 0
		LEFT JOIN Marsh m ON c.mhID = m.mhid
    LEFT JOIN units on units.unid = nv.unid
    LEFT JOIN UnitConv ON nv.hitag = UnitConv.Hitag 
                      AND UnitConv.unid = nv.unid AND UnitConv.unid2 = 1   --для перевода в кг
    where nv.datnom=@datnom
					and d.tip=1
					and nv.kol>0
		) y
	end
end
else
begin
	select distinct*, case when y.pics>0 then cast(1 as bit) else cast(0 as bit) end [x] from (
	select 	nv.datnom, 
						nv.Hitag, 
						nv.tekid, 
						n.name, 
						nv.Price, 
						nv.cost, 
						nv.Kol, 
						nv.Kol_B,
						ve.fam, 
						t.Country,
						isnull(t.sert_id,0) [sert_id],
                         
                            
          InpdetVetSvid.VetId AS Id_vet_svid,
          InpdetVetSvid.VetUuid, 
						--case when n.flgWeight=1 then t.weight*nv.kol else n.Netto*nv.kol end Ves,
            nv.kol*ISNULL(UnitConv.k, 1) ves,
						nv.Sklad, 
						nv.OrigPrice, 
						nv.ag_id,
						d.pin, 
						d.gpName, 
						d.gpAddr, 
						m.Marsh, 
						c.RemarkOP,
						f.OurName,
						(select count(a.sert_id) from SertifPic a where a.sert_id=t.sert_id and a.isdel=0) as Pics,
            convert(VARCHAR, Inpdet.nd, 104) + ', ' + cast (inpdet.ncom AS VARCHAR) AS DateCom
		from nv 
		left join visual t on t.ID=nv.tekID
    --LEFT JOIN tdVi ON NV.TekID = tdVi.id
    --LEFT JOIN Inpdet ON tdVi.startid = Inpdet.id
    LEFT JOIN Inpdet ON t.startid = Inpdet.id
		left join vendors ve on t.ncod=ve.ncod 
		left join nomen n on n.hitag=nv.hitag 
		left join nc c on c.datnom=nv.datnom
		left join def d on c.b_id=d.pin 
		left join FirmsConfig f on c.OurID=f.Our_id
    LEFT JOIN InpdetVetSvid ON Inpdet.Id = InpdetVetSvid.Id AND C.OurID = InpdetVetSvid.OurID
    LEFT JOIN SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Our_id = InpdetVetSvid.OurID AND SertifVetSvid.Is_Del = 0
    LEFT JOIN Marsh m ON c.mhID = m.mhid
    LEFT JOIN units on units.unid = nv.unid
    LEFT JOIN UnitConv ON nv.hitag = UnitConv.Hitag 
                      AND UnitConv.unid = nv.unid AND UnitConv.unid2 = 1   --для перевода в кг
    where nv.datnom in (select datnom from nc where b_id=@b_id and nd>=@dt1 and nd<=@dt2)
					and d.tip=1
					and nv.kol>0
		) y
END