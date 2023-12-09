CREATE PROCEDURE dbo.GetnNaklDet
@dn bigint
AS
BEGIN

DECLARE @RefDatnom INT
if object_id('tempdb..#DatnomList') is not null drop table #DatnomList
create table #DatnomList (datnom bigint)

SET @RefDatnom = (SELECT NC.RefDatnom FROM NC WHERE NC.datnom = @dn AND NC.SP>0) --текущая ко входной


insert into #DatnomList (datnom) 
SELECT @dn --входная
UNION
SELECT IIF(@RefDatnom = 0, @dn, @RefDatnom)  --текущая ко входной, если входная - добивка
UNION 
SELECT DISTINCT NC.DatNom --добивки ко входной, если входная не добивка/остальные добивки, если входная - добивка
  FROM NC WHERE NC.RefDatnom = IIF(@RefDatnom = 0, @dn, @RefDatnom) AND NC.SP>0


select nv.* into #nv_filter from nv JOIN #DatnomList ON NV.DatNom = #DatnomList.datnom

--select * into #nv_filter from nv where datnom=@dn

alter table #nv_filter
drop column nvid

--if dbo.DatNomInDate(@dn)=dbo.today()
begin
	insert into #nv_filter
  select z.datnom,
         -1,
         z.Hitag,
         0,
         0,
         z.Zakaz,
         0,
         z.skladNo,         
         0,
         z.AuthorOP,
         0,
         0,
         0 
  from nvZakaz z
  where datnom=@dn
  			and done=0
end

declare @sql varchar(max)
set @sql=''
set @sql=@sql+'select * from (
  select cast(d.brinn as varchar(12)) [brinn], nv.datnom, nv.Hitag, nv.tekid,
         n.name, nv.Price, nv.cost, nv.Kol, nv.Kol_B, units.UnitName,
         nv.kol * IIF(nv.unid=1, 1, isnull(UnitConv.k, n.netto)) ves,
  			 ve.fam, isnull(pr.ProducerName,t.Country) Country,t.sert_id,
  			 nv.Sklad,nv.OrigPrice, 
  			 nv.ag_id,d.pin,d.gpName,
         iif(c.B_ID =  57990, ''Воронежская область, г. Воронеж, ул.45 Стрелковой дивизии, 234'', d.gpAddr) as gpAddr,
         m.Marsh,
         case when patindex(c.StfNom, c.RemarkOp)<>0 then c.RemarkOp else isnull(c.StfNom,'''')+'' ''+isnull(c.RemarkOP,'''') end [RemarkOP],
  			 IIF(c.Stip=4 AND DefContract.DCK<>45004, ISNULL(def.brName, ''''), f.OurName) AS OurName,
         count(p.sert_id) as Pics,
         case when count(p.sert_id)=0 then 0 else 1 end as Mrk,
         0 ordNum,
         case when SertifNomenVetCat.IdCat<>-1 then nv.kol * IIF(nv.unid=1, 1, isnull(UnitConv.k, n.netto)) else 0 end [vetves]
	from #nv_filter [nv] --nv 
	left join '
  
set @sql=@sql+ (case when dbo.DatNomInDate(@dn)=dbo.today() then ' tdvi ' else ' visual ' end)

set @sql=@sql+'
     			t on t.ID=nv.tekID
  left join vendors ve on t.ncod=ve.ncod 
  left join nomen n on n.hitag=nv.hitag 
  left join Gr g on g.ngrp=n.ngrp
  left join nc c on c.datnom=nv.datnom
  left join def d on c.b_id=d.pin and d.tip=1
  left join FirmsConfig f on c.OurID=f.Our_id
  left join SertifPic P on P.sert_id=t.sert_id
  left join producer pr on pr.ProducerID=t.ProducerID
  LEFT JOIN SertifNomenVetCat ON n.hitag = SertifNomenVetCat.Hitag
  LEFT JOIN DefContract ON c.gpOur_ID = DefContract.DCK
  LEFT JOIN Def ON DefContract.pin = Def.pin 
  LEFT JOIN Marsh m ON m.mhID = c.mhID
  LEFT JOIN units on units.unid = nv.unid
  LEFT JOIN UnitConv ON nv.hitag = UnitConv.Hitag 
                    AND UnitConv.unid = nv.unid AND UnitConv.unid2 = 1   --для перевода в кг
	where nv.datnom='+cast(@dn as varchar)+' and nv.kol>0
	group by d.brinn, nv.datnom, nv.Hitag, nv.tekid, 
           n.name, nv.Price, nv.cost, nv.Kol, nv.Kol_B, units.UnitName, UnitConv.k,
  				 ve.fam, t.Country,t.sert_id, nv.unid, n.netto,
  				 nv.Sklad, nv.OrigPrice, nv.ag_id,
  				 d.pin, d.gpName, d.gpAddr, m.Marsh, c.RemarkOP,f.OurName, c.StfNom, pr.ProducerName,g.Vet, SertifNomenVetCat.IdCat,
           c.Stip, def.brName, c.B_ID, DefContract.DCK '
/*
set @sql=@sql+ 
	case when dbo.DatNomInDate(@dn)=dbo.today() then 
	'union 
	select 	cast(0 as varchar(1)),z.datnom,z.Hitag,0,n.name,z.Price,z.cost,z.Zakaz,0,'''','''',0,0,0,z.Price, 
        	'''',0,0,cast(0 as bit),null,null,0,'''','''',0,'''','''',0,0,1,0
	from nvZakaz z
	left join nomen n on n.hitag=z.Hitag
	where z.datnom='+cast(@dn as varchar)+'
				and z.Done=0'
	else '' end
*/
set @sql=@sql+') x order by x.ordNum,x.sklad, x.name' 

print @sql  
exec(@sql)     

DROP TABLE #nv_filter
DROP TABLE #DatnomList

END