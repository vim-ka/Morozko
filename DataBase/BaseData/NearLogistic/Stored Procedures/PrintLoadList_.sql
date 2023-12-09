CREATE PROCEDURE [NearLogistic].PrintLoadList_ 
@mhID int
AS
BEGIN
declare @nd datetime
declare @marsh int 

select @nd=nd,@marsh=marsh from dbo.marsh where mhid=@mhID

if object_id('tempdb..#tempNV') is not null drop table #tempNV

select g.ngrp, 
    dbo.GetGrOnlyParent(g.NGRP) as Parent 
into #tempGr 
from Gr g 

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
      union 
      select 0,v.datnom,v.hitag,v.skladno,v.Zakaz,-1
      from dbo.nvzakaz v 
      join nearlogistic.marshrequests mr on mr.reqid=v.datnom and mr.reqtype=0
      where mr.mhid=@mhid and v.done=0
) x

select * 
into #tempNV
from (

select v.datnom,
    case when e.flgweight=0 then v.kol
           when e.netto=0 and e.flgweight=1 then v.kol
            when e.flgweight=1 and isnull(d.weight,b.weight)*v.kol<e.netto then 1
            when e.flgweight=1 and abs(isnull(d.weight,b.weight)*v.kol % e.netto - e.netto) <= e.netto*0.05 then ceiling(isnull(d.weight,b.weight)*v.kol / e.netto)
            else round(isnull(d.weight,b.weight)*v.kol / e.netto, 0) end [kol],
    --iif(e.flgWeight=1,iif(e.netto=0,v.kol,iif((isnull(d.weight,b.weight)*v.kol) < e.netto,1,iif(isnull(d.weight,b.weight)*v.kol) / e.netto % e.netto - e.netto))), v.kol) [kol],
       v.hitag,
       v.sklad,
       e.minp,
       e.name,
       v.kol*1.0/e.minp [KolBox],
       e.netto,
       case when e.flgweight=0 or v.tekid=-1 then e.netto*v.kol
          when b.weight<>0 then v.kol*isnull(b.weight,0)
           else v.kol*isnull(d.weight,0) end [allw],
       case when e.flgweight=1 and (isnull(b.weight,0)>0) then b.weight
           when e.flgweight=1 and (isnull(d.weight,0)>0) then d.weight
            when e.flgweight=1 and v.tekid=-1 then e.netto 
           else 0 end [Ves],
       iif(t.parent=85 or e.ngrp=96 or e.ngrp=101 or e.ngrp=85,1,0) as Kolb,
       0 [reqtype],
       iif(v.tekid=-1,'не набрано','') [type],
       e.flgweight
from #tmp v
left join (select id, weight from dbo.tdvi) b on b.id=TekId
left join (select id, weight from dbo.visual) d on d.id=TekId
join (select n.ngrp,n.hitag,n.name,case when n.brutto>=n.netto then n.brutto else n.netto end [Netto],n.minp,n.flgWeight from dbo.nomen n) e on e.hitag=v.hitag
left join gr t on e.ngrp=t.ngrp       
      
union all 

select mr.ReqID,
       1,
       z.Nom,
       z.skladno,
       1,
       z.Nname+', ['+cast(z.InvNom as varchar)+','+cast(z.FabNom as varchar)+']',
       1,
       fm.Weight,
       fm.Weight,
       fm.Weight,
       0,
       1,
       '',
       0
from [NearLogistic].MarshRequests mr
join dbo.frizrequestinvnom i on mr.ReqID=i.frizreqid
join dbo.frizer z on z.nom=i.frizernom 
join dbo.FrizerModel fm on fm.FMod=z.FMod
 where mr.mhID=@mhid
       and mr.ReqType=2  
       and mr.ReqAction=1     
      
) x

--Погрузочная ведомость
select B_id,
       iif(a.master=43849,'<b>'+gpName+' </b>',gpName) [gpName],
       (case when isnull(nc.stfnom,'')='' then  cast(dbo.InNnak(nc.DatNom) as varchar) else nc.stfnom+'('+cast(dbo.InNnak(nc.DatNom) as varchar)+')' end) as NNak,
       mr.ReqOrder Marsh2,
       C.Sklad,
       C.hitag,
       case
          when C.Ves<>0 then C.Name+' '+cast(Cast(ROUND(C.Ves,2) as float) as varchar)+'кг'
          else C.Name
       end as Name,
       case 
          when (C.kol % C.MinP)=0 and c.flgweight<>1 then Cast(Cast(C.kol/C.MinP  as int) as Varchar)
          when (C.kol % C.MinP)>0 and c.flgweight<>1 and (Cast(C.kol/C.MinP as int)=0) then 
              '+'+Cast(Cast(C.kol%C.MinP as int) as Varchar)
          when (C.kol % C.MinP)>0 and c.flgweight<>1 then 
             Cast(Cast(C.kol/C.MinP as int) as Varchar)+' +'+
             Cast(Cast(C.kol%C.MinP as int) as Varchar)
          when c.flgweight=1 then cast(cast(c.kol as int) as varchar)         
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
       '16'+format(@nd,'ddMMyy')+right('000'+cast(@marsh as varchar),4) [barcode],
       c.[type],
       0 [casher_id]
from Nc 
left join Def A on A.pin=B_id
inner join NearLogistic.MarshRequests mr on mr.ReqID=nc.datnom and mr.ReqType=0
inner join #tempNV C on c.datnom=nc.datnom and c.reqtype=0

union all

select mr.PINTo,
       gpName,
    cast(mr.reqid as varchar),
       mr.ReqOrder Marsh2,
       C.Sklad,
       C.hitag,
       C.Name,
       cast(c.kol as varchar) as Kols,
       C.MinP,
       C.Netto,
       C.KolBox,
       C.Allw,
       A.PosX,
       A.PosY,
       C.kol % C.MinP as Gds,
       A.Fmt,
       iif(C.Kolb=1, C.Allw,0) as KolbW,
       '16'+format(@nd,'ddMMyy')+right('000'+cast(@marsh as varchar),4) [barcode],
       c.[type],
       0 [casher_id]
from NearLogistic.MarshRequests mr 
left join Def A on A.pin=mr.pinto
inner join #tempNV C on c.datnom=mr.ReqID and c.reqtype=1

union all

select p.point_id,
       p.point_name+char(13)+p.point_adress,
    cast(mr.reqid as varchar),
       mr.ReqOrder Marsh2,
       0,
       0,
       'сторонний груз',
       str(f.kolbox,3,1)+' кор' Kols,
       0,
       0,
       f.kolbox,
       f.weight,
       p.PosX,
       p.PosY,
       0 [Gds],
       0,
       0 [KolbW],
       '' [barcode],
       '',
       f.pin [casher_id]
from NearLogistic.MarshRequests mr 
join NearLogistic.MarshRequests_free f on f.mrfid=mr.reqid
join nearlogistic.marshrequestsdet d on d.mrfid=f.mrfid and d.action_id=6
join nearlogistic.marshrequests_points p on p.point_id=d.point_id 
where mr.mhid=@mhid and mr.ReqType=-2

order by Marsh2 desc,NNak,c.[type],Sklad,Name
drop table #tempNV
if object_id('tempdb..#tmp') is not null drop table #tmp
END