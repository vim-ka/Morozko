
CREATE view [NearLogistic].[letters_list_new]
as
select row_number() over(order by len(x.value), x.value) [id], cast(x.value as nvarchar(4)) [list] from (
select value from string_split('А\Б\Г\Д\Ж\З\И\К\М\О\П\Р\С\У\Ф\Х\Ч\Ш\Ю\Я','\')
union all
select a.value+b.value
from string_split('А\Б\Г\Д\Ж\З\И\К\М\О\П\Р\С\У\Ф\Х\Ч\Ш\Ю\Я','\') a
join string_split('А\Б\Г\Д\Ж\З\И\К\М\О\П\Р\С\У\Ф\Х\Ч\Ш\Ю\Я','\') b on 1=1
where a.value<>b.value
union all
select a.value+b.value+c.value
from string_split('А\Б\Г\Д\Ж\З\И\К\М\О\П\Р\С\У\Ф\Х\Ч\Ш\Ю\Я','\') a
join string_split('А\Б\Г\Д\Ж\З\И\К\М\О\П\Р\С\У\Ф\Х\Ч\Ш\Ю\Я','\') b on 1=1
join string_split('0\1\2\3\4\5\6\7\8\9','\') c on 1=1
where a.value<>b.value
union all
select a.value+b.value+c.value+d.value
from string_split('А\Б\Г\Д\Ж\З\И\К\М\О\П\Р\С\У\Ф\Х\Ч\Ш\Ю\Я','\') a
join string_split('А\Б\Г\Д\Ж\З\И\К\М\О\П\Р\С\У\Ф\Х\Ч\Ш\Ю\Я','\') b on 1=1
join string_split('0\1\2\3\4\5\6\7\8\9','\') c on 1=1
join string_split('0\1\2\3\4\5\6\7\8\9','\') d on 1=1
where a.value<>b.value
) x
union all 
select 0,'--'