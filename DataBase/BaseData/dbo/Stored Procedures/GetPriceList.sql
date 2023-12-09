CREATE procedure dbo.GetPriceList @ag_id int, @CompName varchar(50)
 /* @Oper int, @Act varchar(4), @SourDate datetime,
  @Nnak int, @Plata money, @Fam varchar(30), 
  @P_ID int, @B_ID int, @V_ID int, @Ncod int,
  @remark varchar(60), @RashFlag tinyint, @LostFlag tinyint,
  @LastFlag tinyint, @Op int, @Bank_ID int,
  @Our_ID int, @BankDay datetime, @Actn tinyint, @Ck tinyint,
  @Thr int, @ThrFam varchar(40), @DocNom int, 
  @ForPrint tinyint, @OrigRecN int, @SourDatNom int, @StNom int, @FromBank_ID smallint, @SkladNo int, @DepID int=0, @Nalog float=0, @RemarkPlat varchar(150)='',
  @pin int=0, @ksid int = 0 out*/
as
begin
  declare @DepID int, @Sv_id int
  declare @AllPrice bit
  set @AllPrice=(select AllPrice from agentlist where ag_id=@ag_id)
  set @sv_id=(select sv_ag_id from agentlist where ag_id=@ag_id)
  set @DepID=(select DepID from agentlist where ag_id=@ag_id)
  
  select g.ngrp as code,g.parent,'g' as tip,isnull(r.Prior+' ','')+g.grpname as grpname, 0 as ostat, 0 as OstatVes,0 as OstatSP,0 as OstatSC,0 as OnlyMinpSklad,0 as PriceCom, 0 as CostCom,
         0 as minp, 0 as sklad, '' as Box, '' as PriorP, '' as Newt, 0 as MainExtra, 0 as Extra, '' as 'ImageName'
  from GR g left join GRPrior r on g.ngrp=r.ngrp and r.DepID=@DepID
  where g.AgInvis=0 and g.MainParent not in (select Ngrp from AgDisPrice where Disable=1 and ag_id=@ag_id) 
          
  union
  
  select /*case when s.OnlyMinp = 1 or (max(v.minp)=1) then v.hitag*10+1 else v.hitag*10 end as code,*/
         v.hitag as code,                         
         n.ngrp as parent,
         't' as tip,
         n.name as grpname,
         case when (@AllPrice=1) and (cast(sum(v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0)) as integer))=0 
              then 999
              else cast(sum(v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0)) as integer) end as Ostat,
         sum((v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0))*cast(v.weight as float)) as OstatVes,
         sum((v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0))*v.Price) as OstatSP,
         sum((v.morn-v.sell-v.bad-v.remov+v.isprav-isnull(z.QTYZakaz,0))*v.Cost) as OstatSC,
         max(distinct cast(v.OnlyMinp as integer)) as OnlyMinpSklad,
         (select max(Price) from tdVi tv where tv.hitag=v.hitag and tv.ncom=(select max(t.ncom) from tdvi t, SkladList s where t.Sklad=s.SkladNo and s.AgInvis=0 and t.hitag=tv.hitag and t.locked=0)) as PriceCom,
         (select max(Cost) from tdVi tv where tv.hitag=v.hitag and tv.ncom=(select max(t.ncom) from tdvi t, SkladList s where t.Sklad=s.SkladNo and s.AgInvis=0 and t.hitag=tv.hitag and t.locked=0)) as CostCom,
         max(v.minp) minp,
         v.sklad,
         case when (s.OnlyMinp = 1) or (max(v.minp)=1) then 'b'
                                  else '' end as Box,
         --case when n.prior>getdate() then 'n' else '' end as PriorP,
         '' as PriorP,--case when isnull(pr.hitag,0) > 0 then 'p' else '' end as PriorP,
         case when isnull(r.hitag,0) > 0 then 'n' else '' end as Newt,
         max(x.MainExtra) as MainExtra,
         max(y.Extra) as Extra,
         'm'+FORMAT(v.hitag,'00000') as 'ImageName'                         
  from tdvi v left join skladlist s on v.sklad=s.skladNo
              left join nomen n on v.hitag=n.hitag                                
              left join 
             (select tekid, sum(Qty) as QTYZakaz from Zakaz  where CompName<>@CompName group by tekid) z on v.id=z.tekid
              left join MtPrior r on r.hitag=v.hitag and (r.DepID=@DepID or r.Sv_id=@Sv_id or r.Ag_id=@Ag_id)
              left join
             (select Ncod, Ngrp, Hitag, Extra as MainExtra from MtMainExtra where ag_id=@ag_id or sv_id=@sv_id or DepID=@DepID) x on x.Ncod=v.Ncod or x.Ngrp=n.Ngrp or x.Hitag=v.Hitag
              left join
             (select m.hitag, max(m.Extra) as Extra from mtExtra m 
               where m.b_id in (select p.pin from planvisit p where p.Ag_id=@ag_id) and m.Extra>0 and m.BegDate>=getdate() and m.EndDate<=getdate() group by m.hitag) y on y.hitag=v.hitag
              /*left join
             (select distinct v.hitag from nv v join nc c on v.datnom=c.datnom where c.nd>=GetDate()-30 and c.ag_id=@ag_id) pr on pr.hitag=v.hitag*/
              /*(select n.hitag from nomen n where n.DateCreate>=GetDate()-30) pr on pr.hitag=v.hitag */ 
    
  where v.locked=0 and s.locked=0 and s.agInvis=0 and s.Discard=0 and           
        n.ngrp not in (select ngrp from gr where AgInvis=1 or MainParent in (select Ngrp from AgDisPrice where ag_id=@ag_id and Disable=1))
  group by s.OnlyMinp, n.ngrp, v.hitag, n.name,v.sklad,n.prior, r.hitag--, pr.hitag            
  union
  select n.hitag as code,                         
         n.ngrp as parent,
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
         1 as sklad,
         '' as Box,
         '' as PriorP,
         'p' as Newt,
         0 as MainExtra,
         0 as Extra,
         '' as ImageName                         

  from nomen n where n.hitag in (94500,94501) 
  order by tip,code            
                                     
end