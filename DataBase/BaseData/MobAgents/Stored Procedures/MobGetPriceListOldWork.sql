

CREATE procedure MobAgents.MobGetPriceListOldWork @ag_id int, @CompName varchar(50)
as
begin
  declare @DepID int, @Sv_id int, @P_ID int, @FirmGroup smallint
  declare @AllPrice bit
  declare @nd datetime
  set @nd=dbo.today()
  select @AllPrice=Merch,@sv_id=sv_ag_id,@DepID=DepID, @P_ID=P_ID from agentlist where ag_id=@ag_id
  select @FirmGroup=FC.FirmGroup from FirmsConfig fc join Person p on fc.Our_id=p.Our_id
  where p.P_ID=@P_ID

  
  select 'g'+cast(g.ngrp as varchar(3)) as code,
         case when (g.parent=0) or (g.parent=90) then ''
                                                 else 'g'+cast(g.parent as varchar(3)) end as parent,
         'g' as tip,
         isnull(r.Prior+' ','')+g.grpname as grpname,
         0 as ostat,
         0 as OstatVes,0 as OstatSP,0 as OstatSC,0 as OnlyMinpSklad,0 as PriceCom, 0 as CostCom,
         0 as minp, /*0 as sklad,*/ '' as Box, '' as PriorP, '' as Newt,-- 0 as MainExtra, 0 as Extra,
         '' as Izm, 0 as MinPrice, 0 as BasePrice, 0 as MaxPrice, 0 as NDS
  from GR g left join GRPrior r on g.ngrp=r.ngrp and r.DepID=@DepID
            join 
            (
             select distinct r.ngrp, r.mainparent, r.parent
             from tdvi v left join skladlist s on v.sklad=s.skladNo
              left join nomen n on v.hitag=n.hitag                                
              left join gr r on n.ngrp=r.ngrp
              left join SkladGroups g on s.skg=g.skg
              left join FirmsConfig fc on v.Our_ID=fc.Our_id
             where v.locked=0 and s.locked=0 and (s.agInvis=0 or (s.skladno=35 and @DepID=3)) and s.Discard=0 
             and n.ngrp not in (select ngrp from gr where AgInvis=1 or MainParent in (select Ngrp from AgDisPrice where ag_id=@ag_id and Disable=1))
             --and (s.UpWeight=0 or n.flgWeight=0) 
             and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2))
             and fc.FirmGroup = @FirmGroup
             ) a on a.ngrp=g.ngrp or a.mainparent=g.ngrp or a.parent=g.ngrp --a.MainParent=g.MainParent or
  where g.AgInvis=0 and g.MainParent not in (select Ngrp from AgDisPrice where Disable=1 and ag_id=@ag_id) 
         
          
  union
  /*Весовой товар без набора через терминал и весь штучный товар*/
  select cast(v.hitag as varchar(6)) as code,                         
         'g'+cast(n.ngrp as varchar(3)) as parent,
         't' as tip,
          iif(isnull(r.NamePrefix+' ','')<>' ',isnull(r.NamePrefix+' ',''),'') + case when (s.OnlyMinp = 1) or (max(v.minp)=1) then UPPER(n.name) else n.name end as grpname,
--   case when (case when s.OnlyMinP = 1 then cast(1 as bit) else n.OnlyMinP end) = 1 or (max(v.minp)=1) then UPPER(n.name) else n.name end as grpname,
         case when (@AllPrice=1) and (cast(sum(v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0)) as integer))=0 then 999
              when n.flgWeight=0 then cast(sum(v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0)) as integer) 
              else sum((v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0))*cast(v.weight as float))            
         end as Ostat,
         sum((v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0))*cast(v.weight as float)) as OstatVes,
         sum((v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0))*v.Price) as OstatSP,
         sum((v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0))*v.Cost) as OstatSC,
         max(distinct cast(v.OnlyMinp as integer)) as OnlyMinpSklad,
        (select max(Price) from tdVi tv, SkladList s, SkladGroups g  where  tv.Sklad=s.SkladNo and g.skg=s.skg and s.AgInvis=0 and tv.locked=0 and s.Discard=0 and (s.SafeCust=0 or @FirmGroup=10)  and tv.hitag=v.hitag and s.Locked=0
         and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2)) and tv.ncom=max(mn.MaxNcom)) as PriceCom,
        (select max(Cost) from tdVi tv, SkladList s, SkladGroups g  where  tv.Sklad=s.SkladNo and g.skg=s.skg and s.AgInvis=0 and tv.locked=0 and s.Discard=0 and (s.SafeCust=0 or @FirmGroup=10)  and tv.hitag=v.hitag and s.Locked=0
         and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2)) and tv.ncom=max(mn.MaxNcom)) as CostCom,
         max(v.minp) minp,
         case when (s.OnlyMinp = 1) or (max(v.minp)=1) then 'b'
--         case when (case when s.OnlyMinP = 1 then cast(1 as bit) else n.OnlyMinP end) = 1 or (max(v.minp)=1) then 'b'
                                                       else '' end as Box,
         --case when n.prior>getdate() then 'n' else '' end as PriorP,
         '' as PriorP,--case when isnull(pr.hitag,0) > 0 then 'p' else '' end as PriorP,
         case when isnull(r.hitag,0) > 0 then 'n' else '' end as Newt,
         --max(x.MainExtra) as MainExtra,
         --max(y.Extra) as Extra,
         --case when n.flgWeight=0 then cast(max(v.minp) as varchar(5))+':шт:упак' else cast(min(round(v.weight,2)) as varchar(10))+':кг:короб' end as Izm,
        case when n.flgWeight=0 then cast(max(v.minp) as varchar(5))+':шт:упак' else cast(max(v.minp) as varchar(5))+':кг:шт' end as Izm, 

         (select max(case when tv.[WEIGHT]<>0 then tv.Price/tv.[WEIGHT] else tv.Price end) from tdVi tv, SkladList s, SkladGroups g where  tv.Sklad=s.SkladNo and g.skg=s.skg and  s.AgInvis=0 and tv.locked=0 and (s.SafeCust=0 or @FirmGroup=10)  and s.Discard=0 and tv.hitag=v.hitag and s.Locked=0
         and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2)) and tv.ncom=max(mn.MaxNcom)) as MinPrice,
         (select max(case when tv.[WEIGHT]<>0 then tv.Price/tv.[WEIGHT] else tv.Price end) from tdVi tv, SkladList s, SkladGroups g where  tv.Sklad=s.SkladNo and g.skg=s.skg and s.AgInvis=0 and tv.locked=0 and (s.SafeCust=0 or @FirmGroup=10)  and s.Discard=0 and tv.hitag=v.hitag and s.Locked=0
         and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2)) and tv.ncom=max(mn.MaxNcom)) as BasePrice,
         (select max(case when tv.[WEIGHT]<>0 then tv.Price/tv.[WEIGHT] else tv.Price end) from tdVi tv, SkladList s, SkladGroups g where  tv.Sklad=s.SkladNo and g.skg=s.skg and s.AgInvis=0 and tv.locked=0 and (s.SafeCust=0 or @FirmGroup=10)  and s.Discard=0 and tv.hitag=v.hitag and s.Locked=0
         and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2)) and tv.ncom=max(mn.MaxNcom))*1.2 as MaxPrice,

         case when n.NDS=10 then 1
              when n.NDS=18 then 8
              else 0 end as NDS   
  from tdvi v left join skladlist s on v.sklad=s.skladNo
              left join nomen n on v.hitag=n.hitag                                
              left join 
             (select tekid, sum(Qty) as QTYZakaz from Zakaz  where CompName<>@CompName group by tekid) z on v.id=z.tekid
              left join MtPrior r on r.hitag=v.hitag and (r.DepID=@DepID or r.Sv_id=@Sv_id or r.Ag_id=@Ag_id)
              --left join
             --(select Ncod, Ngrp, Hitag, Extra as MainExtra from MtMainExtra where ag_id=@ag_id or sv_id=@sv_id or DepID=@DepID) x on x.Ncod=v.Ncod or x.Ngrp=n.Ngrp or x.Hitag=v.Hitag
             -- left join
             --(select m.hitag, max(m.Extra) as Extra from mtExtra m 
             --  where m.b_id in (select p.pin from planvisit p where p.Ag_id=@ag_id) and m.Extra>0 and m.BegDate>=getdate() and m.EndDate<=getdate() group by m.hitag) y on y.hitag=v.hitag
              /*left join
             (select distinct v.hitag from nv v join nc c on v.datnom=c.datnom where c.nd>=GetDate()-30 and c.ag_id=@ag_id) pr on pr.hitag=v.hitag*/
              /*(select n.hitag from nomen n where n.DateCreate>=GetDate()-30) pr on pr.hitag=v.hitag */ 
              left join SkladGroups g on s.skg=g.skg
              join FirmsConfig fc on v.Our_ID=fc.Our_id
              outer apply (select max(t.ncom) as MaxNcom from tdvi t, SkladList s, SkladGroups g, FirmsConfig fc 
                           where t.Sklad=s.SkladNo and g.skg=s.skg and s.AgInvis=0 and s.Discard=0 and t.hitag=v.hitag
                                 and t.locked=0 and s.Locked=0 and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2))
                                 and t.Our_ID=fc.Our_id and fc.FirmGroup = @FirmGroup
                                 ) mn
  where v.locked=0 and s.locked=0 and (s.agInvis=0 or (s.skladno=35 and @DepID=3)) and s.Discard=0 and 
        n.ngrp not in (select ngrp from gr where AgInvis=1 or MainParent in (select Ngrp from AgDisPrice where ag_id=@ag_id and Disable=1))
        and (s.UpWeight=0 or n.flgWeight=0) 
        and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2))
        and fc.FirmGroup = @FirmGroup
  group by s.OnlyMinp, n.ngrp, v.hitag, n.name, n.prior, r.hitag,n.flgWeight, n.NDS, r.NamePrefix--, pr.hitag 
  
  union
  
  /*Весовой товар для набора через терминал (пересчет веса в примерный остаток)*/
  select cast(v.hitag as varchar(6)) as code,                         
         'g'+cast(n.ngrp as varchar(3)) as parent,
         't' as tip,
         iif(isnull(r.NamePrefix+' ','')<>' ',isnull(r.NamePrefix+' ',''),'') + case when (s.OnlyMinp = 1) or (max(v.minp)=1) then UPPER(n.name) else n.name end as grpname,
--		 case when (case when s.OnlyMinP = 1 then cast(1 as bit) else n.OnlyMinP end) = 1 or (max(v.minp)=1) then UPPER(n.name) else n.name end as grpname,
         case when (@AllPrice=1) and cast(sum(v.morn-v.sell-v.bad-v.remov+v.isprav) as integer)=0 then 999
              else sum((v.morn-v.sell-v.bad-v.remov+v.isprav)*cast(v.weight as float))
         end as Ostat,
          -- round(sum(case when n.netto<>0 then (v.morn-v.sell-v.bad-v.remov+v.isprav)*v.weight/n.netto 
                                      
         sum((v.morn-v.sell-v.bad-v.remov+v.isprav)*cast(v.weight as float)) as OstatVes,
         sum((v.morn-v.sell-v.bad-v.remov+v.isprav)*v.Price) as OstatSP,
         sum((v.morn-v.sell-v.bad-v.remov+v.isprav)*v.Cost) as OstatSC,
         max(distinct cast(v.OnlyMinp as integer)) as OnlyMinpSklad,
         case when max(n.netto)=0   then round(avg((case when v.weight<>0 then v.Price/cast(v.weight as float) else v.Price end)),2)
              when max(n.netto)<>0  then round(avg(n.netto*(case when v.weight<>0 then v.Price/cast(v.weight as float) else v.Price end)),2)
        
         end as PriceCom,
         
         case when max(n.netto)=0   then round(avg((case when v.weight<>0 then v.Cost/cast(v.weight as float) else v.Cost end)),2)
              when max(n.netto)<>0  then round(avg(n.netto*(case when v.weight<>0 then v.Cost/cast(v.weight as float) else v.Cost end)),2)
        
         end as CostCom,
         max(v.minp) minp,
         case when (s.OnlyMinp = 1) or (max(v.minp)=1) then 'b'
--         case when (case when s.OnlyMinP = 1 then cast(1 as bit) else n.OnlyMinP end) = 1 or (max(v.minp)=1) then 'b'
                                                       else '' end as Box,
         --case when n.prior>getdate() then 'n' else '' end as PriorP,
         '' as PriorP,--case when isnull(pr.hitag,0) > 0 then 'p' else '' end as PriorP,
         case when isnull(r.hitag,0) > 0 then 'n' else '' end as Newt,
         --max(x.MainExtra) as MainExtra,
         --max(y.Extra) as Extra,
         --case when n.flgWeight=0 then cast(max(v.minp) as varchar(5))+':шт:упак' else cast(min(round(v.weight,2)) as varchar(10))+':кг:короб' end as Izm,
        case when n.flgWeight=0 then cast(max(v.minp) as varchar(5))+':шт:упак' else cast(max(v.minp) as varchar(5))+':кг:шт' end as Izm, 
       /*(case when max(n.netto)=0   then round(avg((case when v.weight<>0 then v.Price/cast(v.weight as float) else v.Price end)),2)
              when max(n.netto)<>0  then round(avg(n.netto*(case when v.weight<>0 then v.Price/cast(v.weight as float) else v.Price end)),2)
        
         end) as MinPrice,
               case when max(n.netto)=0   then round(avg((case when v.weight<>0 then v.Price/cast(v.weight as float) else v.Price end)),2)
              when max(n.netto)<>0  then round(avg(n.netto*(case when v.weight<>0 then v.Price/cast(v.weight as float) else v.Price end)),2)
        
         end as BasePrice, 
        (case when max(n.netto)=0   then round(avg((case when v.weight<>0 then v.Price/cast(v.weight as float) else v.Price end)),2)
              when max(n.netto)<>0  then round(avg(n.netto*(case when v.weight<>0 then v.Price/cast(v.weight as float) else v.Price end)),2)
        
         end)*1.2 as MaxPrice,*/
         (select max(case when tv.[WEIGHT]<>0 then tv.Price/tv.[WEIGHT] else tv.Price end) from tdVi tv, SkladList s, SkladGroups g where  tv.Sklad=s.SkladNo and g.skg=s.skg and  s.AgInvis=0 and tv.locked=0 and (s.SafeCust=0 or @FirmGroup=10)  and s.Discard=0 and tv.hitag=v.hitag and s.Locked=0
         and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2)) and tv.ncom=max(mn.MaxNcom)) as MinPrice,
         (select max(case when tv.[WEIGHT]<>0 then tv.Price/tv.[WEIGHT] else tv.Price end) from tdVi tv, SkladList s, SkladGroups g where  tv.Sklad=s.SkladNo and g.skg=s.skg and s.AgInvis=0 and tv.locked=0 and (s.SafeCust=0 or @FirmGroup=10)  and s.Discard=0 and tv.hitag=v.hitag and s.Locked=0
         and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2)) and tv.ncom=max(mn.MaxNcom)) as BasePrice,
         (select max(case when tv.[WEIGHT]<>0 then tv.Price/tv.[WEIGHT] else tv.Price end) from tdVi tv, SkladList s, SkladGroups g where  tv.Sklad=s.SkladNo and g.skg=s.skg and s.AgInvis=0 and tv.locked=0 and (s.SafeCust=0 or @FirmGroup=10)  and s.Discard=0 and tv.hitag=v.hitag and s.Locked=0
         and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2)) and tv.ncom=max(mn.MaxNcom))*1.2 as MaxPrice,
         case when n.NDS=10 then 1
              when n.NDS=18 then 8
              else 0 end as NDS   
  from tdvi v left join skladlist s on v.sklad=s.skladNo
              left join nomen n on v.hitag=n.hitag                                
              left join 
             (select tekid, sum(Qty) as QTYZakaz from Zakaz  where CompName<>@CompName group by tekid) z on v.id=z.tekid
              left join MtPrior r on r.hitag=v.hitag and (r.DepID=@DepID or r.Sv_id=@Sv_id or r.Ag_id=@Ag_id)
             --left join
             --(select Ncod, Ngrp, Hitag, Extra as MainExtra from MtMainExtra where ag_id=@ag_id or sv_id=@sv_id or DepID=@DepID) x on x.Ncod=v.Ncod or x.Ngrp=n.Ngrp or x.Hitag=v.Hitag
             -- left join
             --(select m.hitag, max(m.Extra) as Extra from mtExtra m 
             --  where m.b_id in (select p.pin from planvisit p where p.Ag_id=@ag_id) and m.Extra>0 and m.BegDate>=getdate() and m.EndDate<=getdate() group by m.hitag) y on y.hitag=v.hitag
              /*left join
             (select distinct v.hitag from nv v join nc c on v.datnom=c.datnom where c.nd>=GetDate()-30 and c.ag_id=@ag_id) pr on pr.hitag=v.hitag*/
              /*(select n.hitag from nomen n where n.DateCreate>=GetDate()-30) pr on pr.hitag=v.hitag */ 
              left join SkladGroups g on s.skg=g.skg
              join FirmsConfig fc on v.Our_ID=fc.Our_id
              outer apply (select max(t.ncom) as MaxNcom from tdvi t, SkladList s, SkladGroups g, FirmsConfig fc 
                           where t.Sklad=s.SkladNo and g.skg=s.skg and s.AgInvis=0 and s.Discard=0 and t.hitag=v.hitag
                                 and t.locked=0 and s.Locked=0 and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2))
                                 and t.Our_ID=fc.Our_id and fc.FirmGroup = @FirmGroup
                                 ) mn
  where v.locked=0 and s.locked=0 and s.agInvis=0 and s.Discard=0 and            
        n.ngrp not in (select ngrp from gr where AgInvis=1 or MainParent in (select Ngrp from AgDisPrice where ag_id=@ag_id and Disable=1))
        and s.UpWeight=1 and n.flgWeight=1 and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2))
        and fc.FirmGroup = @FirmGroup
  group by s.OnlyMinp, n.ngrp, v.hitag, n.name, n.prior, r.hitag,n.flgWeight, n.NDS, r.NamePrefix--, pr.hitag   
            
  union
  
  /*Виртульные коды*/
  select cast(n.hitag as varchar(6)) as code,                         
         '' as parent,--'g'+cast(n.ngrp as varchar(3)) as parent,
         't' as tip,
         n.name as grpname,
         999999 as Ostat,
         0 as OstatVes,
         1 as OstatSP,
         1 as OstatSC,
         1 as OnlyMinpSklad,
         1 as PriceCom,
         1 as CostCom,
         1 as minp,
         -- 1 as sklad,
         '' as Box,
         '' as PriorP,
         'p' as Newt,
         --0 as MainExtra,
         --0 as Extra,
         '' as Izm,
         0 as MinPrice, 0 as BasePrice, 0 as MaxPrice, 
         0 as NDS
  from nomen n where n.hitag in (94502,94503,94504) --94500,94501,
/*  union
  
   /*Товар для возврата*//*Товар без набора через терминал*/
*//*  select cast(v.hitag as varchar(6)) as code,                         
         'g'+cast(n.ngrp as varchar(3)) as parent,
         't' as tip,
         case when (s.OnlyMinp = 1) or (max(v.minp)=1) then UPPER(n.name) else n.name end as grpname,
         case when (@AllPrice=1) and (cast(sum(v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0)) as integer))=0 then 999
              else cast(sum(v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0)) as integer) end as Ostat,
         sum((v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0))*cast(v.weight as float)) as OstatVes,
         sum((v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0))*v.Price) as OstatSP,
         sum((v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0))*v.Cost) as OstatSC,
         max(distinct cast(0 as integer)) as OnlyMinpSklad,
        (select max(Price) from tdVi tv, SkladList s where  tv.Sklad=s.SkladNo and s.AgInvis=0 and tv.locked=0 and s.SafeCust=0  and tv.hitag=v.hitag and s.Locked=0
         and tv.ncom=(select max(t.ncom) from tdvi t, SkladList s where t.Sklad=s.SkladNo and s.AgInvis=0 and t.hitag=tv.hitag and t.locked=0 and s.SafeCust=0 and s.Locked=0)) as PriceCom,
        (select max(Cost) from tdVi tv, SkladList s where  tv.Sklad=s.SkladNo and s.AgInvis=0 and tv.locked=0 and s.SafeCust=0  and tv.hitag=v.hitag and s.Locked=0
          and tv.ncom=(select max(t.ncom) from tdvi t, SkladList s where t.Sklad=s.SkladNo and s.AgInvis=0 and t.hitag=tv.hitag and t.locked=0 and s.SafeCust=0 and s.Locked=0)) as CostCom,
         max(v.minp) minp,
         case when (s.OnlyMinp = 1) or (max(v.minp)=1) then 'b'
                                                       else '' end as Box,
         --case when n.prior>getdate() then 'n' else '' end as PriorP,
         '' as PriorP,--case when isnull(pr.hitag,0) > 0 then 'p' else '' end as PriorP,
         case when isnull(r.hitag,0) > 0 then 'n' else '' end as Newt,
         --max(x.MainExtra) as MainExtra,
         --max(y.Extra) as Extra,
         --case when n.flgWeight=0 then cast(max(v.minp) as varchar(5))+':шт:упак' else cast(min(round(v.weight,2)) as varchar(10))+':кг:короб' end as Izm,
        case when n.flgWeight=0 then cast(max(v.minp) as varchar(5))+':шт:упак' else cast(max(v.minp) as varchar(5))+':шт:короб' end as Izm, 
         0 as MinPrice,
         0 as BasePrice, 
         0 as MaxPrice,
         case when n.NDS=10 then 1
              when n.NDS=18 then 8
              else 0 end as NDS   
  from visual v left join skladlist s on v.sklad=s.skladNo
              left join nomen n on v.hitag=n.hitag                                
              left join 
             (select tekid, sum(Qty) as QTYZakaz from Zakaz  where CompName<>@CompName group by tekid) z on v.id=z.tekid
              left join MtPrior r on r.hitag=v.hitag and (r.DepID=@DepID or r.Sv_id=@Sv_id or r.Ag_id=@Ag_id)
              --left join
             --(select Ncod, Ngrp, Hitag, Extra as MainExtra from MtMainExtra where ag_id=@ag_id or sv_id=@sv_id or DepID=@DepID) x on x.Ncod=v.Ncod or x.Ngrp=n.Ngrp or x.Hitag=v.Hitag
             -- left join
             --(select m.hitag, max(m.Extra) as Extra from mtExtra m 
             --  where m.b_id in (select p.pin from planvisit p where p.Ag_id=@ag_id) and m.Extra>0 and m.BegDate>=getdate() and m.EndDate<=getdate() group by m.hitag) y on y.hitag=v.hitag
              /*left join
             (select distinct v.hitag from nv v join nc c on v.datnom=c.datnom where c.nd>=GetDate()-30 and c.ag_id=@ag_id) pr on pr.hitag=v.hitag*/
              /*(select n.hitag from nomen n where n.DateCreate>=GetDate()-30) pr on pr.hitag=v.hitag */ 
 *//*   
  where v.locked=0 and s.locked=0 and (s.agInvis=0 or (s.skladno=35 and @DepID=3)) and s.Discard=0 and s.SafeCust=0 and           
        n.ngrp not in (select ngrp from gr where AgInvis=1 or MainParent in (select Ngrp from AgDisPrice where ag_id=@ag_id and Disable=1))
        and (s.UpWeight=0 or n.flgWeight=0) and v.hitag in
        (select distinct hitag from tdvi 
         except
         select distinct hitag from  visual where datepost>=(@nd-90))
  group by s.OnlyMinp, n.ngrp, v.hitag, n.name, n.prior, r.hitag,n.flgWeight, n.NDS--, pr.hitag  
  */
  
  
  order by tip,code            
                                     
end