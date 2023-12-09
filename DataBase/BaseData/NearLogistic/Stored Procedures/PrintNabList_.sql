CREATE PROCEDURE NearLogistic.PrintNabList_ 
@mhid int
--,@skg int
AS
BEGIN
if object_id('tempdb..#tempNV') is not null drop table #tempNV
if object_id('tempdb..#tempNCPalletNom') is not null drop table #tempNCPalletNom

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

select *
into #tempNV
from (
/*select v.Sklad,
       v.DatNom,
       v.hitag,
       E.Name,
       E.Netto,
       E.MinP,
       case when E.flgWeight=1 and (IsNull(B.Weight,0)>0) then IsNull(B.Weight,0)
       when E.flgWeight=1 and (IsNull(D.Weight,0)>0) then IsNull(D.Weight,0) 
       else 0 end as [Ves], 
       v.Kol,
       0 as ReqType
from NV v 
inner join NearLogistic.MarshRequests mr on mr.ReqID=v.DatNom and mr.ReqType=0
left join tdvi B on B.id=v.TekId
left join Visual D on D.id=v.TekId
left join (select hitag,Name,case when Brutto>=Netto then brutto else Netto end as Netto,MinP,flgWeight from Nomen) E on E.hitag=v.hitag   
where v.kol>0 
      and mr.mhID=@mhid*/
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
       --iif(e.flgWeight=1,iif(e.netto=0,v.kol,isnull(d.weight,b.weight) / e.netto), v.kol) [kol],
       0 [reqtype],
       isnull(b.dater,d.dater) [dater]
from #tmp v
left join (select id, weight, dater from dbo.tdvi) b on b.id=TekId
left join (select id, weight, dater from dbo.visual) d on d.id=TekId
join (select n.ngrp,n.hitag,n.name,case when n.brutto>=n.netto then n.brutto else n.netto end [Netto],n.minp,n.flgWeight from dbo.nomen n) e on e.hitag=v.hitag      
      
union all

select z.SkladNo,
       mr.ReqID,
       z.Nom,
       z.Nname+', ['+cast(z.InvNom as varchar)+','+cast(z.FabNom as varchar)+']',
       fm.Weight,
       fm.VolumeBox,
       fm.Weight, 
       1,
       1,
       z.DatePost
from [NearLogistic].MarshRequests mr
join dbo.frizrequestinvnom i on mr.ReqID=i.frizreqid
join dbo.frizer z on z.nom=i.frizernom 
join dbo.FrizerModel fm on fm.FMod=z.FMod
 where mr.mhID=@mhid
       and mr.ReqType=2  
       and mr.ReqAction=1            
      
) x

select pn.* 
into #tempNCPalletNom
from NcPalletNom pn
inner join #tempNV v on pn.datnom=v.datnom and v.reqtype=0
inner join SkladList sl on sl.SkladNo=v.Sklad
where pn.skg=sl.Skg       

select  @mhid [@mhid],
    Marsh2,
        IsNull(np.PalletNo,0) as PalletNo,
        B.Skg [@skg],
        B.Skg,
     B.SkgName,
        f.Sklad,
        F.Hitag,
        case
          when F.Ves<>0 then F.NAme+' '+cast(Cast(ROUND(F.Ves,2) as float) as varchar)+'кг'
          else F.NAme
        end as Name,
        case  
           when F.MinP=1 then F.kol
           else F.kol / F.MinP*1.0
        end as Upak,
        case
          when (F.kol % F.MinP*1.0)=0 then Cast(Cast(F.kol/F.MinP as int) as Varchar)
          when (F.kol % F.MinP)>0 and (Cast(F.kol/F.MinP as int)=0) then 
              '+'+Cast(Cast(F.kol*1.0%F.MinP as int) as varchar)
          when (F.kol % F.MinP)>0 then 
             Cast(Cast(F.kol/F.MinP as int) as varchar)+'+'+
             Cast(Cast(F.kol%f.MinP as int) as varchar)         
         end as Kols,
         F.MinP,
         case
           when F.Ves>0 then (F.Ves*F.kol)
           when F.Netto>0 then (F.kol*F.Netto)
         end as weight,S.gpName,
         --S.reg_id, 
         R.SkladReg as reg_id,
         dbo.InNnak(nc.datNom)as NNak,
                 
         case when isnull(nc.stfnom,'')=''
              then cast(dbo.InNNak(nc.datnom) as varchar)
              else nc.stfnom+' ('+cast(dbo.InNNak(nc.datnom) as varchar)+')' end as NNakStr,
         nc.Printed,
         nc.Datnom,
         case
           when IsNull(np.PalletNo,0)=0 then '0'
           when IsNull(np.PalletNo,0)=IsNull(np2.PalletNo,0) then cast(IsNull(np.PalletNo,0)as varchar)
           else cast(IsNull(np2.PalletNo,0)as varchar)+'-'+cast(IsNull(np.PalletNo,0)as varchar)
         end as sPalNo,
         iif(a.depid=3,4,S.Fmt) [fmt],
         S.gpAddr,
         f.Datnom,
         F.Sklad,
         F.Name,
         s.pin,
         f.dater,
         '10'+format([nc].nd,'ddMMyy')+format(nc.datnom%10000,'0000') [barcode]       
from NC 
join Def S on S.pin=nc.B_id
inner join #tempNV F on f.datnom=nc.datnom and f.reqtype=0
left join (select SkladNo,sl.Skg,sg.skgName from SkladList sl join SkladGroups sg on sg.skg=sl.skg)B on B.SkladNo=F.Sklad
left join (select distinct datNom,PalletNo,Skg from #tempNcPalletNom n where pnId =(select max(pnId) from #tempNcPalletNom where datNom=n.datNom and Skg=n.Skg))Np on Np.DatNom=nc.DatNom and Np.skg=B.skg
left join (select distinct datNom,PalletNo,Skg from #tempNcPalletNom n where pnId =(select min(pnId) from #tempNcPalletNom where datNom=n.datNom and Skg=n.Skg))Np2 on Np2.DatNom=nc.DatNom and Np2.skg=B.skg
left join [dbo].Regions R on R.reg_id=S.reg_id 
left join dbo.defcontract dc on dc.dck=nc.dck
left join dbo.agentlist a on a.ag_id=dc.ag_id

union all

select  @mhid [@mhid],
    [nc].ReqOrder [Marsh2],
        0 as PalletNo,
        B.Skg [@skg],
        B.Skg,
     B.SkgName,
        f.Sklad,
        F.Hitag,
        F.NAme,
        F.kol as Upak,
        cast(f.kol as varchar) as Kols,
        F.MinP*1.0,
        F.Ves as weight,
        S.gpName,
        R.SkladReg as reg_id,
        dbo.InNnak(f.datnom),                 
        cast(dbo.InNnak(f.datnom) as varchar) as NNakStr,
        0,
        f.datnom,
        '' as sPalNo,
        S.Fmt,
        S.gpAddr,
        f.Datnom,
        F.Sklad,
        F.Name,
        s.pin,
        f.dater,
        '0'       
from NearLogistic.MarshRequests [nc] 
join Def S on S.pin=[nc].PINTo
inner join #tempNV F on f.datnom=nc.reqid and f.reqtype=1
left join (select SkladNo,sl.Skg,sg.skgName from SkladList sl join SkladGroups sg on sg.skg=sl.skg)B on B.SkladNo=F.Sklad
left join [dbo].Regions R on R.reg_id=S.reg_id 

order by 2 desc,f.Datnom,F.Sklad,3,F.Name
 
drop table #tempNV
drop table #tempNCPalletNom
if object_id('tempdb..#tmp') is not null drop table #tmp
END