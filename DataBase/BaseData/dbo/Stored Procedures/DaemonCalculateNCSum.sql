CREATE procedure dbo.DaemonCalculateNCSum
as
begin
	set nocount on
  declare @dn int 
  if object_id('tempdb..#tSums') is not null drop table #tSums
  
  if datepart(hh,getdate())=01
    set @dn=morozdata.dbo.InDatNom(0,dateadd(day,-1,getdate()))
  else
    set @dn=morozdata.dbo.InDatNom(0,getdate())

  select c.datnom, 
  			 c.b_id,
         isnull(sum(v.kol*v.price)*(1.0+c.Extra/100.0),0) sp, 
         isnull(sum(v.kol*v.cost),0) sc,
         c.sp [Price],
         c.sc [Cost]
  into #tSums
  from  morozdata.dbo.nc c left join morozdata.dbo.nv v with (index(nv_datnom_idx)) on c.datnom=v.datnom
  where c.datnom>=@dn 
  group by c.datnom,c.b_id,c.extra,c.sp,c.sc

  create index idx_sums_datnom on #tSums(datnom)
  
  alter table #tSums add need bit not null default 0
  
  update #tSums set need=iif((abs(sp-price)>0.01)or(abs(sc-cost)>0.01),1,0)
  
  update #tSums set need=iif(exists(select 1 from #tSums x where x.b_id=#tSums.b_id and need=1),1,0)
  
  delete from #tSums where need=0
  
  alter table #tSums add done bit not null default 0
  
  update #tSums set done=iif((exists(select 1 from #tSums x where x.b_id=#tSums.b_id group by b_id having sum(x.sp)>0))or(sp<0),1,0)  
  
  update morozdata.dbo.nc set sp=s.sp, 
  														sc=s.sc, 
                              done=1 --iif(s.done=1,1,c.done)
  from morozdata.dbo.nc c 
  inner join #tSums s on s.datnom=c.datnom
  
  if object_id('tempdb..#tSums') is not null drop table #tSums  
  set nocount off
end