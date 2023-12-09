CREATE VIEW ELoadMenager.carriers_list
as
select top 100000 crid [id], crname [list] from dbo.carriers where closed=0 order by crname