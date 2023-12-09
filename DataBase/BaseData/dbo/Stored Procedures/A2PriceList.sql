CREATE procedure A2PriceList @FirmGroup smallint, @PLID smallint, @nd datetime
as
declare @Allprice bit
begin
  set @AllPrice=1;
  
  create table #NeedIds(id int);
  
  insert into #NeedIds
  select v.id 
  from 
    tdvi v 
    inner join skladlist s on v.sklad=s.skladNo
    inner join nomen n on v.hitag=n.hitag                                
    left join SkladGroups g on s.skg=g.skg
    inner join FirmsConfig fc on v.Our_ID=fc.Our_id
  where 
    v.locked=0 and s.locked=0 and s.agInvis=0 and s.Discard=0
    and n.ngrp not in (select ngrp from gr where AgInvis=1)
    and g.plid=@PLID
    and fc.FirmGroup = @FirmGroup 
  create index nd_idx_temp on #NeedIds(id)
  


  select v.hitag, r.ngrp, r.mainparent, r.parent, n.flgWeight, max(v.ncom) as ncom 
  into #TempPrice 
  from 
    tdvi v 
    inner join #NeedIDs nid on v.id=nid.id
    inner join nomen n on v.hitag=n.hitag                                
    inner join gr r on n.ngrp=r.ngrp
  group by v.hitag, r.ngrp, r.mainparent, r.parent, n.flgWeight;
  
 
  select 'g'+cast(g.ngrp as varchar(3)) as code,
         case when (g.parent=0) or (g.parent=90) then ''
                                                 else 'g'+cast(g.parent as varchar(3)) end as parent,
         'g' as tip,
         g.grpname as grpname,
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
         0 as NDS
  from GR g 
       inner join #TempPrice a on a.ngrp=g.ngrp or a.mainparent=g.ngrp or a.parent=g.ngrp
  where g.AgInvis=0
          
  union

  /*Весовой товар без набора через терминал и весь штучный товар*/
  select cast(v.hitag as varchar(6)) as code,                         
         'g'+cast(n.ngrp as varchar(3)) as parent,
         't' as tip,
         n.name as grpname,         
         round(max(mn.Price),2) as MinPrice,
         round(max(mn.Price),2) as BasePrice,
         round(max(mn.Price)*1.2,2) as MaxPrice,
         
         max(case when v.[WEIGHT]<>0 and n.flgWeight=1 then ' Цена ' + cast(cast(round(mn.Price,2) as money) as varchar) + 'р/кг'
                  when n.netto<>0 and n.flgWeight=0 then ' Цена ' + cast(cast(round(mn.Price/n.netto,2) as money) as varchar) + 'р/кг'
             else '' end) as Str1kg,
         
         case when (@AllPrice=1) and (cast(sum(v.morn-v.sell-v.bad-v.remov+v.isprav) as integer))=0 then 999
              when n.flgWeight=0 then cast(sum(v.morn-v.sell-v.bad-v.remov+v.isprav) as integer) 
              else sum((v.morn-v.sell-v.bad-v.remov+v.isprav)*cast(v.weight as float)*iif(s.UpWeight=1,n.netto,cast(v.weight as float)))            
         end as Ostat,
         
         case when n.flgWeight=0 
              then cast(max(v.minp) as varchar(5))+':шт:упак' 
              else convert(varchar, cast(max(n.netto) as money), 0)+':кг:шт' end as EdIzm, 
              
         '' as PosColor,

         case when (s.OnlyMinp = 1) or (max(v.minp)=1) 
              then 'b'
              else '' end as Box,
              
         '' as PriorP,
         
         '' as Newt,
         
         case when n.NDS=10 then 1
              when n.NDS=18 then 8
              else 0 end as NDS   
       
      
  from tdvi v join #NeedIDs nid on v.id=nid.id 
              left join nomen n on v.hitag=n.hitag                                
              left join skladlist s on v.sklad=s.skladNo
                          
              outer apply 
              (select max(case when t.[WEIGHT]<>0 and tm.flgWeight=1 then t.Price/t.[WEIGHT] else t.Price end) as Price 
               from tdvi t join #NeedIDs nid on t.id=nid.id 
                           join #TempPrice tm on t.hitag=tm.hitag and t.ncom=tm.ncom 
               where t.hitag=v.hitag)  mn
        
  group by s.OnlyMinp, n.ngrp, v.hitag, n.name, n.prior, n.flgWeight, n.NDS
  
  order by tip,code            
 
end