CREATE PROCEDURE dbo.EloadNcodRests
@ncod int,
@dck int,
@nd datetime
AS
BEGIN
  if datediff(day,@nd,getdate())=0
  begin
  select  v.hitag [КодТовара], 
          nm.name [НаименованиеТовара], 
          v.sklad [Склад],
          sum((v.morn-v.sell+v.isprav-v.remov)*v.price) [Остаток руб.],
          sum((v.morn-v.sell+v.isprav-v.remov)*v.Weight) [Остаток кг.]
  from tdvi v
  inner join skladlist sl on sl.skladno=v.sklad
  inner join nomen nm on nm.hitag=v.hitag
  where v.ncod=@ncod
        and sl.discard=0
        and v.dck=iif(@dck=-1,v.dck,@dck)
  group by v.hitag, nm.name, v.sklad
  having abs(sum((v.morn-v.sell+v.isprav-v.remov)*v.Weight))>=0.010
  order by nm.name
  end
  else
  begin  	
    select v.hitag [КодТовара], 
    			 nm.name [НаименованиеТовара], 
           sum(v.EveningRest*v.price) [Остаток руб.], 
      		 sum(v.EveningRest*v.Weight) [Остаток кг.]
    from MorozArc..ArcVi v
    inner join nomen nm on nm.hitag=v.hitag
    where v.WorkDate= @nd
      		and v.ncod = @ncod
          and v.dck=iif(@dck=-1,v.dck,@dck)
    group by v.hitag, nm.name, v.sklad
    having abs(sum(v.EveningRest*v.Weight))>=0.010
    order by nm.name
  end
END