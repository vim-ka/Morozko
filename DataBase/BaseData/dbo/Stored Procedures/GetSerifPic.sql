CREATE PROCEDURE dbo.GetSerifPic
@sert_ids varchar(max)
AS
BEGIN
  /*declare @sql varchar(max)
	set @sql='select sert_id,
			 						 SPic							
						from sertifpic 
						where sert_id in ('+@sert_ids+') 
						order by sert_id'
	exec(@sql)*/
	
	declare @sql varchar(max)

	if object_id('tempdb.dbo.#tmpSert') is not null
		drop table #tmpSert

	create table #tmpsert (Sert_id int, SPic image, i integer)
	set @sql='select sert_id,
									 SPic,
									 row_number() over(partition by sert_id order by SPicName )							
						from sertifpic 
						where sert_id in ('+@sert_ids+') and isdel=0' 
	set @sql='insert into #tmpsert '+@sql
			
	exec(@sql)

	declare @cnt int 
	declare @sert_id int

	declare cSert_id cursor for
	select sert_id, count(sert_id) 
	from #tmpsert
	group by sert_id 

	open cSert_id

	fetch next from cSert_id into @sert_id, @cnt

	while @@fetch_status=0
	begin
		if @cnt % 2 <>0
			insert into #tmpsert(sert_id,i) values(@sert_id, @cnt+1)
			
		fetch next from cSert_id into @sert_id, @cnt
	end

	close cSert_id
	deallocate cSert_id

	select sert_id, spic from #tmpsert order by sert_id, i
	drop table #tmpSert
END