CREATE procedure dbo.FillMaslo 
as begin
  -- Концепция изменилась. 
  -- составим список покупателей, которые покупали отслеживаемый товар за последний месяц:
  truncate table Maslo;

  -- Это вариант для заданного списка кодов товаров:
  insert into Maslo 
  select distinct nc.b_id as pin, nc.dck
  from
    nc
    inner join nv on nv.datnom=nc.datnom
  where
    -- nc.nd>=dateadd(MONTH, -1, getdate())
    nc.nd>='20160410'
    and nv.kol>0
    and nv.hitag in (25836);

  -- А это вариант для заданного поставщика:
  /*
  insert into Maslo
  select distinct nc.b_id as pin, nc.dck
  from
    nc
    inner join nv on nv.datnom=nc.datnom
    inner join visual v on v.id=nv.tekid
  where
    nc.nd>='20160411'
    and nv.kol>0
    and v.ncod=1207
  */    



/*  
  select distinct nc.b_id
  from
    nc
    inner join nv on nv.datnom=nc.datnom
  where
    nc.nd>=dateadd(MONTH, -2, getdate()) and nc.nd<=dateadd(MONTH, -1, getdate())
    and nv.kol>0
    and nv.hitag in (12674,13131)--(25255,25253)
  order by b_id;
  
  



  -- Список покупателей, которые покупали масло от 1 до 2 месяцев назад:
  create table #t(b_id int);
  insert into #t
  select distinct nc.b_id
  from
    nc
    inner join nv on nv.datnom=nc.datnom
  where
    nc.nd>=dateadd(MONTH, -2, getdate()) and nc.nd<=dateadd(MONTH, -1, getdate())
    and nv.kol>0
    and nv.hitag in (12674,13131)--(25255,25253)
  order by b_id;

  -- Список покупателей, которые покупали масло 1 месяц назад или позже
  create table #x(b_id int);
  insert into #x
  select distinct nc.b_id
  from
    nc
    inner join nv on nv.datnom=nc.datnom
  where
    nc.nd>dateadd(MONTH, -1, getdate())
    and nv.hitag in (12674,13131)
  order by b_id;
  -- Разница между теми и другими - это те, кто купил масло 1-2 месяца назад и больше покупал:  
  truncate table Maslo;
  insert into Maslo select * from #t EXCEPT select * from #x;
*/
  
end;