CREATE VIEW ELoadMenager.ParamTypeList
AS
select 'dat' [id], 'Дата' [list]
union
select 'ado' , 'Список выбора'
union
select 'str' , 'Строка'
union 
select 'int' , 'Целое число'
union 
select 'bit' , 'Чекбокс'
union 
select 'lst', 'Выбор нескольких'
union 
select 'tm', 'Время'