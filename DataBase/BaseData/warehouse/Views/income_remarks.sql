create view warehouse.income_remarks
as 
select 0 [id], '' [list]
union select 1,'Излишки'
union select 2,'Недостача'
union select 3,'Малый остаток срока реализации'
union select 4,'Брак'
union select 5,'Просрочено'