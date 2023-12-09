CREATE procedure dbo.Read21822 -- результат работы - список сегодняшних накладных,
-- относящихся к клиентам, которые КУПИЛИ товары "Ортика Фрозен Фудс" с 11.04.2016
-- В том числе и сегодня тоже.
as
declare @StartDay datetime
begin
  create table #t(pin int, dck int);

  -- Это вариант для известного списка товаров:
  insert into #t
  select b_id as Pin,DCK from Maslo 
  UNION
  select distinct nc.b_id as pin, nc.dck
  from
    nc
    inner join nv on nv.datnom=nc.datnom
  where
    nc.nd=dbo.today()
    and nv.kol>0
    and nv.hitag in (25836);

  -- А это вариант для заданного поставщика 1207:    
  /*
  insert into #t
  select b_id as Pin,DCK from Maslo 
     UNION
  select distinct nc.b_id as pin, nc.dck
  from
    nc
    inner join nv on nv.datnom=nc.datnom
    inner join tdvi v on v.id=nv.tekid
  where
    nc.nd=dbo.today()
    and nv.kol>0
    and v.ncod=1207
    */

  -- Итак, в табл. #t все, кто купил масло за последний месяц, включая сегодня.
  -- Теперь надо наложить его на список сегодняшних продаж.
  -- Если покупатель принадлежит списку #t, то его не надо подсвечивать.
  -- Если покупатель не принадлежит списку отделов (1,5,2,33,32,28,39,40), то его тоже не надо подсвечивать.
  -- Если накладная возвратная, то ее тоже не надо подсвечивать.
  -- Всех остальных надо подсвечивать

  select nc.DatNom % 10000 as Nnak
  from 
    nc
    left join #t on #t.dck=nc.dck
    inner join Agentlist A on A.AG_ID=nc.Ag_Id
  WHERE
    nc.nd=dbo.today()
    and nc.sc>0
    and #t.dck is NULL
    and a.DepID in (1,5,2,33,32,28,39,40)






/*
  -- Сейчас в табл. Maslo содержатся покупатели, которые последние три месяца не купили отслеживаемые товары
  -- по состоянию на сегодняшнюю полночь. Список будет скорректирован с учетом сегодняшних продаж.
  set @StartDay=dbo.today()
  if exists(select * from maslo where b_id in (select distinct b_id from nc where nd=@startDay))
    begin
    create table #b (b_id int);

    insert into #b
    select distinct nc.b_id
    from
      nc
      inner join nv on nv.datnom=nc.datnom
    where
      nc.nd>=@StartDay
      and nv.hitag in (23253,23255)
      and nv.kol>0
    order by b_id;
    create index b_temp_idx on #b(b_id);

    select datnom % 10000 as Nnak
    from 
      nc
      inner join Maslo on Maslo.b_id=nc.b_id
      left join #b on #b.b_id=nc.b_id
    where 
      nc.nd=@StartDay
      and nc.sp>0
      and #b.b_id is null
  end 
  else select 0 as nnak;

  */
end;