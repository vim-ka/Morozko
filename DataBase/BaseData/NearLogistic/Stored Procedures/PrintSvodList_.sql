﻿
CREATE PROCEDURE NearLogistic.PrintSvodList_
@mhID int
--,@skg int
AS
BEGIN
if object_id('tempdb..#tempNV') is not null drop table #tempNV
  
create table #tempNV (sklad int,
                      datnom Bigint,
                      hitag int,
                      [name] varchar(90),
                      netto decimal(10,3),
                      minp int,
                      [ves] decimal(10,2),
                      kol int,
                      volminp float,
                      ReqType int)
/*insert into #tempNV
select v.Sklad,
       v.DatNom,
       v.hitag,
       E.Name,
       E.Netto,
       E.MinP,
       case when E.flgWeight=1 and (IsNull(B.Weight,0)>0) then IsNull(B.Weight,0)
       when E.flgWeight=1 and (IsNull(D.Weight,0)>0) then IsNull(D.Weight,0) 
       else 0 end as [Ves], 
       v.Kol,
       e.volminp,
       0
 from NV v 
 inner join NearLogistic.MarshRequests mr on mr.ReqID=v.DatNom
 left join tdvi B on B.id=v.TekId
 left join Visual D on D.id=v.TekId
 left join (select hitag,volminp,Name,case when Brutto>=Netto then brutto else Netto end as Netto,MinP,flgWeight from Nomen) E on E.hitag=v.hitag   
 where v.kol>0 
       and mr.mhID=@mhid
       and mr.ReqType=0*/
       
if object_id('tempdb..#tmp') is not null drop table #tmp
select * into #tmp from 
(   
      select v.nvid,v.datnom,v.hitag,v.sklad,v.kol,v.tekid,mr.reqorder
      from dbo.nv v with (index(nv_datnom_idx)) 
      join nearlogistic.marshrequests mr on mr.reqid=v.datnom and mr.reqtype=0
      where mr.mhid=@mhid and v.kol>0
      union 
      select v.nvid,c.refdatnom,v.hitag,v.sklad,v.kol,v.tekid,mr.reqorder
      from dbo.nv v with (index(nv_datnom_idx)) 
      join dbo.nc c on c.datnom=v.datnom
      join nearlogistic.marshrequests mr on mr.reqid=c.refdatnom and mr.reqtype=0
      where mr.mhid=@mhid and v.kol>0 
) x
insert into #tempnv
select v.sklad,
       v.datnom,
    v.hitag,
       e.name,
       e.netto,
       e.minp,
       case when e.flgweight=1 and (isnull(b.weight,0)>0) then b.weight
           when e.flgweight=1 and (isnull(d.weight,0)>0) then d.weight
           else 0 end [Ves],
       v.kol,
       e.volminp,
       0 
from #tmp v
left join (select id, weight from dbo.tdvi) b on b.id=TekId
left join (select id, weight from dbo.visual) d on d.id=TekId
join (select n.ngrp,n.hitag,n.name,case when n.brutto>=n.netto then n.brutto else n.netto end [Netto],n.minp,n.flgWeight,n.volminp from dbo.nomen n) e on e.hitag=v.hitag       

insert into #tempNV       
select z.SkladNo,
       mr.ReqID,
       z.Nom,
       z.Nname+', ['+cast(z.InvNom as varchar)+','+cast(z.FabNom as varchar)+']',
       fm.Weight,
       fm.VolumeBox,
       fm.Weight, 
       1,
       fm.VolumeBox,
       1
from [NearLogistic].MarshRequests mr
join dbo.frizrequestinvnom i on mr.ReqID=i.frizreqid
join dbo.frizer z on z.nom=i.frizernom 
join dbo.FrizerModel fm on fm.FMod=z.FMod
 where mr.mhID=@mhid
       and mr.ReqType=2
       and mr.ReqAction=1         
       
select @mhid [mhid],
    B.Skg,
       B.SkgName,
       f.Sklad,
       F.Hitag,
       case
         when F.Ves<>0 then F.Name+' '+cast(cast(round(F.Ves,2) as float) as varchar)+'кг'
         else F.Name
       end as Name,
       case
         when (sum(F.kol) % F.MinP*1.0)=0 then cast(cast(sum(F.kol)/F.MinP as int) as varchar)
         when (sum(F.kol) % F.MinP)>0 and (Cast(Sum(F.kol)/F.MinP as int)=0) then
             '+'+cast(cast(sum(F.kol)*1.0%F.MinP as int) as varchar)
         when (sum(F.kol) % F.MinP)>0 then 
             cast(cast(sum(F.kol)/F.MinP as int) as varchar)+'+'+
             cast(cast(sum(F.kol)%F.MinP as int) as varchar)             
       end as Kols,
       
       case
         when F.MinP=1 then sum(F.kol)
         else sum(F.kol)*1.0 / F.MinP*1.0
       end as KolUp,
       cast(F.MinP as  integer) as MinP,
       case
         when (IsNull(sum(F.Ves),0)>0) then F.Ves*sum(F.kol)          
         when F.Netto>0 then F.Netto*sum(F.kol)
       end as weight,
       cast(sum(F.Kol) as integer) as sKol,
       F.Netto,
       F.Ves,
       Sklad as SortSklad,
       '0' as PalNo,
       0 as NNak,
       0 as Marsh2,
       round(
        (case
         when MinP = 1 then sum(F.Kol)*F.VolMinP
         else sum(F.Kol) / F.MinP*1.0 *F.VolMinP
       end),4) as VolMinP
 from NC 
inner join #tempNV F on f.datnom=nc.datnom
left join (select SkladNo,sl.Skg,sg.skgName from SkladList sl join SkladGroups sg on sg.skg=sl.skg)B on B.SkladNo=F.Sklad
where f.reqtype=0
group by B.Skg,B.SkgName,f.Sklad,F.Hitag,F.Name,F.Netto,F.Ves,F.MinP,F.VolMinP

union all

select @mhid [mhid],
    B.Skg,
       B.SkgName,
       f.Sklad,
       F.Hitag,
       F.Name,
       cast(sum(f.kol) as varchar) Kols,
       sum(F.kol) KolUp,
       cast(F.MinP as  integer) as MinP,
       sum(F.Ves) weight,
       cast(sum(F.Kol) as integer) as sKol,
       F.Netto,
       F.Ves,
       Sklad as SortSklad,
       '0' as PalNo,
       0 as NNak,
       0 as Marsh2,
       round(f.volminp,4) as VolMinP
from NearLogistic.MarshRequests mr 
inner join #tempNV F on f.datnom=mr.ReqID
left join (select SkladNo,sl.Skg,sg.skgName from SkladList sl join SkladGroups sg on sg.skg=sl.skg)B on B.SkladNo=F.Sklad
where f.reqtype=1
group by B.Skg,B.SkgName,f.Sklad,F.Hitag,F.Name,F.Netto,F.Ves,F.MinP,F.VolMinP

order by 4,6   
  
drop table #tempNV 
END