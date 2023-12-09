CREATE PROCEDURE [NearLogistic].PrintLoadList @ND datetime, @Marsh int
AS
BEGIN

declare @datnom1 int, @datnom2 int

set @datnom1= dbo.InDatNom(0,@ND)
set @datnom2= dbo.InDatNom(9999,@ND)

select g.ngrp, dbo.GetGrOnlyParent(g.NGRP) as Parent into #tempGr from Gr g 

--Погрузочная ведомость
select B_id,
       gpName,
       (case when isnull(nc.stfnom,'')='' then  cast(dbo.InNnak(nc.DatNom) as varchar) else nc.stfnom end) as NNak,
       Marsh2,
       C.Sklad,
       C.hitag,
       case
          when C.Ves<>0 then C.Name+' '+cast(Cast(ROUND(C.Ves,2) as float) as varchar)+'кг'
          else C.Name
       end as Name,
       case 
          when (C.kol % C.MinP)=0 then Cast(Cast(C.kol/C.MinP  as int) as Varchar)
          when (C.kol % C.MinP)>0 and (Cast(C.kol/C.MinP as int)=0) then 
              '+'+Cast(Cast(C.kol%C.MinP as int) as Varchar)
          when (C.kol % C.MinP)>0 then 
             Cast(Cast(C.kol/C.MinP as int) as Varchar)+' +'+
             Cast(Cast(C.kol%C.MinP as int) as Varchar)         
       end as Kol,
       C.MinP,
       C.Netto,
       C.KolBox,
       C.Allw,
       A.PosX,
       A.PosY,
       C.kol % C.MinP as Gds,
       A.Fmt,
       iif(C.Kolb=1, C.Allw,0) as KolbW 
from Nc left join Def A on A.pin=B_id
        left join
       (select DatNom,Kol,nv.hitag,sklad,E.MinP,E.Name,
        Kol*1.0/E.MinP as KolBox,E.Netto,
        case
          when E.flgWeight=0 then E.Netto*Kol
          when B.Weight<>0 then Kol*IsNull(B.Weight,0)
          else Kol*IsNull(D.Weight,0)
          /*when (B.Weight=0) then
             Kol*IsNull(B.Weight,0)+Kol*IsNull(E.Netto,0)
          else Kol*IsNull(D.Weight,0)+Kol*IsNull(E.Netto,0)  */
        end as AllW,
        case
          when E.flgWeight=1 and (IsNull(B.Weight,0)>0) then B.Weight
          when E.flgWeight=1 and (IsNull(D.Weight,0)>0) then D.Weight
          else 0
        end as Ves,
        iif(t.Parent=85 or e.ngrp=96 or e.ngrp=101 or e.ngrp=85,1,0) as Kolb
       from NV
       left join (select id, weight from tdvi) B on B.id=TekId
       left join (select id, weight from Visual) D on D.id=TekId
       left join (select ngrp, hitag,Name,case
                  when Brutto>=Netto then brutto
                  else netto
                  end as Netto,MinP, flgWeight from Nomen)E on E.hitag=nv.hitag
       left join #tempGr t on E.Ngrp=t.Ngrp
                  
       where nv.kol>0) C on C.DatNom=nc.DatNom

where nc.datnom>=@Datnom1 and nc.datnom<=@Datnom2 and Marsh=@Marsh  and exists(select v.nvid from nv v where v.datnom=nc.datnom and v.kol>0)
order by Marsh2 desc,NNak,Sklad,Name

END