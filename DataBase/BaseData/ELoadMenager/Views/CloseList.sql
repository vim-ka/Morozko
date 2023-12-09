CREATE VIEW ELoadMenager.CloseList
AS
select 0 [id], 'Открытые' [list] union select 1, 'Закрытые' union select 2, 'Все'