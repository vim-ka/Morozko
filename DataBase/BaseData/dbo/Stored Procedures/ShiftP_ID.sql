CREATE PROCEDURE dbo.ShiftP_ID
@ids varchar(100),
@p_id int
AS
declare @tranname varchar(10)
set @tranname='ShiftP_ID'
begin tran @tranname	
	declare @er int 
	set @er=0
	declare @sql varchar(500)
	declare @tName varchar(100)
	declare @sName varchar(100)
	declare @tobj int
	declare cTableNames cursor for 
	select 	object_name(object_id) [tname],
					object_id 
	from sys.columns 
	where lower(name)='p_id' and 
				patindex('%psscores%', lower(object_name(object_id)))=0 and 
				patindex('%_del%', lower(object_name(object_id)))=0 and 
				patindex('%log%', lower(object_name(object_id)))=0 and 
				patindex('%PersonNewWave%', lower(object_name(object_id)))=0
				
	open cTableNames 

	fetch next from cTableNames into @tName, @tobj

	while @@fetch_status=0 
	begin
		if patindex('person', lower(@tName))<>0
		begin
      select @sName=name 
			from sys.schemas 
			where schema_id in (
												select schema_id
												from sys.tables  
												where object_id=@tobj)    
 			set @sql=''
			set @sql='update [MorozData].['+@sName+'].['+@tName+'] set closed=1, dubl=1 where p_id in ('+@ids+')'
			exec(@sql)
			set @er=@er+@@error
			set @sql=''
			set @sql='update [MorozData].['+@sName+'].['+@tName+'] set closed=0, dubl=0 where p_id='+cast(@p_id as varchar)
			exec(@sql)
			set @er=@er+@@error
      print @sName+'.'+@tName
		end
		else
		begin					
      select @sName=name 
			from sys.schemas 
			where schema_id in (
												select schema_id
												from sys.tables  
												where object_id=@tobj)
												
			if patindex('kassa1', lower(@tName))<>0
			begin      	
				set @sql=''
				set @sql='update [MorozData].[dbo].kassa1 set pin=p_id where p_id in ('+@ids+','+cast(@p_id as varchar)+')'				
        exec(@sql)        
				set @er=@er+@@error
			end
												
			set @sql=''
			set @sql='update [MorozData].['+@sName+'].['+@tName+'] set p_id='+cast(@p_id as varchar)+' where p_id in ('+@ids+')'
			print @sName+'.'+@tName
			exec(@sql)
			set @er=@er+@@error
		end 
		
		fetch next from cTableNames into @tName, @tobj
	end 

	close cTableNames
	deallocate cTableNames
	
	

if @er=0 
	begin  	
		commit tran @tranname
    exec dbo.ShiftStNom @p_id
		insert into ShiftP_ID_LOG (IDS, P_ID, FIO)
		values (@ids, @p_id, (select fio from person where p_id=@p_id))
		print 'Успех'
	end
else
	begin
		rollback tran @tranname
		print 'Откат'
	end