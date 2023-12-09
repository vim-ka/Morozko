CREATE PROCEDURE dbo.NnakInMarsh @ND datetime with recompile
AS
BEGIN
declare @dn0 int, @dn1 int
set @dn0 = dbo.InDatNom(0000, @nd)
set @dn1 = dbo.InDatNom(9999, @nd)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
create Table #TmpTable(Marsh int,reg_id varchar(5),Printed int,Done int,
                       NNak int, B_id int,brname varchar(100),Weight float,
                       Addr varchar(200),Remark varChar(255),Sp float,
                       Nac float,NomZ int,Ag_Id int,InMarsh bit, MarshOld int,
                       Tomorrow bit, tmPost varchar(20),DepId int, TimeArrival varchar(5),
                       DatNom int,DelivCancel bit,wFish float,wIce float,wBak float,
                       wOther float, wMilk float)
                       
create table #tmp2(spBack float,wBack float,refDatNom int)
create table #dCancel(DNom int,dCancel int)

insert into #TmpTable(Marsh,reg_id,Printed,Done,NNak, B_id,brname,Weight,
                       Addr,Remark,Sp,Nac,NomZ,Ag_Id,InMarsh, MarshOld,
                       Tomorrow,tmPost,DepId,TimeArrival,DatNom,DelivCancel,
                       wFish,wIce,wBak,wOther, wMilk)
select Marsh, A.reg_id, Printed, Done,
       dbo.InNnak(nc.DatNom)as NNak,
       B_id, 
       A.gpName as brname,
       --Sum(IsNull(D.AllW,0)+IsNull(D.AllW2,0)+IsNull(D.AllW3,0)+IsNull(D.AllW4,0)+IsNull(D.AllW5,0)) as Weight,
       [dbo].[GetBruttoWeightNakl](nc.DatNom) as Weight,
       A.GpAddr as Addr,
       nc.Remark,
       nc.Sp,
       nc.Sp-Sc as Nac,
       Marsh2 as NomZ,
       Ag.Ag_id as Ag_Id,
       case
         when nc.Marsh=0 then cast('false' as bit)
                         else cast('true' as bit)end as InMarsh,
       0 as MarshOld, 
       Tomorrow,
       'до '+A.tmPost as tmPost,
       Ag.DepId,
       TimeArrival,
       nc.DatNom,
       DelivCancel,
       Sum(IsNull(D.AllW,0)),
       Sum(IsNull(D.AllW2,0)),
       Sum(IsNull(D.AllW3,0)),
       Sum(IsNull(D.AllW4,0)),
       Sum(IsNull(D.AllW5,0))
from NC left join Def A on A.pin=nc.B_id
        left join DefContract e on nc.dck=e.dck           
        left join Agentlist ag  on ag.Ag_Id=e.Ag_id
        left join
       (select nv.DatNom,
        /*CASE
          when IsNull(B.Weight,0)=0 then Sum(Kol*C.Netto)+Sum(Kol*IsNull(D.Weight,0))
          else Sum(Kol*IsNull(B.Weight,0))+Sum(Kol*C.Netto)
        end as AllW*/
         case when Sl.Skg in (7) then IIF((IsNull(B.Weight,0)=0), Sum(nv.Kol*(case when Brutto>=Netto then brutto else netto end)) + Sum(nv.Kol*IsNull(D.Weight,0)),
                                                                  Sum(nv.Kol*(case when Brutto>=Netto then brutto else netto end)) + Sum(nv.Kol*IsNull(B.Weight,0)) )
         end as AllW,
         
         case when Sl.Skg in (3,29) then IIF((IsNull(B.Weight,0)=0), Sum(nv.Kol*(case when Brutto>=Netto then brutto else netto end)) + Sum(nv.Kol*IsNull(D.Weight,0)),
                                                                     Sum(nv.Kol*(case when Brutto>=Netto then brutto else netto end)) + Sum(nv.Kol*IsNull(B.Weight,0)) ) 
         end as AllW2,
         
         case when Sl.Skg in (11,12,16,17,19) then IIF((IsNull(B.Weight,0)=0), Sum(nv.Kol*(case when Brutto>=Netto then brutto else netto end)) + Sum(nv.Kol*IsNull(D.Weight,0)),
                                                                               Sum(nv.Kol*(case when Brutto>=Netto then brutto else netto end)) + Sum(nv.Kol*IsNull(B.Weight,0)) )
         end as AllW3,
         
         case when Sl.Skg not in (3,5,7,11,12,16,17,19,29,32) then IIF((IsNull(B.Weight,0)=0), Sum(nv.Kol*(case when Brutto>=Netto then brutto else netto end)) + Sum(nv.Kol*IsNull(D.Weight,0)),
                                                                                            Sum(nv.Kol*(case when Brutto>=Netto then brutto else netto end)) + Sum(nv.Kol*IsNull(B.Weight,0)) ) 
         end as AllW4,
         
         case when Sl.Skg in (5,32) then IIF((IsNull(B.Weight,0)=0), Sum(nv.Kol*(case when Brutto>=Netto then brutto else netto end)) + Sum(nv.Kol*IsNull(D.Weight,0)),
                                                                  Sum(nv.Kol*(case when Brutto>=Netto then brutto else netto end)) + Sum(nv.Kol*IsNull(B.Weight,0)) ) 
         end as AllW5
         
    from NV
    join NC on nv.datnom=nc.DatNom
    left join  SkladList Sl on Sl.SkladNo=nv.Sklad
    left join  tdvi B on B.id=TekId
    left join  Visual D on D.id=TekId
    left join  Nomen C on C.hitag=nv.hitag
    
--    where nc.Nd=@ND                   
    where nc.DatNom>=@dn0 and nc.DatNom<=@dn1                   
    group by nv.DatNom,B.Weight,Sl.Skg)D on D.DatNom=nc.DatNom 
              
                
--where nc.ND = @ND 
where nc.DatNom>=@dn0 and nc.DatNom<=@dn1                   
and (nc.Sp > 0 or nc.actn = 1)
group by Marsh,A.reg_id,Printed,Done,nc.DatNom,
       B_id,A.gpName,A.GpAddr,nc.Remark,nc.Sp,nc.Sc,Marsh2,Ag.Ag_id,
       Tomorrow, A.tmPost,Ag.DepId, TimeArrival,DelivCancel
order by Marsh,Marsh2,nc.DatNom

insert into #tmp2(refDatNom,wBack,spBack)
select refDatNom,ISNULL(Sum(G.Allw),0) as Allw, Sum(sp)
from NC
left join (select nv.DatNom,Sum(Kol*(case when C.Brutto>=C.Netto then C.brutto else C.netto end))+Sum(Kol*IsNull(D.Weight,0))+Sum(Kol*IsNull(B.Weight,0))
           --CASE
           --  when IsNull(B.Weight,0)=0 then Sum(Kol*C.Netto)+Sum(Kol*IsNull(D.Weight,0))
           --  else Sum(Kol*IsNull(B.Weight,0))+Sum(Kol*C.Netto)
           -- end 
           as AllW
           from NV  left join tdvi B on B.id=TekId 
                    left join visual D on D.id=TekId 
                    left join Nomen C on C.hitag=nv.hitag 
--          where nv.DatNom in (select datnom from NC where refdatnom in (select DatNom from NC where Nd=@ND))                      
			where nv.DatNom in (select datnom from NC where refdatnom in (select DatNom from NC where nc.DatNom>=@dn0 and nc.DatNom<=@dn1))                      
          group by DatNom--,B.Weight
          )G on G.DatNom=nc.datnom
          
--where ND>@Nd 
where NC.DatNom>=@dn0 
--and refDatNom in (select DatNom from NC where Nd=@Nd)
and refDatNom in (select DatNom from NC where DatNom>=@dn0 and DatNom<=@dn1)
group by refDatNom

insert into  #dCancel(DNom ,dCancel)
select datnom,Count(DelivCancel)
from NV
where NV.DatNom>=@dn0 and NV.DatNom<=@dn1 and delivcancel=1 
group by datnom

select Marsh,reg_id,Printed,Done,NNak, B_id,brname,Weight,
       Addr,Remark,Sp,Nac,NomZ,Ag_Id,InMarsh, MarshOld,
       Tomorrow,tmPost,DepId,TimeArrival,DatNom,DelivCancel,
       A.wBack,A.spBack,@Nd as ND,IsNull(B.dCancel,0) as dCancel,
       wFish,wIce,wBak,wOther,wMilk
from #TmpTable
left join #Tmp2 A on A.refDatNom=DatNom
left join #dCancel B on B.DNom=#TmpTable.datNom
/* group by Marsh,reg_id,Printed,Done,NNak, B_id,brname,Weight,
         Addr,Remark,Sp,Nac,NomZ,Ag_Id,InMarsh, MarshOld,
         Tomorrow,tmPost,DepId,TimeArrival,DatNom,DelivCancel*/
order by Marsh
         
END