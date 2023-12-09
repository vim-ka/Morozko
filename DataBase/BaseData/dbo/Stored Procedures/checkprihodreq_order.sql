CREATE PROCEDURE dbo.checkprihodreq_order
@prihodrid int
AS
begin
	set nocount on
  if object_id('tempdb..#prd_ord') is not null drop table #prd_ord

	declare @res bit
  declare @msg varchar(3000)
   
  declare @ordid int
  declare @status int
  declare @Allow bit
  
  set @res=0
  set @msg=''
  /*
  select @ordid=prihodrordersid,
  			 @allow=prihodrallow,
         @status=prihodrdone
  from dbo.prihodreq 
  where prihodrid=@prihodrid
  
  if @status=20 and @allow=0 and @ordid>0 --статус перед закрытием, не разрешен, по заявке закупки
  begin
  	select * into #prd_cnt from (
    select p.prihodrdethitag [hitag],
    			 n.name,
           n.flgweight [isWeight],
           sum(iif(n.flgweight=1,p.prihodrdetweigth*p.prihodrdetkol,p.prihodrdetkol)) [kolPrihod],
           o.[cnt] [kolOrder]
    from dbo.prihodreqdet p
    join dbo.nomen n on n.hitag=p.prihodrdethitag
    left join ( select o.hitag,
    									 sum(iif(n.flgweight=1,o.weight*o.qty,o.qty)) [cnt] 
                from dbo.orddet o
                join dbo.nomen n on n.hitag=o.hitag
                where o.ordid=@ordid
                group by o.hitag
                ) o on o.hitag=n.hitag
    where p.prihodrid=@prihodrid
    group by p.prihodrdethitag, n.name, n.flgweight, o.[cnt]) x
    where (x.[isweight]=0 and x.[kolprihod]-x.[kolorder]<>0)
    			or(x.[isweight]=1 and abs(x.[kolprihod]-x.[kolorder])>x.[kolorder]*0.1)
          or x.[kolorder] is null
    --проверка на несоответствие количества номенклатуры
    select @msg=iif(a.[cntPrihod]<>a.[cntOrder],
    								'Номенклатурных позиций в приходе='+cast(a.[cntPrihod] as varchar)+', в заявке='+cast(a.[cntOrder] as varchar)+';',
                    '')+char(10)+char(13)
    from (
    select (select count(distinct prihodrdethitag) from dbo.prihodreqdet p where p.prihodrid=@prihodrid) [cntPrihod],
    			 (select count(distinct hitag) from dbo.orddet o where o.ordid=@ordid) [cntOrder]) a
    --если есть расхождения в количестве 
   	if exists(select 1 from #prd_cnt) 
   	set @msg=@msg+
    				 stuff((select N''+cast([hitag] as varchar)+' '+[name]+' пр='+cast([kolprihod] as varchar)+'; зк='+cast(isnull([kolorder],0) as varchar)+char(10)+char(13)
               		  from #prd_cnt 
               		  order by name 
               			for xml path(''), type).value('.','varchar(max)'),1,0,'')		                     
  	set @res=iif(@msg<>'',1,0)
  end
  */
  select @res [res], @msg [msg]
  if object_id('tempdb..#prd_ord') is not null drop table #prd_ord
  set nocount off
end