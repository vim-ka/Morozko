CREATE procedure Guard.CalcActnProgress @day0 datetime, @Day1 datetime, 
  @ClientList varchar(8000)='', -- здесь может быть список покупателей в виде '1001,1002,2000'
  @skipproclist bit=0 -- 1 если нужно использовать и обновлять список уже проанализированных накладных SourceNaklProcList
as
declare @MRID int, @cmd varchar(200), @Fld varchar(10)
begin
  delete from MarketRequestRes where host_name=host_name()
  truncate table Guard.SkipNom
  declare c1 cursor FAST_FORWARD for select ID as MRID from MarketRequest R where R.datefrom<=@day1 and R.dateto>=@day0
  open c1
  fetch next from c1 into @MRID
  while @@fetch_status=0 BEGIN
    EXEC DBO.MarketRequestCalcByAgents @MRID, @DAY0, @DAY1, 0, @skipproclist
    fetch next from c1 into @MRID
  END
  close c1
  deallocate c1
  print('КОНТРОЛЬНАЯ ТОЧКА 1 ПРОЙДЕНА')

  if @ClientList<>'' delete from MarketRequestRes where host_name=host_name() and b_id not in (select k from dbo.Str2intarray(@ClientList));

  if @skipproclist = 1
    insert into SourceNaklProcList select distinct datnom from Guard.SkipNom where datnom not in (select datnom from SourceNaklProcList)  	

  create table #t(ag_id int, b_id int);
  insert into #t select distinct ag_id, b_id from MarketRequestRes where host_name=host_name();

  declare c3 cursor FAST_FORWARD for select distinct mrid from MarketRequestRes where host_name=host_name() order by mrid;
  open c3;
  fetch next from c3 into @mrid;

  while @@fetch_status=0 begin

    set @Fld = 'Ac'+cast(@MRID as varchar);
    set @cmd='alter table #t add '+@Fld+' smallint default 0';
    execute(@cmd)

    set @cmd='update #t set '+@fld+'=(select isnull(sum(Cnt),0) from MarketRequestRes R where R.host_name=host_name() and R.mrid='
        +cast(@mrid as varchar)+' and R.ag_id=#t.ag_id and R.b_id=#t.b_id)';  
    print @cmd
    execute(@cmd)

    fetch next from c3 into @mrid;
  end;
  close c3;
  deallocate c3;

  select * from #t;
end