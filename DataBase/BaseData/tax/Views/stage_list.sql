CREATE view tax.stage_list
as
select -1 [id], 'не обработан' [list],0 [deep], 999999 [deep_out]
union select 0,'бухгалтерия',5,30
union select 1,'юрист',30,999999