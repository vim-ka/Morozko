CREATE PROCEDURE MobAgents.MobGetSmartOrder @ag_id int
AS
BEGIN
  --заглушка  (накладные за последние 3 дня)
 /* select '' as vk,
  0 as status,
  '01.01.01' as nd,
  0 as pin,
  0 as hitag,
  0 as kolvo,
  0 as price
  from MobAgents.MobConfig where param='0' 
  order by vk
  */
  
    
  declare @NeedDay datetime, @StartDatnom bigint
  set @NeedDay=dbo.today()-4;
  set @StartDatnom=dbo.InDatNom(0,@NeedDay);
  create table #NeedDCK (dck int)
  
  insert into #NeedDCK (dck)
  select c.dck from defcontract c where c.ag_id=@ag_id or c.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0)
  union
  select b.add_dck from agaddbases b where b.ag_id=@ag_id and b.add_dck<>0


  select case when isnull(n.DocNom,'')='' or n.sp<0 then cast(n.datnom as varchar(11)) else n.DocNom end as vk,
         case when n.sp=0 then 5 else 4 end as status,
         n.nd,
         '' as datnom, -- n.datnom,пока код учетной системы в TradePoint не используется
         n.dck as pin,
         v.hitag,
         v.kol as kolvo,
         v.price
  from nc n join nv v on n.datnom=v.datnom
            join #NeedDCK e on n.dck=e.dck
  where n.datnom>@StartDatnom and n.tara=0 and n.frizer=0 and n.actn=0
  order by pin,vk

END