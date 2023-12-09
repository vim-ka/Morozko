CREATE view tax.job_types_list
as
select 0 [id], 'Звонок' [list], cast(0 as bit) [tech_job]
union select 1, 'Недозвон', cast(0 as bit)
union select 2, 'Старт работ', cast(1 as bit)
union select 3, 'Конец работ', cast(1 as bit)
union select 4, 'Изменение этапа', cast(1 as bit)
union select 5, 'Вывод из сети', cast(1 as bit)
union select 6, 'Отказ платить', cast(0 as bit)