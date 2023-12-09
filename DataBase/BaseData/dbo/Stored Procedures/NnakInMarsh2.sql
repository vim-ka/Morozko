CREATE PROCEDURE dbo.NnakInMarsh2 @ND datetime
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
create Table #TmpTable(Marsh int,reg_id varchar(5),Printed int,Done int,
                       NNak int, B_id int,brname varchar(100),Weight float,
                       Addr varchar(100),Remark varChar(100),Sp float,
                       Nac float,NomZ int,Ag_Id int,InMarsh bit, MarshOld int,
                       Tomorrow bit, tmPost varchar(20),DepId int, TimeArrival varchar(5),
                       DatNom int,DelivCancel bit,wFish float,wIce float,wBak float,
                       wOther float)
                       
create table #tmp2(spBack float,wBack float,refDatNom int)
create table #dCancel(DNom int,dCancel int)

insert into #TmpTable(Marsh,reg_id,Printed,Done,NNak, B_id,brname,Weight,
                       Addr,Remark,Sp,Nac,NomZ,Ag_Id,InMarsh, MarshOld,
                       Tomorrow,tmPost,DepId,TimeArrival,DatNom,DelivCancel,
                       wFish,wIce,wBak,wOther)
select Marsh,A.reg_id,Printed,Done,dbo.InNnak(nc.DatNom)as NNak,
       B_id,A.gpName as brname,IsNull(Sum(D.AllW+D.AllW2+D.AllW3+D.AllW4),0) as Weight,
       A.GpAddr as Addr,Remark,
       nc.Sp,nc.Sp-Sc as Nac,Marsh2 as NomZ,A.brAg_id as Ag_Id,
       case
         when nc.Marsh=0 then  cast('false' as bit)
         else  cast('true' as bit)
       end as InMarsh, 0 as MarshOld,Tomorrow, 'до '+A.tmPost as tmPost,
       A.DepId, TimeArrival,nc.DatNom,DelivCancel,Sum(D.AllW),Sum(D.AllW2),
       Sum(D.AllW3),Sum(D.AllW4)
from NC  nc
left join
(select pin,gpName,reg_id,gpAddr,brAg_id,TmPost,F.DepId from Def
  left join
  (select Ag_Id,sv.DepId from Agents ag,SuperVis sv
   where ag.Sv_id=sv.Sv_id)F on F.Ag_Id=brAg_id
where tip=1)A on A.pin=nc.B_id
 left join
    (select nv.DatNom,
      /*   CASE
          when IsNull(B.Weight,0)=0 then Sum(Kol*C.Netto)+Sum(Kol*IsNull(D.Weight,0))
          else Sum(Kol*IsNull(B.Weight,0))+Sum(Kol*C.Netto)
        end as AllW*/
        case 
           when Sl.Skg in (7,15) and (IsNull(B.Weight,0)=0) then  
                                                Sum(Kol*C.Netto)+Sum(Kol*IsNull(D.Weight,0))
           when Sl.Skg in (7,15) and (IsNull(B.Weight,0)<>0) then  
                                                Sum(Kol*IsNull(B.Weight,0))+Sum(Kol*C.Netto)
          -- else 0
         end as AllW,
         case 
           when Sl.Skg in (3) and (IsNull(B.Weight,0)=0) then  
                                                Sum(Kol*C.Netto)+Sum(Kol*IsNull(D.Weight,0))
           when Sl.Skg in (3) and (IsNull(B.Weight,0)<>0) then  
                                                Sum(Kol*IsNull(B.Weight,0))+Sum(Kol*C.Netto)
           --else 0
         end as Allw2,
         case
           when Sl.Skg in (16,12,11) and (IsNull(B.Weight,0)=0) then  
                                                Sum(Kol*C.Netto)+Sum(Kol*IsNull(D.Weight,0))
           when Sl.Skg in (16,12,11) and (IsNull(B.Weight,0)<>0) then  
                                                Sum(Kol*IsNull(B.Weight,0))+Sum(Kol*C.Netto)
           --else 0
         end as AllW3,
         case
           when Sl.Skg not in (16,12,11,3,7,15) and (IsNull(B.Weight,0)=0) then  
                                                Sum(Kol*C.Netto)+Sum(Kol*IsNull(D.Weight,0))
           when Sl.Skg not in (16,12,11,3,7,15) and (IsNull(B.Weight,0)<>0) then  
                                                Sum(Kol*IsNull(B.Weight,0))+Sum(Kol*C.Netto)
           --else 0
         end as AllW4
    from NV
    join
    (select DatNom from NC
    where ND=@ND)A on A.datnom=nv.DatNom
    left join
    (select id,weight from tdvi)B on B.id=TekId
    left join
    (select id,weight from Visual)D on D.id=TekId
    left join
    (select SkladNo,skg
     from SkladList)Sl on Sl.SkladNo=nv.Sklad
    left join
    (select case
              when Brutto>=Netto then brutto
              else netto
            end as Netto,hitag from Nomen)C on C.hitag=nv.hitag
    group by nv.DatNom,B.Weight,Sl.Skg )D on D.DatNom=nc.DatNom 
where ND=@ND and Sp>0
group by Marsh,A.reg_id,Printed,Done,nc.DatNom,
       B_id,A.gpName,A.GpAddr,Remark,nc.Sp,nc.Sc,Marsh2,A.brAg_id,
       Tomorrow, A.tmPost,A.DepId, TimeArrival,DelivCancel
order by Marsh,Marsh2,nc.DatNom

--insert into #tmp2(refDatNom,wBack,spBack)
select refDatNom,ISNULL(Sum(G.Allw),0) as Allw,(sp)
from NC
left join
 (select nv.DatNom,Sum(Kol*C.Netto)+Sum(Kol*IsNull(D.Weight,0))+Sum(Kol*IsNull(B.Weight,0))
    /*CASE
      
      when IsNull(B.Weight,0)=0 then Sum(Kol*C.Netto)+Sum(Kol*IsNull(D.Weight,0))
      else Sum(Kol*IsNull(B.Weight,0))+Sum(Kol*C.Netto)
    end*/ as AllW
  from NV
  left join
  (select id,weight from tdvi)B on B.id=TekId
  left join
  (select id,weight from Visual)D on D.id=TekId
  left join
  (select case
            when Brutto>=Netto then brutto
            else netto
          end as Netto,hitag from Nomen)C on C.hitag=nv.hitag
  group by DatNom--,B.Weight
 )G on G.DatNom=nc.datnom
 where ND>@Nd and refDatNom in (select DatNom from NC where Nd=@Nd)
 group by refDatNom,sp
/* 
insert into  #dCancel(DNom ,dCancel)
select datnom,Count(DelivCancel)
from NV
where delivcancel=1 and  datnom in (select datnom from NC where nd=@ND)
group by datnom

select Marsh,reg_id,Printed,Done,NNak, B_id,brname,Weight,
       Addr,Remark,Sp,Nac,NomZ,Ag_Id,InMarsh, MarshOld,
       Tomorrow,tmPost,DepId,TimeArrival,DatNom,DelivCancel,
       A.wBack,A.spBack,@Nd as ND,IsNull(B.dCancel,0) as dCancel,
       wFish,wIce,wBak,wOther
from #TmpTable
left join #Tmp2 A on A.refDatNom=DatNom
left join #dCancel B on B.DNom=#TmpTable.datNom
/* group by Marsh,reg_id,Printed,Done,NNak, B_id,brname,Weight,
         Addr,Remark,Sp,Nac,NomZ,Ag_Id,InMarsh, MarshOld,
         Tomorrow,tmPost,DepId,TimeArrival,DatNom,DelivCancel*/*/
END