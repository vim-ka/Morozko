CREATE PROCEDURE MobAgents.MobGetSmartPrice @ag_id int
AS
BEGIN
  
  declare @DepID int, @PLID int, @FirmGroup int, @Our_id int
  set @DepID=(select DepID from agentlist where ag_id=@ag_id)
  
  select @Our_ID = Our_ID , @PLID = PLID  from Deps where DepID=@DepID
  select @FirmGroup=FC.FirmGroup  from FirmsConfig fc where fc.Our_ID=@Our_ID
  
  if @DepID in (0)  --пока только для Крыма
  begin
    /*create table #NeedAg_ID (ag_id int)
  
    insert into #NeedAg_ID (ag_id)
    select a.ag_id from agentlist a where a.sv_ag_id=@ag_id or a.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0)
 */

     
    declare @SkladList varchar(300)
    select @SkladList=
    stuff((select ', '+ cast(l.skladno as varchar(3))
         from skladlist l join SkladGroups g on l.skg=g.skg 
         where g.PLID=@PLID and l.locked=0 and l.agInvis=0 and l.Discard=0 and l.SafeCust=0
         for xml path('')),1,2,'')
    create table #Temp (pin int, hitag int, Price money)
    insert into #Temp (pin, hitag, Price)
    exec [dbo].[GenerPricesNSP2b]  0, @SkladList, 0, 5, '', 0, @ag_id ;
    
    select pin, hitag, Price from #Temp
    union
    
    select d.dck,
           v.hitag,                                 
           round(v.Price,2) as Price
        
    from [MobAgents].GoodForback v join DefContract d on d.ag_id=@ag_id
                                  --join #NeedAg_ID na on na.ag_id=d.ag_id
                                   
    where v.FirmGroup=@FirmGroup 
            and v.PLID=@PLID
    order by 1

  end
  else  -- Заглушка
  select 0 as pin, 0 as Hitag, 0 as Price
  from MobAgents.MobConfig where param='0' 
  order by pin 
  

/*
  declare @SkladList varchar(300)
  select @SkladList=
  stuff((select ', '+ cast(l.skladno as varchar(3))
         from skladlist l where l.locked=0 and l.agInvis=0 and l.Discard=0 and l.SafeCust=0
         for xml path('')),1,2,'')

  exec [dbo].[GenerPricesNSP2b]  0, @SkladList, 0, 5, '', 0, @ag_id ;
*/

END