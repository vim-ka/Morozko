CREATE PROCEDURE dbo.PersonMustFIN
@closed int
AS
BEGIN
  declare @sql varchar(max)

	if object_id('tempdb.dbp.#tmpPsStatCom') is not null 
		drop table #tmpPsStatCom
		
	create table #tmpPsStatCom (p_id int, com varchar(500))

	insert into #tmpPsStatCom
	select 	p.p_id,
	STUFF((	select N'-'+cast(s.must as varchar)+':'+isnull(t.stName,'#')
					from psscores s
					left join psstat t on t.StID=s.StID 
					where s.p_id=p.p_id and s.must<>0
					for xml path(''), type).value('.','varchar(max)'),1,1,'') [com]
	from PsScores p
	where p.Must<>0

	set @sql=''
	set @sql='select p.p_id [Код], p.fio [ФИО], sum(s.must) [Сумма], isnull(c.com,'''') [Расшифровка]'
	set @sql=@sql+' from psscores s'
	set @sql=@sql+' left join person p on p.p_id=s.p_id'
	set @sql=@sql+' left join #tmpPsStatCom c on c.p_id=s.p_id'
	set @sql=@sql+' where p.closed= case when '+cast(@closed as varchar)+'=2 then p.closed else '+cast(@closed as varchar)+' end'
	set @sql=@sql+' group by p.p_id, p.fio, c.com'

	exec(@sql)

	drop table #tmpPsStatCom
END