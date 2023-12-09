CREATE PROCEDURE dbo.GetCurrentNCDet
@datnom INT,
@isGroup bit=0,
@b_id int=0,
@dt1 datetime='20010101',
@dt2 datetime='20010101'  
as
if @isGroup=0
begin
	if @datnom=dbo.InDatNom(@datnom%10000,getdate())
	begin
		select *, case when y.pics>0 then cast(1 as bit) else cast(0 as bit) end [x] from (
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
						case when n.flgWeight=1 then t.weight*nv.kol else n.Netto*nv.kol end Ves,
						nv.Sklad, 
						nv.BasePrice, 
						nv.remark, 
						nv.tip, 
						nv.Meas,
						nv.DelivCancel, 
						nv.OrigPrice, 
						nv.ag_id,
						d.pin, 
						d.gpName, 
						d.gpAddr, 
						c.Marsh, 
						c.RemarkOP,
						f.OurName,
						(select count(a.sert_id) from SertifPic a where a.sert_id=t.sert_id and a.isdel=0) as Pics
		from nv 
		left join tdvi t on t.ID=nv.tekID
		left join vendors ve on t.ncod=ve.ncod 
		left join nomen n on n.hitag=nv.hitag 
		left join nc c on c.datnom=nv.datnom
		left join def d on c.b_id=d.pin 
		left join FirmsConfig f on c.OurID=f.Our_id
		where nv.datnom=@datnom 
					and d.tip=1
					and nv.kol>0
		union 
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
						z.zakaz*n.netto [ves],
						0 [sklad], 
						0 [baseprice], 
						'' [remark], 
						0 [tip], 
						0 [meas],
						cast(0 as bit) [delivcancel], 
						null [origprice], 
						null [ag_id],
						0 [pin], 
						'' [gpname], 
						'' [gpaddr], 
						0 [marsh], 
						'' [remarkop],
						'' [ourname],
						(select count(a.sert_id) from SertifPic a where a.sert_id=(select top 1 tdvi.sert_id from tdvi where tdvi.hitag=z.hitag) and a.isdel=0) [pics]
    from nvZakaz z 
    left join nomen n on n.hitag=z.Hitag
    where z.datnom= @datnom
    			and z.Done=0			
          
          ) y
	end
	else
	begin
		select *, case when y.pics>0 then cast(1 as bit) else cast(0 as bit) end [x] from (
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
						case when n.flgWeight=1 then t.weight*nv.kol else n.Netto*nv.kol end Ves,
						nv.Sklad, 
						nv.BasePrice, 
						nv.remark, 
						nv.tip, 
						nv.Meas,
						nv.DelivCancel, 
						nv.OrigPrice, 
						nv.ag_id,
						d.pin, 
						d.gpName, 
						d.gpAddr, 
						c.Marsh, 
						c.RemarkOP,
						f.OurName,
						(select count(a.sert_id) from SertifPic a where a.sert_id=t.sert_id and a.isdel=0) as Pics
		from nv 
		left join visual t on t.ID=nv.tekID
		left join vendors ve on t.ncod=ve.ncod 
		left join nomen n on n.hitag=nv.hitag 
		left join nc c on c.datnom=nv.datnom
		left join def d on c.b_id=d.pin 
		left join FirmsConfig f on c.OurID=f.Our_id
		where nv.datnom=@datnom
					and d.tip=1
					and nv.kol>0
		) y
	end
end
else
begin
	select *, case when y.pics>0 then cast(1 as bit) else cast(0 as bit) end [x] from (
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
						case when n.flgWeight=1 then t.weight*nv.kol else n.Netto*nv.kol end Ves,
						nv.Sklad, 
						nv.BasePrice, 
						nv.remark, 
						nv.tip, 
						nv.Meas,
						nv.DelivCancel, 
						nv.OrigPrice, 
						nv.ag_id,
						d.pin, 
						d.gpName, 
						d.gpAddr, 
						c.Marsh, 
						c.RemarkOP,
						f.OurName,
						(select count(a.sert_id) from SertifPic a where a.sert_id=t.sert_id and a.isdel=0) as Pics
		from nv 
		left join visual t on t.ID=nv.tekID
		left join vendors ve on t.ncod=ve.ncod 
		left join nomen n on n.hitag=nv.hitag 
		left join nc c on c.datnom=nv.datnom
		left join def d on c.b_id=d.pin 
		left join FirmsConfig f on c.OurID=f.Our_id
		where nv.datnom in (select datnom from nc where b_id=@b_id and nd>=@dt1 and nd<=@dt2)
					and d.tip=1
					and nv.kol>0
		) y
end