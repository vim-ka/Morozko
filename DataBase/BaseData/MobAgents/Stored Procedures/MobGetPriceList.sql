CREATE procedure MobAgents.MobGetPriceList @ag_id int, @CompName varchar(50)
as
begin
--  set transaction isolation level read uncommitted  
  --set nocount on
  declare @DepID int, @Sv_id int, @P_ID int, @Our_ID int
  declare @AllPrice bit, @FirmGroup smallint, @nd datetime
  declare @PLID int
  
  set @nd=dbo.today()
  
  select @AllPrice=Merch, @sv_id=sv_ag_id, @DepID=DepID, @P_ID=P_ID 
  from agentlist 
  where ag_id=@ag_id
  
  select @Our_ID = Our_ID , @PLID = PLID
  from Deps 
  where DepID=@DepID
  
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
  
   /*select @FirmGroup=FC.FirmGroup  from FirmsConfig fc join Person p on fc.Our_id=p.Our_id
  where p.P_ID=@P_ID*/
 
  
  select @FirmGroup=FC.FirmGroup
  from FirmsConfig fc 
  where fc.Our_ID=@Our_ID
  
  create table #LocalTDVI (ID int, hitag int, Ncod int, Sklad int, Rest int, 
    Our_ID int, price money, cost money, locked bit, minp int, mpu int, weight float, 
    startid int, datepost datetime, DCK int, ncom int)
    
  insert into #LocalTDVI (ID, hitag , Ncod, Sklad, Rest, Our_ID, price, cost, locked, minp, mpu, weight, startid, datepost,DCK, ncom)
    select ID, hitag , Ncod, Sklad, iif(locked=1,0, morn-sell+isprav-remov-rezerv-iif(bad<0,0,bad)), tdVi.Our_ID, price, cost, locked, minp, mpu, weight, startid, datepost,DCK,
           ncom
    
    from  tdvi join FirmsConfig fc on fc.Our_id=tdvi.our_id
    where fc.FirmGroup=@FirmGroup  

  select v.id into #NeedIDs
  from #LocalTDVI v left join skladlist s on v.sklad=s.skladNo
                    left join nomen n on v.hitag=n.hitag                                
                    left join MtPrior r on r.hitag=v.hitag and (r.DepID=@DepID or r.Sv_id=@Sv_id or r.Ag_id=@Ag_id)
                    left join SkladGroups g on s.skg=g.skg
                    join FirmsConfig fc on v.Our_ID=fc.Our_id
  where /*v.locked=0 and*/ s.locked=0 and (s.agInvis=0 or (s.skladno=35 and @DepID=3)) and s.Discard=0
        and n.ngrp not in (select ngrp from gr where AgInvis=1 or MainParent in (select Ngrp from AgDisPrice where ag_id=@ag_id and Disable=1))
        and n.ngrp not in (select Ngrp from AgDisPrice where Disable=1 and ag_id=@ag_id)
        and g.PLID=@PLID
        and fc.FirmGroup = @FirmGroup  
        and s.SafeCust=0 --Товары на ответ. хранении не показываем
  create nonclustered index idx_mt_tdvi_hitag on #LocalTDVI(hitag)
 /* select t.hitag into #NeedHitagsVis from
  (select distinct v.hitag from visual v join FirmsConfig fc on v.Our_ID=fc.Our_id 
                                         left join nomen n on v.hitag=n.hitag    
   where v.datepost>=(@nd-200) and fc.FirmGroup = @FirmGroup 
         and n.ngrp not in (select ngrp from gr where AgInvis=1 or MainParent in (select Ngrp from AgDisPrice where ag_id=@ag_id and Disable=1))
         and n.ngrp not in (select Ngrp from AgDisPrice where Disable=1 and ag_id=@ag_id)   
  except 
  select  distinct v.hitag from tdvi v join #NeedIDs s on v.id=s.id) t*/

  create table #TempPrice (hitag int, ngrp int, mainparent int, parent int, flgWeight bit, Price money)
  
  insert into #TempPrice (hitag, ngrp, mainparent, parent, flgWeight, Price)
  select v.hitag, r.ngrp, r.mainparent, r.parent, n.flgWeight, 
         max(case when v.[WEIGHT]>0.0001 and n.flgWeight=1 then v.Price/v.[WEIGHT] else v.Price end) as Price 
  from #LocalTDVI v join #NeedIDs nid on v.id=nid.id
                    left join nomen n on v.hitag=n.hitag                                
                    left join gr r on n.ngrp=r.ngrp
  where (n.flgWeight = 0) or (v.Weight>0.0001 and n.flgWeight = 1) 
        and v.Rest>0  --убрать после 07.07.17               
  group by v.hitag, r.ngrp, r.mainparent, r.parent, n.flgWeight  
  
  union
  
  select v.hitag, r.ngrp, r.mainparent, r.parent, n.flgWeight, v.price
  from [MobAgents].GoodForBack v left join nomen n on v.hitag=n.hitag                                
                                 left join gr r on n.ngrp=r.ngrp
  where v.hitag not in 
  (select v.hitag
  from #LocalTDVI v join #NeedIDs nid on v.id=nid.id
                    left join nomen n on v.hitag=n.hitag                                
                    left join gr r on n.ngrp=r.ngrp
  group by v.hitag, r.ngrp, r.mainparent, r.parent, n.flgWeight)                               
  
  group by v.hitag, r.ngrp, r.mainparent, r.parent, n.flgWeight, v.price  
  
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
  
  
  select distinct g.ngrp,r.Prior into #GRTemp
  from GR g left join GRPrior r on g.ngrp=r.ngrp and r.DepID=@DepID
            join #TempPrice a on a.ngrp=g.ngrp or a.mainparent=g.ngrp or a.parent=g.ngrp or g.ngrp in (41,42,43,44,45)
  where g.AgInvis=0 and
        g.MainParent not in (select Ngrp from AgDisPrice where Disable=1 and ag_id=@ag_id) 
        and g.Ngrp not in (select Ngrp from AgDisPrice where Disable=1 and ag_id=@ag_id)
  
  
  /*Категории*/

  select 'g-1' as code,
         '' as parent,
         'g' as tip,
         'Категория не задана' as grpname,
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
  UNION
  select distinct 'g'+cast(g.ngrp as varchar(3)) as code,
         case when (g.parent=0) or (g.parent=90) then ''
                                                 else 'g'+cast(g.parent as varchar(3)) end as parent,
         'g' as tip,
         isnull(gr.Prior+' ','')+g.grpname as grpname,
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
  from GR g join #GRTemp gr on g.ngrp=gr.ngrp
  UNION
  select distinct 'gs'+cast(s.skladno as varchar(3)) as code,
         '' as parent,
         'g' as tip,
         ' '+isnull(upper( s.SkladName),'?') as grpname,
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
  from SkladList s where s.isGroup=1
          
  UNION 
  --Товар
  select cast(v.hitag as varchar(6))+iif(s.isGroup = 0,  '','316') as code,   
         case when gt.ngrp is null then 'g-1'
              when s.isGroup = 1 then 'gs316'
              else 'g'+cast(n.ngrp as varchar(3))                
         end as parent,     
         --iif(gt.ngrp is null,'g-1', 'g'+cast(n.ngrp as varchar(3))) as parent,
         't' as tip,
         case when ((s.OnlyMinp = 1) and max(v.minp)>1) or ((s.OnlyMinp = 1) and max(v.minp)=1) and (max(n.Netto)>1)  then UPPER(n.name) else n.name end as grpname,
         
         round(max(tm.price),2) as MinPrice,
         round(max(tm.price),2) as BasePrice,
         round(max(tm.price)*1.2,2) as MaxPrice,
         
         max(case when v.[WEIGHT]>0.01 and n.flgWeight=1 then ' Цена ' + cast(cast(round(tm.price,2) as money) as varchar) + 'р/кг'
                  when n.netto<>0 and n.flgWeight=0 then ' Цена ' + cast(cast(round(tm.price/n.netto,2) as money) as varchar) + 'р/кг'
             else '' end) as Str1kg,
         
         case when (@AllPrice=1) and (cast(sum(v.Rest-isnull(z.QTYZakaz,0)) as integer))=0 then 999
              when n.flgWeight=0 then cast(sum(v.Rest-isnull(z.QTYZakaz,0)) as integer) 
              else sum((v.rest)*cast(v.weight as float)-isnull(z.QTYZakaz,0)*iif(s.UpWeight=1,n.netto,cast(v.weight as float)))            
         end as Ostat,
         
         case when n.flgWeight=0 
              then cast(max(v.minp) as varchar(5))+':шт:упак' 
              else convert(varchar, cast(max(n.netto) as money), 0)+':кг:шт' end as EdIzm, 
              
         iif(isnull(r.ord,0) = 0, '', cast(r.ord as varchar(5)))+':'+dbo.IntToColorHTML(r.clr) as PosColor,

         case when (s.OnlyMinp = 1)-- or (max(v.minp)=1 and n.flgWeight=0) 
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
               
         'Код товара:'+cast(v.hitag as varchar(6))
          +' срок годн.:'+cast(isnull(n.ShelfLife,0) as varchar(4))+'дн.' as Info
  from #LocalTDVI v join #NeedIDs nid on v.id=nid.id 
              left join nomen n on v.hitag=n.hitag                                
              left join #tmpPrior r on r.hitag=v.hitag
              left join skladlist s on v.sklad=s.skladNo
              left join (select tekid, sum(Qty) as QTYZakaz from Zakaz where CompName<>@CompName group by tekid) z on v.id=z.tekid
              left join #NeedHitag nh on v.hitag=nh.hitag            
              join #TempPrice tm on v.hitag=tm.hitag 
              left join #GRTemp gt on n.ngrp=gt.ngrp

        
  group by s.OnlyMinp, n.ngrp, v.hitag, n.name, n.prior, r.hitag,n.flgWeight, n.NDS,r.LightEnable, r.ord, r.clr,nh.hitag,n.ShelfLife,gt.ngrp, s.isGroup 
  
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
  
  
  UNION 
  
   --Товар для возврата
  select cast(v.hitag as varchar(6)) as code,                         
         iif(gt.ngrp is null,'g-1', 'g'+cast(n.ngrp as varchar(3))) as parent,
         't' as tip,
         case when  ( max(CAST(s.OnlyMinp as int)) = 1 and max(n.minp)>1 )
                     or ( max(cast(s.OnlyMinp as INT)) = 1 and max(n.minp)=1 and max(n.Netto)>1 ) 
          then UPPER(n.name)
          else n.name end +'(для возврата)' as grpname,
         
         round(max(v.Price),2) as MinPrice,
         round(max(v.Price),2) as BasePrice,
         round(max(v.Price)*1.2,2) as MaxPrice,
         
         /*max(case when v.[WEIGHT]>0.01 and n.flgWeight=1 then ' Цена ' + cast(cast(round(v.Price,2) as money) as varchar) + 'р/кг'
                  when n.netto<>0 and n.flgWeight=0 then ' Цена ' + cast(cast(round(v.Price/n.netto,2) as money) as varchar) + 'р/кг'
             else '' end)*/
         '' as Str1kg,
         
         0 as Ostat,
         
         case when n.flgWeight=0 
              then cast(max(n.minp) as varchar(5))+':шт:упак' 
              else convert(varchar, cast(max(n.netto) as money), 0)+':кг:шт' end as EdIzm, 
              
         '' as PosColor,

         '' as Box,
         
         /*case when max(cast(s.OnlyMinp as int)) = 1
              then 'b'
              else '' end as Box,*/
              
         '' as PriorP,
         '' as Newt,
         
         case when n.NDS=10 then 1
              when n.NDS=18 then 8
              else 0 end as NDS,   
               
         'Код товара:'+cast(v.hitag as varchar(6))
          +' срок годн.:'+cast(isnull(n.ShelfLife,0) as varchar(4))+'дн.' as Info
  from [MobAgents].GoodForback v left join nomen n on v.hitag=n.hitag                                
                                 left join skladlist s on v.sklad=s.skladNo
                                 left join #GRTemp gt on n.ngrp=gt.ngrp
  where v.FirmGroup=@FirmGroup --and v.hitag not in (select hitag from #TempPrice) 
        and v.PLID=@PLID
  and v.hitag not in 
  (select v.hitag
    from #LocalTDVI v join #NeedIDs nid on v.id=nid.id 
              left join nomen n on v.hitag=n.hitag                                
              left join #tmpPrior r on r.hitag=v.hitag
              left join skladlist s on v.sklad=s.skladNo
              left join (select tekid, sum(Qty) as QTYZakaz from Zakaz where CompName<>@CompName group by tekid) z on v.id=z.tekid
              left join #NeedHitag nh on v.hitag=nh.hitag            
              join #TempPrice tm on v.hitag=tm.hitag 
              join skladgroups g on s.skg=g.skg
     where g.PLID=@PLID         
    group by s.OnlyMinp, n.ngrp, v.hitag, n.name, n.prior, r.hitag,n.flgWeight, n.NDS,r.LightEnable, r.ord, r.clr,nh.hitag )
      
  group by n.ngrp,gt.ngrp, v.hitag, n.name, n.flgWeight, n.NDS,n.ShelfLife

 order by tip, code
  
  
  drop table #LocalTDVI
  drop table #tmpPrior
  --set nocount off
end