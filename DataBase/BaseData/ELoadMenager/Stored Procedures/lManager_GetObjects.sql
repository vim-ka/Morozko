CREATE PROCEDURE ELoadMenager.lManager_GetObjects
@tags varchar(1000),
@user_id int = -1,
@isChg bit = 0,
@isDel bit = 0,
@isFolder bit = 1,
@FilterName varchar(50) = ''
as 
begin
	declare @isMorozko bit = 0
  set @isMorozko=cast(iif(@user_id<>40,1,0)as bit) --гостевой доступ
  
  if object_id('tempdb..#resTree') is not null drop table #resTree
  if object_id('tempdb..#tag') is not null drop table #tag
  
  create table #tag (tag_id int)
  
  if @tags<>''
  	insert into #tag 
  	select value from string_split(@tags,',')
  
  create table #resTree (id int, parentID int, name varchar(50), description varchar(1000), date_publish datetime, 
  											 date_lastuse datetime, date_lastprint datetime, isdel bit, isfolder bit, imgindex int, imgstate int, isPrint bit not null default 0)
	--выбор папок
  insert into #resTree                          
  select o.id,
  			 o.ParentID,
         o.Name,
         o.Description,
         o.Date_publish,
         o.Date_lastuse,
         o.Date_lastprint,
         o.isDel,
         o.isFolder,
         0 [imgIndex],
         -1 [imgState],
         0           
  from ELoadMenager.objects o 
  where ((o.isFolder=1 and @isFolder=1) or (@isChg=1 and o.isFolder=1))
        and o.isDel=iif(@isChg=1,o.isDel,@isDel)
  
  --выбор общедоступных выгрузок  
  insert into #resTree                          
  select o.id,
  			 o.ParentID,
         o.Name,
         o.Description,
         o.Date_publish,
         o.Date_lastuse,
         o.Date_lastprint,
         o.isDel,
         o.isFolder,
         1 [imgIndex],
         -1 [imgState],
         0           
  from ELoadMenager.objects o
  join ELoadMenager.users_to_objects uo on uo.object_id=o.id
  where o.isFolder=0
  			and (@isMorozko=1 or @user_id=0)
  			and uo.user_id=-1
  			and o.isDel=iif(@isChg=1,o.isDel,@isDel)
        and (o.id in (select t.object_id from ELoadMenager.tags_to_objects t inner join #tag g on g.tag_id=t.tag_id) or @tags='' or @isChg=1)
  
  --выбор именных выгрузок
  if @user_id<>-1
  insert into #resTree                          
  select distinct
  			 o.id,
  			 o.ParentID,
         o.Name,
         o.Description,
         o.Date_publish,
         o.Date_lastuse,
         o.Date_lastprint,
         o.isDel,
         o.isFolder,
         1 [imgIndex],
         0 [imgState],
         0          
  from ELoadMenager.objects o
  join ELoadMenager.users_to_objects uo on uo.object_id=o.id
  where o.isFolder=0
        and uo.user_id=iif(@user_id=0,uo.user_id,@user_id)
        and not uo.object_id in (select id from #resTree)
        and o.isDel=iif(@isChg=1,o.isDel,@isDel)
        and (o.id in (select t.object_id from ELoadMenager.tags_to_objects t inner join #tag g on g.tag_id=t.tag_id) or @tags='' or @isChg=1)
  
  if @isChg=1
  	insert into #resTree
  	select 0,-1,'Все','',null,null,null,0,1,0,-1,0
  
  update r set isPrint=1
  from #resTree r 
  where r.id in (select object_id from reports)
    
  if @isChg=0 
  begin
  	if @FilterName<>''
    	delete from #resTree where isfolder=0 and not name+' '+description like @FilterName
      
    delete from #resTree where not id in (select parentID from #resTree) and isfolder=1
  end
  
  select * from #resTree order by name, isFolder
  
  if object_id('tempdb..#tag') is not null drop table #tag
  if object_id('tempdb..#resTree') is not null drop table #resTree
END