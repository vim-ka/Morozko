CREATE PROCEDURE warehouse.terminal_takebacks
@reqretid int,
@op int,
@spk int,
@ids varchar(max) --hitag;cnt;sklad;isnew#hitag1;cnt1;sklad1;isnew1....
AS
BEGIN
	set nocount on  
  declare @tovprice money
  declare @res bit; set @res=0;
  declare @msg varchar(500); set @msg='';
  declare @hitag int
  declare @cnt int
  declare @sklad int
  declare @s_datnom int  
  declare @isnew bit
  declare @id int
  declare @kol int
  declare @weight numeric(12,3)
  declare @sklad_r int
  declare @flgW bit
 	declare @sql varchar(max)
  declare @ttable varchar(50)
  if object_id('tempdb..#lst') is not null drop table #lst
  create table #lst (hitag int, cnt int, sklad int, isnew bit)
  set @ttable='##'+host_name()+'_reqlist'  
  set @sql=''
  set @sql='if object_id(''tempdb..'+@ttable+''') is not null drop table '+@ttable+' '
  set @sql=@sql+' exec nearlogistic.gettablefromstrings '''+@ids+''',''hitag;cnt;sklad;isnew'','';'',''#'','''+@ttable+''''
  set @sql=@sql+' insert into #lst select cast(hitag as int),cast(cnt as int),cast(sklad as int),cast(isnew as bit) from '+@ttable+' '
  set @sql=@sql+' drop table '+@ttable+' '  
  exec(@sql)  
  --select * from #lst
  declare c_lst cursor for 
  select * from #lst order by hitag
  open c_lst
  fetch next from c_lst into @hitag,@cnt,@sklad,@isnew
  while @@fetch_status=0
  begin
  	--if @isnew=0
    begin
			declare c_req cursor for
      select r.kol, r.fact_weight, r.sklad, n.flgWeight, r.id, r.tovprice, r.sourcedatnom
      from dbo.reqreturndet r
      join dbo.nomen n on n.hitag=r.hitag
      where r.reqretid=@reqretid and r.hitag=@hitag and r.done=0
      order by r.sourcedatnom
      --for update of r.fact_kol2, r.fact_weight2, r.sklad, r.done, r.tovprice
      open c_req
      fetch next from c_req into @kol, @weight, @sklad_r, @flgW, @id, @tovprice, @s_datnom
      while @@fetch_status=0 or @cnt>0
      begin
      	if @flgW=1 begin 
        if @weight>@cnt*1.0/1000 set @weight=@cnt*1.0/1000 end
        else if @kol>@cnt set @kol=@cnt
      	update r set r.fact_kol2=iif(@flgW=1,iif(@weight=0,0,r.kol),@kol),
        						 r.tovprice=iif(@flgW=1, (@tovprice/r.fact_weight)*@weight, @tovprice),
                     r.fact_weight2=iif(@flgW=0,r.fact_weight,@weight),
                     r.sklad=iif(@sklad=-1,r.sklad,@sklad),
                     r.done=1                     
        from dbo.reqreturndet r
        --where current of c_req      	
        where r.reqretid=@reqretid and r.hitag=@hitag and r.done=0 and r.sourcedatnom=@s_datnom
        set @cnt=@cnt-iif(@flgW=0,@kol,round(@weight*1000,0))        
        fetch next from c_req into @kol, @weight, @sklad_r, @flgW, @id, @tovprice, @s_datnom
      end
      close c_req
      deallocate c_req
    end
    print '3'
  	fetch next from c_lst into @hitag,@cnt,@sklad,@isnew
  end
  close c_lst
  deallocate c_lst
  if not exists(select 1 from dbo.reqreturndet where reqretid=@reqretid and done=0)
  update q set q.depidcust=9, q.depidexec=29, q.tip2=194, 
               q.otv2=8612, q.rs=5, q.op=iif(@spk>0,709,@op)
  from dbo.requests q  
  where q.rk=@reqretid
  select @res [res], @msg [msg]
  if object_id('tempdb..#lst') is not null drop table #lst
  set nocount off
END