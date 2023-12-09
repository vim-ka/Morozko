CREATE procedure warehouse.operator_cancel_nvzakaz
@datnom bigint,
@nzid int, 
@rem varchar(50),
@op int
as
begin
  set nocount on;
  declare @nzid_ int;
  if object_id('tempdb..#src') is not null drop table #src;
  select * into #src from dbo.nvzakaz 
  where datnom=iif(@nzid=0,@datnom,datnom) and nzid=iif(@nzid=0,nzid,@nzid) and done=1;
  declare crs cursor for
  select nzid from dbo.nvzakaz where datnom=iif(@nzid=0,@datnom,datnom) and nzid=iif(@nzid=0,nzid,@nzid);
  open crs;
  fetch next from crs into @nzid_;
  while @@fetch_status=0
  BEGIN 
  	exec warehouse.terminal_CancelNvZakaz @nzid_,@rem,@op,-1,-1,-1
    fetch next from crs into @nzid_;
  end;
  close crs; deallocate crs;
  insert into dbo.nvzakaz(datnom,hitag,zakaz,comp,id,price,cost,skladno)
  select datnom,hitag,(-1)*zakaz,host_name(),0,price,cost,skladno from #src;
  if object_id('tempdb..#src') is not null drop table #src;
  set nocount off;
end