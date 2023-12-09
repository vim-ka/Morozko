

CREATE procedure MobAgents.MobGetPriceList_WorkOld @ag_id int, @CompName varchar(50)
as
begin
--  set transaction isolation level read uncommitted  
  set nocount on
  declare @DepID int, @Sv_id int, @P_ID int, @Our_ID int
  declare @AllPrice bit, @FirmGroup smallint, @nd datetime

  set @nd=dbo.today()
  
  select @AllPrice=Merch,@sv_id=sv_ag_id,@DepID=DepID, @P_ID=P_ID 
  from agentlist where ag_id=@ag_id
  
  select @Our_ID = Our_ID from Deps where DepID=@DepID
  
  --формирование подсветки товара
  --/*
  
  select * into #pr
  from dbo.MtPrior
  
  create table #tmpPrior(hitag int,
			     		 LightEnable bit,
                         clr int,
                         ord int)

  insert into #tmpPrior(hitag,LightEnable,clr,ord)
  select hitag, 
         LightEnable, 
         Clr, 
         ord 
  from #pr 
  where ag_id=@ag_id
	
  create nonclustered index idx_mt_prior_hitag on #tmpPrior(hitag)
    
  insert into #tmpPrior(hitag,LightEnable,clr,ord)
  select hitag, 
         LightEnable, 
         Clr, 
         ord 
  from #pr m
  where sv_id=@sv_id
        and not exists(select 1 from #tmpPrior t where t.hitag=m.Hitag)

  insert into #tmpPrior(hitag,LightEnable,clr,ord)
  select hitag, 
         LightEnable, 
         Clr, 
         ord 
  from #pr m
  where depid=@depid
        and not exists(select 1 from #tmpPrior t where t.hitag=m.Hitag)
          
  insert into #tmpPrior(hitag,LightEnable,clr,ord)
  select hitag, 
         LightEnable, 
         Clr, 
         ord 
  from #pr m
  where depid=0
        and not exists(select 1 from #tmpPrior t where t.hitag=m.Hitag)
  
  drop table #pr
  --*/
  --конец формирования подсветки товара
  
  /*select @FirmGroup=FC.FirmGroup
  from FirmsConfig fc join Person p on fc.Our_id=p.Our_id
  where p.P_ID=@P_ID*/
  
  select @FirmGroup=FC.FirmGroup
  from FirmsConfig fc 
  where fc.Our_ID=@Our_ID

  select v.id into #NeedIDs
  from tdvi v left join skladlist s on v.sklad=s.skladNo
              left join nomen n on v.hitag=n.hitag                                
              left join MtPrior r on r.hitag=v.hitag and (r.DepID=@DepID or r.Sv_id=@Sv_id or r.Ag_id=@Ag_id)
              left join SkladGroups g on s.skg=g.skg
              join FirmsConfig fc on v.Our_ID=fc.Our_id
  where v.locked=0 and s.locked=0 and (s.agInvis=0 or (s.skladno=35 and @DepID=3)) and s.Discard=0
        and n.ngrp not in (select ngrp from gr where AgInvis=1 or MainParent in (select Ngrp from AgDisPrice where ag_id=@ag_id and Disable=1))
        and n.ngrp not in (select Ngrp from AgDisPrice where Disable=1 and ag_id=@ag_id)
        and ((@DepID=43 and g.PLID=2) or (@DepID<>43 and g.PLID<>2))
        and fc.FirmGroup = @FirmGroup   


  select v.hitag, r.ngrp, r.mainparent, r.parent, n.flgWeight, max(v.ncom) as ncom into #TempPrice 
  from tdvi v join #NeedIDs nid on v.id=nid.id
              left join nomen n on v.hitag=n.hitag                                
              left join gr r on n.ngrp=r.ngrp
  group by v.hitag, r.ngrp, r.mainparent, r.parent, n.flgWeight  
  
  /* Товар, который брали точки агента в течении 30 последних дней*/
  create table #NeedDCK (dck int)
  
  insert into #NeedDCK (dck)
  select c.dck from defcontract c where c.ag_id=@ag_id or c.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0)
  union
  select b.add_dck from agaddbases b where b.ag_id=@ag_id and b.add_dck<>0
  
  create table #NeedPin (pin int)
  
  insert into #NeedPin (pin)
  select c.pin from defcontract c join #NeedDCK d on c.dck=d.dck
  
  create table #NeedHitag (hitag int)
  
  if @FirmGroup = 10 
  begin  
    insert into #NeedHitag (hitag)
    select distinct c.hitag from bigpricelist c join #NeedPin d on c.b_id=d.pin
    where c.SaveD>=@nd-30
  end  
  
  /*Категории*/
  select 'g'+cast(g.ngrp as varchar(3)) as code,
         case when (g.parent=0) or (g.parent=90) then ''
                                                 else 'g'+cast(g.parent as varchar(3)) end as parent,
         'g' as tip,
         isnull(r.Prior+' ','')+g.grpname as grpname,
         0 as MinPrice, 
         0 as BasePrice, 
         0 as MaxPrice,
         '' as Str1kg,
         0 as ostat,
         '' as EdIzm,
         '' as PosColor,
         '' as Box, 
         '' as PriorP,
         '' as Newt,
         0 as NDS,
         '' as Info
  from GR g left join GRPrior r on g.ngrp=r.ngrp and r.DepID=@DepID
            join #TempPrice a on a.ngrp=g.ngrp or a.mainparent=g.ngrp or a.parent=g.ngrp or g.ngrp in (41,42,43,44,45)
  where g.AgInvis=0
        and g.MainParent not in (select Ngrp from AgDisPrice where Disable=1 and ag_id=@ag_id) 
        and g.Ngrp not in (select Ngrp from AgDisPrice where Disable=1 and ag_id=@ag_id)
         
          
  UNION
  /*Товар*/
  select cast(v.hitag as varchar(6)) as code,                         
         'g'+cast(n.ngrp as varchar(3)) as parent,
         't' as tip,
         case when ((s.OnlyMinp = 1) and max(v.minp)>1) or ((s.OnlyMinp = 1) and max(v.minp)=1) and (max(n.Netto)>1)  then UPPER(n.name) else n.name end as grpname,
         
         round(max(mn.Price),2) as MinPrice,
         round(max(mn.Price),2) as BasePrice,
         round(max(mn.Price)*1.2,2) as MaxPrice,
         
         max(case when v.[WEIGHT]>0.01 and n.flgWeight=1 then ' Цена ' + cast(cast(round(mn.Price,2) as money) as varchar) + 'р/кг'
                  when n.netto<>0 and n.flgWeight=0 then ' Цена ' + cast(cast(round(mn.Price/n.netto,2) as money) as varchar) + 'р/кг'
             else '' end) as Str1kg,
         
         case when (@AllPrice=1) and (cast(sum(v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0)) as integer))=0 then 999
              when n.flgWeight=0 then cast(sum(v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0)) as integer) 
              else sum((v.morn-v.sell-v.bad-v.remov+v.isprav)*cast(v.weight as float)-isnull(z.QTYZakaz,0)*iif(s.UpWeight=1,n.netto,cast(v.weight as float)))            
         end as Ostat,
         
         case when n.flgWeight=0 
              then cast(max(v.minp) as varchar(5))+':шт:упак' 
              else convert(varchar, cast(max(n.netto) as money), 0)+':кг:шт' end as EdIzm, 
              
         iif(isnull(r.ord,0) = 0, '', cast(r.ord as varchar(5)))+':'+dbo.IntToColorHTML(r.clr) as PosColor,

         case when (s.OnlyMinp = 1)-- or (max(v.minp)=1 /*and n.flgWeight=0*/) 
              then 'b'
              else '' end as Box,
              
         case when (isnull(nh.hitag,0) > 0) 
              then 'p'
              else '' end as PriorP,
         
         case when (isnull(r.hitag,0) > 0) and (r.LightEnable=1)
              then 'n'
              else '' end as Newt,
         
         case when n.NDS=10 then 1
              when n.NDS=18 then 8
              else 0 end as NDS,   
               
         '' as Info
  from tdvi v join #NeedIDs nid on v.id=nid.id 
              left join nomen n on v.hitag=n.hitag                                
              --left join MtPrior r on r.hitag=v.hitag and (r.DepID=@DepID or r.Sv_id=@Sv_id or r.Ag_id=@Ag_id)
              left join #tmpPrior r on r.hitag=v.hitag
              left join skladlist s on v.sklad=s.skladNo
              left join (select tekid, sum(Qty) as QTYZakaz from Zakaz where CompName<>@CompName group by tekid) z on v.id=z.tekid
              left join #NeedHitag nh on v.hitag=nh.hitag            
              outer apply 
              (select max(case when t.[WEIGHT]>0.01 and tm.flgWeight=1 then t.Price/t.[WEIGHT] else t.Price end) as Price 
               from tdvi t join #NeedIDs nid on t.id=nid.id 
                           join #TempPrice tm on t.hitag=tm.hitag and t.ncom=tm.ncom 
               where t.hitag=v.hitag)  mn
             /*left join
             (select distinct v.hitag from nv v join nc c on v.datnom=c.datnom where c.nd>=GetDate()-30 and c.ag_id=@ag_id) pr on pr.hitag=v.hitag*/
              /*(select n.hitag from nomen n where n.DateCreate>=GetDate()-30) pr on pr.hitag=v.hitag */ 
        
  group by s.OnlyMinp, n.ngrp, v.hitag, n.name, n.prior, r.hitag,n.flgWeight, n.NDS,r.LightEnable, r.ord, r.clr,nh.hitag 
  
  UNION
  
  /*Виртульные коды*/
    select cast(n.hitag as varchar(6)) as code,                         
         iif(ngrp<41 or ngrp>45,'','g'+cast(n.ngrp as varchar(3))) as parent,
         't' as tip,
         n.name as grpname,
         0 as MinPrice,
         0 as BasePrice,
         0 as MaxPrice, 
         '' as Str1kg,
         999999 as Ostat,
         '' as EdIzm,
         '' as PosColor,
         '' as Box,
         '' as PriorP,
         'n' as Newt,
         0 as NDS,
         '' as Info
 
  from nomen n where n.hitag in (94502,94503,94504,94510,94511,94512,94513,94514,94515,94516) 
  
  
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
  drop table #tmpPrior
  
 	set nocount off
end