

CREATE PROCEDURE ELoadMenager.Eload_NakInMarsh
@nd datetime,
@marsh int
AS
BEGIN
select c.datnom % 10000 [НомерНаклдной],
			 c.b_id [КодПокупателя],
       c.Fam [НаименованиеПокупателя],
       c.sp [Сумма, руб.],
       c.Weight [Вес, кг.],
       c.Ag_Id [КодАгента],
       d.Reg_ID [КодРегиона],
       c.Tomorrow [НаЗавтра]
from nc c
inner join def d on d.pin=c.b_id
where c.nd=@nd
			and c.marsh=@marsh
END