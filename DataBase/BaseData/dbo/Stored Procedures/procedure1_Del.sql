

CREATE PROCEDURE dbo.procedure1_Del @ND1 datetime,@ND2 datetime
AS
BEGIN
create Table #TmpTable(NNak int,upKols float,ND datetime,Marsh int,
                       skg int,weight float);
 create Table #Tmp2(mhid int,ND datetime,Marsh int,Weight float,Skg int,
                    CNNak float,upKols float,CWork int);


                       
insert into #TmpTable(NNak,upKols,ND,Marsh,skg,Weight)
select nc.DatNom as cNNak,Sum(D.Upak)as upKols,ND,Marsh,
      D.Skg, Sum(kol*D.Ves)as WW
from NC
join
    (select DatNom,F.Skg,A.Brutto,kol,      
       case  
         when A.MinP=1 then kol
         else kol / A.MinP*1.0
       end as Upak,
       case
          when A.Brutto =0 and  (IsNull(B.Weight,0)>0) then B.Weight
          when A.Brutto =0 and (IsNull(B.Weight,0)=0) then IsNull(D.Weight,0)
          when A.Brutto>0 then A.Brutto
       end as Ves
    from NV 
    left join 
       (select MinP,hitag,case when Brutto>=Netto then brutto
                           else netto end as Brutto 
        from Nomen)A on A.hitag=nv.hitag
    left join
        (select id,weight from tdvi)B on B.id=TekId
    left join
        (select id,weight from Visual)D on D.id=TekId
    left join
    (select skg,SkladNo from SkladList)F on F.SkladNo=nv.Sklad
    )D on D.DatNom=nc.DatNom
where nd>=@ND1 and nd<=@ND2 and Marsh>0 and Sp>0
group by ND,Marsh, D.Skg,nc.DatNom

insert into #Tmp2(mhid,ND,Marsh ,Weight,Skg,CNNak,upKols,CWork)
select m.mhid,m.ND,m.Marsh,Sum(tb.weight)/C.CWork as Weight,tb.Skg,
       Count(tb.NNak)*1.0/C.CWork as CNNak,
         Sum(tb.upKols)/C.CWork as upKols,C.CWork
from Marsh m
left join #tmpTable tb on tb.Nd=m.nd and tb.marsh=m.marsh

left join
     (select Count(uin) as CWork,mhid as ID
      from MarshSkMan
      where uin>0
      group by mhid)C on C.id=m.mhid 
where m.nd>=@ND1 and m.nd<=@ND2 and m.WEIGHT>0 
group by m.mhid,m.ND,m.Marsh,tb.Skg,C.CWork--,tb.NNak
 
select msm.uin,msm.skg,up.Fio ,Sum(tm.Weight) as Weight,Sum(tm.CNNak)*1.0 as nnak,
        Sum(tm.upKols) as upKols,Count(tm.mhid) as cmarsh,A.SkgName
from MarshSkMan msm 
left join usrPwd up on up.uin=msm.uin
join
(select mhid, Weight,Skg,CNNak,upKols,ND,Marsh 
 from #tmp2)tm on tm.mhid=msm.mhid and tm.skg=msm.skg
left join
(select skgName,skg from SkladGroups)A on A.skg=msm.skg
where msm.uin>0
group by msm.uin,msm.skg,up.Fio,A.SkgName
order by up.Fio,msm.uin,A.SkgName
END