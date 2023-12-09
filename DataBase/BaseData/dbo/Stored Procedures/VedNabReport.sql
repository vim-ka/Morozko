CREATE PROCEDURE dbo.VedNabReport @ND1 datetime,@ND2 datetime
AS
BEGIN
declare
@n1 int,
@n2 int
set @n1 = dbo.InDatNom(1, @nd1)
set @n2 = dbo.InDatNom(9999, @nd2)

 create Table #TmpTable(NNak int,upKols float,ND datetime,Marsh int,
                       skg int,weight float);
 create Table #Tmp2(mhid int,ND datetime,Marsh int,Weight float,Skg int,
                    CNNak float,upKols float,CWork int);


                       
insert into #TmpTable(NNak,upKols,ND,Marsh,skg,Weight)
/*select nc.DatNom as cNNak,Sum(D.Upak)as upKols,ND,Marsh,
      D.Skg, Sum(kol*D.Ves)as WW
from NC cross apply
    (select DatNom,F.Skg,A.Brutto,kol,      
       case
         when A.MinP=1 then kol
         else kol / A.MinP*1.0
       end as Upak,
       case
          when A.Brutto = 0 and (IsNull(B.Weight,0)>0) then B.Weight
          when A.Brutto = 0 and (IsNull(B.Weight,0)=0) then IsNull(D.Weight,0)
          when A.Brutto > 0 then A.Brutto
       end as Ves
    from NV 
    cross apply (select MinP,hitag,case when Brutto>=Netto then brutto
                                 else netto end as Brutto 
                 from Nomen where hitag=nv.hitag) A  
    left join (select id,weight from tdvi) B on B.id=nv.TekId
    left join (select id,weight from Visual)D on D.id=nv.TekId  
    left join (select skg,SkladNo from SkladList)F on F.SkladNo=nv.Sklad
               where nv.DatNom=nc.DatNom) D
where nd>=@ND1 and nd<=@ND2 and Marsh>0 and Sp>0
group by ND,Marsh, D.Skg,nc.DatNom*/
select s.cNNak, sum(s.Upak) upKols, s.nd, s.marsh, s.skg, sum(s.kol * s.ves) WW
from
(select
nc.DatNom cNNak,
nv.kol / nomen.minp Upak,
nc.ND,
nc.Marsh,
nv.kol,
(select skg from skladlist where skladno = nv.sklad) skg,
case
	when tdvi.[WEIGHT] > 0 then tdvi.[WEIGHT]
  when Visual.[weight] > 0 then Visual.[weight]
  when (isnull(nomen.Brutto, 0) = 0) then nomen.netto
  else nomen.Brutto
end ves
from
nc
inner join nv on nv.datnom = nc.datnom
inner join nomen on nv.hitag = nomen.hitag
left join tdvi on tdvi.id = nv.tekid
left join visual on visual.id = nv.tekid
where
nc.datnom between @n1 and @n2
and nc.Marsh > 0 
and nc.Sp > 0) s
group by s.cNNak, s.ND, s.Marsh, s.Skg

insert into #Tmp2 (mhid,ND,Marsh ,Weight,tb.Skg,CNNak,upKols,CWork)
select m.mhid,m.ND,m.Marsh,Sum(tb.weight)/C.CWork as Weight,tb.Skg,
       Count(tb.NNak)*1.0/C.CWork as CNNak,
       Sum(tb.upKols)/C.CWork as upKols,C.CWork
from Marsh m
     left join #tmpTable tb on tb.Nd=m.nd and tb.marsh=m.marsh
     left join (select Count(spk) as CWork, mhid as ID,skg from MarshSkMan --where uin>0
                group by mhid,skg)C on C.id=m.mhid and C.Skg=tb.skg
where m.nd>=@ND1 and m.nd<=@ND2 and m.WEIGHT>0 
group by m.mhid,m.ND,m.Marsh,tb.Skg,C.CWork
 
select msm.spk as uin,msm.skg,up.Fio ,Sum(tm.Weight) as Weight,Sum(tm.CNNak)*1.0 as nnak,
        Sum(tm.upKols) as upKols,Count(tm.mhid) as cmarsh,A.SkgName--,
        --sum(sks.tim) as tim
from MarshSkMan msm left join SkladPersonal up on up.spk=msm.spk
                    join (select mhid, Weight,Skg,CNNak,upKols,ND,Marsh 
                         from #tmp2)tm on tm.mhid=msm.mhid and tm.skg=msm.skg
                    left join (select skgName,skg from SkladGroups)A on A.skg=msm.skg
/*left join (select ss.spk, case when (datediff(mi,ss.tmStart, ss.tmEnd)) < 0 then 
        	(1440+datediff(mi,ss.tmStart, ss.tmEnd))
            else (datediff(mi,ss.tmStart, ss.tmEnd)) end tim from ScanSklad ss
            where ss.nd >= @nd1 and ss.nd <= @nd2) sks on sks.spk = msm.spk*/
--where msm.uin>0
group by msm.spk,msm.skg,up.Fio,A.SkgName
order by up.Fio,msm.spk,A.SkgName

END