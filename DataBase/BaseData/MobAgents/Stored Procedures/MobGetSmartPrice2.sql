CREATE PROCEDURE MobAgents.MobGetSmartPrice2 @ag_id int
AS
BEGIN


 /* declare @DepID int, @PLID int, @sv_id int
  set @DepID=(select DepID from agentlist where ag_id=@ag_id)
  set @PLID=(select PLID from Deps where DepID=@DepID)

  
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
  
  
  if @DepID = 43 --or @DepID = 26 --пока только для Крыма
  begin
    declare @SkladList varchar(300)
    select @SkladList=
    stuff((select ', '+ cast(l.skladno as varchar(3))
         from skladlist l join SkladGroups g on l.skg=g.skg 
         where g.PLID=@PLID and l.locked=0 and l.agInvis=0 and l.Discard=0 and l.SafeCust=0
         for xml path('')),1,2,'')

    exec [dbo].[GenerPricesNSP2b]  0, @SkladList, 0, 5, '', 0, @ag_id ;
  
  
--  iif(isnull(r.ord,0) = 0, '', cast(r.ord as varchar(5)))+':'+dbo.IntToColorHTML(r.clr) as PosColor,
  
  end
  else*/  -- Заглушка
  
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