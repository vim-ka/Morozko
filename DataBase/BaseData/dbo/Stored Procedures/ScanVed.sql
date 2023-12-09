CREATE PROCEDURE dbo.ScanVed @DateStart datetime, @DateEnd datetime
AS
BEGIN
declare
@n1 int,
@n2 int
set @n1 = dbo.InDatNom(1, @DateStart)
set @n2 = dbo.InDatNom(9999, @DateEnd)
 create Table #TmpTable(NNak int,upKols float,ND datetime,Marsh int,
                       weight float);
 create Table #Tmp2(mhid int,ND datetime,Marsh int,Weight float,
                    CNNak float,upKols float,CWork int);

                       
insert into #TmpTable(NNak, ND, Marsh, upKols, Weight)
/*select nc.DatNom as cNNak,
       nc.ND,
       Marsh,
       sum(D.Upak)as upKols,
       sum(kol*D.Ves)as WW
from nc cross apply
    (select DatNom,A.Brutto,kol,      
       case
         when A.MinP = 1 then kol
         else kol / A.MinP*1.0
       end as Upak,
       case
          when A.Brutto = 0 and (select weight from tdvi where id=nv.tekid)>0 then (select weight from tdvi where id=nv.tekid)
          when A.Brutto = 0 and (select weight from tdvi where id=nv.tekid) = 0 then (select weight from Visual where id=nv.tekid)
          when A.Brutto > 0 then A.Brutto
       end as Ves
    from NV 
      cross apply (select MinP,hitag,case when Brutto>=Netto then brutto
                                                             else netto end as Brutto 
                   from Nomen where hitag=nv.hitag) A  
    where nv.DatNom=nc.DatNom) D
               
where nd>=@DateStart and nd<=@DateEnd and Marsh > 0 and Sp > 0
group by ND, Marsh, nc.DatNom*/

select 
nc.DatNom as cNNak,
nc.ND,
nc.Marsh,
sum(nv.kol / nomen.minp) as upKols,
sum(nv.kol * 
case
	when tdvi.[WEIGHT] > 0 then tdvi.[WEIGHT]
  when Visual.[weight] > 0 then Visual.[weight]
  when (isnull(nomen.Brutto, 0) = 0) then nomen.netto
  else nomen.Brutto
end) as WW
from nc 
inner join nv on NV.datnom = nc.datnom
inner join nomen on nomen.hitag = nv.hitag
left join tdvi on tdvi.id = nv.tekid
left join visual on visual.id = nv.tekid
where 
nc.DatNom between @n1 and @n2
and nc.Marsh > 0 and nc.Sp > 0
group by nc.ND, nc.Marsh, nc.DatNom

insert into #Tmp2 (mhid,ND,Marsh ,Weight, CNNak,upKols,CWork)
select m.mhid, m.ND, m.Marsh, Sum(tb.weight) as Weight,
       count(tb.NNak)*1.0 as CNNak, Sum(tb.upKols) as upKols,isnull(C.CWork, 1)
from Marsh m
     left join #tmpTable tb on tb.Nd=m.nd and tb.marsh=m.marsh
     left join (select Count(distinct spk) as CWork, mhid as ID from ScanSklad where trID in (16,18) and mhid in
                      (select mhid from marsh where nd>=@DateStart and nd<=@DateEnd and WEIGHT>0) group by mhid)C on C.id=m.mhid 
where m.nd>=@DateStart and m.nd<=@DateEnd and m.WEIGHT>0 
group by m.mhid,m.ND,m.Marsh,C.CWork

 
select t.spk, t.Fio, round(sum(t.Weight),2) as Weight , sum(t.nnak) as nnak, round(sum(t.upKols),2) as upKols, count(t.mhid) as QtyMarsh, sum(t.tim) as tim, t.tName
from
(select msm.spk, sp.Fio, tm.Weight, round(tm.CNNak*1.0,2) as nnak,
       tm.upKols, tm.mhid,
       case when (datediff(mi,msm.tmStart, msm.tmEnd)) < 0 then (1440+datediff(mi,msm.tmStart, msm.tmEnd))
                                                           else (datediff(mi,msm.tmStart, msm.tmEnd)) end as tim,
       s.tName                                                    
from ScanSklad msm left join SkladPersonal sp on sp.spk=msm.spk
                   cross apply (select mhid,
                                case when msm.trID in (16,18) then Weight/CWork else Weight end as Weight,
                                case when msm.trID in (16,18) then CNNak/CWork else CNnak end as CNNak,
                                case when msm.trID in (16,18) then upKols/CWork else upKols end as upKols,
                                 ND,Marsh from #tmp2) tm 
                   left join trades s on msm.trID=s.trID
where tm.mhid=msm.mhid                    
) t                    

group by t.spk, t.Fio,  t.tName
order by t.tName, t.Fio

END