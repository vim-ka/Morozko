CREATE PROCEDURE dbo.ELoadGetFinRentab
@ngrps varchar(500) ='',
@hitags varchar(500) ='',
@FirmsGroup int =7,
@isGrouping bit =1,
@dt1 datetime,
@dt2 datetime  
AS
BEGIN
	declare @sql varchar(max)
  declare @dt varchar(500)
  set @dt=''
  
  create table #days (dt datetime)
  
  while @dt1<=@dt2
  begin
  	insert into #days values(@dt1)
    
    if @dt=''
    	set @dt='['+convert(varchar,@dt1,104)+']'
    else
    	set @dt=@dt+',['+convert(varchar,@dt1,104)+']'
      
    set @dt1=dateadd(day,1,@dt1)
  end
  
  CREATE NONCLUSTERED INDEX days_idx ON #days(dt)
  
  create table #ngrps (ngrp int)
  if @ngrps=''
  	insert into #ngrps
  	select ngrp
    from gr 
    where AgInvis=0
  else
  begin
  	set @sql='insert into #ngrps select '+replace(@ngrps,',',' union all select ')
    exec(@sql)
  end
  
  CREATE NONCLUSTERED INDEX ngrp_idx ON #ngrps(ngrp)
  
  create table #hitags (hitag int)
  if @hitags=''
  	insert into #hitags
  	select hitag
    from nomen n
    inner join #ngrps g on g.ngrp=n.ngrp
  else
  begin
  	set @sql='insert into #hitags select '+replace(@hitags,',',' union all select ')
    exec(@sql)
  end
  
  CREATE NONCLUSTERED INDEX hitag_idx ON #hitags(hitag)
  
  create table #resultHead (id int, 
  													name varchar(50))
  
  if @hitags<>''
  	insert into #resultHead
    select n.hitag,n.name
    from nomen n
    inner join #hitags t on n.hitag=t.hitag
  else
  	insert into #resultHead
    select g.ngrp,g.GrpName
    from gr g
    inner join #ngrps t on g.ngrp=t.ngrp
    
  CREATE NONCLUSTERED INDEX head_idx ON #resultHead(id)
    
  select v.*
  into #tmpVI
  from morozarc.dbo.ArcVI v
  --/*
  inner join #hitags on #hitags.hitag=v.Hitag
  inner join #days on #days.dt=v.WorkDate
  inner join FirmsConfig f on f.Our_id=v.Our_ID
  where f.FirmGroup=@FirmsGroup
  --*/
  /*
  where v.hitag in (select hitag from #hitags)
      	and v.Our_ID in (select f.our_id from FirmsConfig f where f.FirmGroup=@FirmsGroup)
      	and v.WorkDate in (select dt from #days)
  */
  select id,
         convert(varchar,dt,104) [dt],
         isnull(sum(x.rest),0) [rest],
         isnull(sum(x.sold),0) [sold]
  into #tmp 
  from (select iif(@hitags='',n.ngrp,n.hitag) [id],
               v.WorkDate [dt],
               v.MornRest*iif(v.Weight<>0,v.Weight,n.Netto) [Rest],
               (select sum(nv.kol*iif(Visual.weight=0,nomen.netto,Visual.weight)) 
               	from nv 
                inner join nc on nc.datnom=nv.datnom 
                inner join nomen on nomen.hitag=nv.hitag
                inner join visual on nv.tekid=visual.id 
                where nc.nd=v.WorkDate 
                			and nv.hitag=v.hitag 
                      and nc.stip<>4) [Sold]
        from #tmpVI v
        inner join FirmsConfig f on f.Our_id=v.our_id
        inner join nomen n on n.hitag=v.hitag 
        ) x
  group by x.id,x.dt    
  
  create table #resultOborot (id int, 
  													  dt varchar(100), 
                              Val decimal(10,3))
  
  insert into #resultOborot
  select id,
  			 'Итого',
         iif(isnull(sum(sold),0)=0,0,sum(rest)/sum(sold))
  from #tmp
  group by id
  
  if @isGrouping=0
  begin
  	insert into #resultOborot
    select id,
           dt,
           iif([sold]=0,0,[rest]/[sold])
    from #tmp
  end
  
  CREATE NONCLUSTERED INDEX oborot_idx ON #resultOborot(id)
  
  set @sql=''
  set @sql='select id, name, '+iif(@isGrouping=0,@dt+', ','')+'[Итого] from '
  set @sql=@sql+'(select #resultHead.id,name,dt,Val from #resultHead inner join #resultOborot on #resultOborot.id=#resultHead.id) as src '
  set @sql=@sql+'pivot(sum(Val) for dt in ('+iif(@isGrouping=0,@dt+', ','')+'[Итого])) as pvt '
  --print @sql
  exec(@sql)
  
  --select * from #resultHead
  --select * from #resultOborot
  
  drop table #hitags
  drop table #ngrps
  drop table #days
  drop table #resultHead
  drop table #resultOborot
  drop table #tmp
  drop table #tmpVI
END