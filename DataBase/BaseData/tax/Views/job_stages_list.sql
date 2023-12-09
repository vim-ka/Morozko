create view tax.job_stages_list
as
select -1 [id], '' [list]
union select 0,'Call центр'
union select 1,'Бухгалтерия'
union select 2,'Отдел ПДЗ'
union select 3,'Юридический отдел'