CREATE procedure dbo.CalcStartDatnom @StartDay datetime='01.07.2017'
as
begin

  update nc set refdatnom=0 where datnom=refdatnom;

--  declare @StartDay as datetime;
--  set @StartDay='01.01.2017';
  
  if object_id('tempdb..#t0') is not null drop table #t0;
  if object_id('tempdb..#t1') is not null drop table #t1;
  if object_id('tempdb..#t2') is not null drop table #t2;
  if object_id('tempdb..#t3') is not null drop table #t3;
  
  create table #t0(N0 int, N1 int);
  create table #t1(N0 int, N1 int);
  create table #t2(N0 int, N1 int);
  create table #t3(N0 int, N1 int);

  insert into #t0(N0,N1) select distinct datnom, refdatnom from nc where refdatnom>0;
  -- insert into #t0(N0,N1) select distinct datnom, refdatnom from nc where nd>=@startday and refdatnom>0;
  create index t0_tmp_idx on #t0(n0);

  insert into #t1 select #t0.n0, z.n1 from #t0 inner join #t0 as Z on Z.N0=#t0.n1;
  create index t1_tmp_idx on #t1(n0);

  insert into #t2 select #t1.n0, z.n1 from #t1 inner join #t0 as Z on Z.N0=#t1.n1;
  insert into #t3 select #t2.n0, z.n1 from #t2 inner join #t0 as Z on Z.N0=#t2.n1;

  update nc set StartDatnom=null where nd>=@StartDay;
  
  update nc set StartDatnom=#t3.n1 from nc inner join #t3 on #t3.n0=nc.datnom where nc.nd>=@StartDay and nc.StartDatnom is null;
  update nc set StartDatnom=#t2.n1 from nc inner join #t2 on #t2.n0=nc.datnom where nc.nd>=@StartDay and nc.StartDatnom is null;
  update nc set StartDatnom=#t1.n1 from nc inner join #t1 on #t1.n0=nc.datnom where nc.nd>=@StartDay and nc.StartDatnom is null;
  update nc set StartDatnom=#t0.n1 from nc inner join #t0 on #t0.n0=nc.datnom where nc.nd>=@StartDay and nc.StartDatnom is null;
  update nc set StartDatnom=Datnom from nc where nc.nd>=@StartDay and nc.StartDatnom is null;
end;