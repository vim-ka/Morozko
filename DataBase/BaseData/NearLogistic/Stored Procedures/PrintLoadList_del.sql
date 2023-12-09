CREATE PROCEDURE [NearLogistic].PrintLoadList_del
--@ND datetime, @Marsh int
@mhID int
AS
BEGIN
/*
declare @datnom1 int, @datnom2 int

set @datnom1= dbo.InDatNom(0,@ND)
set @datnom2= dbo.InDatNom(9999,@ND)
*/
if object_id('tempdb..#tempNV') is not null drop table #tempNV

select g.ngrp, 
    dbo.GetGrOnlyParent(g.NGRP) as Parent 
into #tempGr 
from Gr g 
/*
select * 
into #tempNV
from (
select iif(c.refdatnom>0,c.refdatnom,c.datnom) [datnom],
    Kol,
       nv.hitag,
       sklad,
       E.MinP,
       E.Name,
       Kol*1.0/E.MinP as KolBox,
       E.Netto,
       case when E.flgWeight=0 then E.Netto*Kol
          when B.Weight<>0 then Kol*IsNull(B.Weight,0)
           else Kol*IsNull(D.Weight,0) end [AllW],
       case when E.flgWeight=1 and (IsNull(B.Weight,0)>0) then B.Weight
           when E.flgWeight=1 and (IsNull(D.Weight,0)>0) then D.Weight
           else 0 end [Ves],
       iif(t.Parent=85 or e.ngrp=96 or e.ngrp=101 or e.ngrp=85,1,0) as Kolb

from NV
inner join NearLogistic.MarshRequests mr on mr.ReqID=nv.datnom and mr.ReqType=0
left join (select id, weight from tdvi) B on B.id=TekId
left join (select id, weight from Visual) D on D.id=TekId
left join (select ngrp, hitag,Name,case when Brutto>=Netto then brutto else netto end as Netto,MinP, flgWeight from Nomen) E on E.hitag=nv.hitag
join dbo.nc c on c.datnom=nv.datnom
left join #tempGr t on E.Ngrp=t.Ngrp                  
where nv.kol>0
   and mr.mhID=@mhID


) a
*/

if object_id('tempdb..#tmp') is not null drop table #tmp
select * into #tmp from 
(   
      select v.nvid,v.datnom,v.hitag,v.sklad,v.kol,v.tekid
      from dbo.nv v with (index(nv_datnom_idx)) 
      join nearlogistic.marshrequests mr on mr.reqid=v.datnom and mr.reqtype=0
      where mr.mhid=@mhid and v.kol>0
      union 
      select v.nvid,c.refdatnom,v.hitag,v.sklad,v.kol,v.tekid
      from dbo.nv v with (index(nv_datnom_idx)) 
      join dbo.nc c on c.datnom=v.datnom
      join nearlogistic.marshrequests mr on mr.reqid=c.refdatnom and mr.reqtype=0
      where mr.mhid=@mhid and v.kol>0 
) x

select v.datnom [datnom],
    v.kol,
       v.hitag,
       v.sklad,
       e.minp,
       e.name,
       v.kol*1.0/e.minp [KolBox],
       e.netto,
       case when e.flgweight=0 then e.netto*v.kol
          when b.weight<>0 then v.kol*isnull(b.weight,0)
           else v.kol*isnull(d.weight,0) end [allw],
       case when e.flgweight=1 and (isnull(b.weight,0)>0) then b.weight
           when e.flgweight=1 and (isnull(d.weight,0)>0) then d.weight
           else 0 end [Ves],
       iif(t.parent=85 or e.ngrp=96 or e.ngrp=101 or e.ngrp=85,1,0) as Kolb 
into #tempNV       
from #tmp v
left join (select id, weight from dbo.tdvi) b on b.id=TekId
left join (select id, weight from dbo.visual) d on d.id=TekId
join (select n.ngrp,n.hitag,n.name,case when n.brutto>=n.netto then n.brutto else n.netto end [Netto],n.minp,n.flgWeight from dbo.nomen n) e on e.hitag=v.hitag
left join gr t on e.ngrp=t.ngrp 

if object_id('tempdb..#tmp') is not null drop table #tmp


--Погрузочная ведомость
select B_id,
       gpName,
       (case when isnull(nc.stfnom,'')='' then  cast(dbo.InNnak(nc.DatNom) as varchar) else nc.stfnom end) as NNak,
       mr.ReqOrder Marsh2,
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
       iif(C.Kolb=1, C.Allw,0) as KolbW,
       '16'+format(nc.nd,'ddMMyy')+right('000'+cast(nc.marsh as varchar),4) [barcode]
from Nc 
left join Def A on A.pin=B_id
inner join NearLogistic.MarshRequests mr on mr.ReqID=nc.datnom and mr.ReqType=0
inner join #tempNV C on c.datnom=nc.datnom

order by Marsh2 desc,NNak,Sklad,Name
drop table #tempNV
END