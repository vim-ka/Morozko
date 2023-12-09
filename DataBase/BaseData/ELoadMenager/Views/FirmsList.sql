CREATE VIEW ELoadMenager.FirmsList
AS
select fc.Our_id [id],fc.OurName [list] from FirmsConfig fc where len(fc.OurName)>1
union 
select -1,'Все фирмы'