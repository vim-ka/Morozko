CREATE PROCEDURE ELoadMenager.Eload_NcodRests
@DCKncod varchar(20),
@nd datetime
AS
BEGIN
  declare @dck int
  declare @ncod int   
  if object_id('tempdb..#param') is not null drop table #param
  create table #param (id int identity(1,1) not null,
  										 param int)
  insert into #param(param)
  select value
  from string_split(@DCKncod,';')
  
  select @dck=param from #param where id=1
  select @ncod=param from #param where id=2
  
  if datediff(day,@nd,getdate())=0
  begin
  select  v.hitag [КодТовара], 
          nm.name [НаименованиеТовара], 
          v.sklad [Склад],
          sum((v.morn-v.sell+v.isprav-v.remov)*v.price) [Остаток руб.],
          sum((v.morn-v.sell+v.isprav-v.remov)*v.Weight) [Остаток кг.]
  from dbo.tdvi v
  inner join dbo.skladlist sl on sl.skladno=v.sklad
  inner join dbo.nomen nm on nm.hitag=v.hitag
  where v.ncod=@ncod
        --and sl.discard=0
        and v.dck=iif(@dck=-1,v.dck,@dck)
  group by v.hitag, nm.name, v.sklad
  having abs(sum((v.morn-v.sell+v.isprav-v.remov)*iif(nm.flgWeight=1,v.Weight,1)))>=0.010
  order by nm.name
  end
  else
  begin  	
    select v.hitag [КодТовара], 
    			 nm.name [НаименованиеТовара], 
           sum(v.EveningRest*v.price) [Остаток руб.], 
      		 sum(v.EveningRest*v.Weight) [Остаток кг.]
    from MorozArc..ArcVi v
    inner join dbo.nomen nm on nm.hitag=v.hitag
    where v.WorkDate= @nd
      		and v.ncod = @ncod
          and v.dck=iif(@dck=-1,v.dck,@dck)
    group by v.hitag, nm.name, v.sklad
    having abs(sum(v.EveningRest*iif(nm.flgWeight=1,v.Weight,1)))>=0.010
    order by nm.name
  end
  if object_id('tempdb..#param') is not null drop table #param
END