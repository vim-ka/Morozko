CREATE function db_FarLogistic.SumStr(@Source bigint, @Rod int, @w1 varchar(40), @w2to4 varchar(40), @w5to10 varchar(40) )
returns varchar(4000)
as begin

/*
— — 'Сумма прописью':
— преобразование числа из цифрого вида в символьное
— ==================================================
— Исходные данные:
— Source — число от 0 до 2147483647 (2^31-1)
— Eсли нужно оперировать с числами > 2 147 483 647
— замените описание переменных Source и TempValue на 'AS DOUBLE'
— — далее нужно задать информацию о единице изменения
— Rod% = 1 — мужской, = 2 — женский, = 3 — средний
— название единицы изменения:
— w1bigint — именительный падеж единственное число (= 1)
— w2to4bigint — родительный падеж единственное число (= 2-4)
— w5to10bigint — родительный падеж множественное число ( = 5-10)
— — Rod% должен быть задано обязательно, название единицы может быть
— не задано = ''
— ———————————————-
— Результат: Summa bigint — запись прописью
— --================================
*/
declare @Summa varchar(4000)
declare @TempValue bigint
If @Source = 0 begin
set @Summa = 'ноль ' + RTrim(@w5to10)
return @Summa
end

select @TempValue = @Source, @Summa = ''

select @Summa = Txt, @TempValue = Rest from db_FarLogistic.SumStrThree( @Summa, @TempValue, @Rod, @w1, @w2to4, @w5to10)
If @TempValue = 0 return @Summa

select @Summa = Txt, @TempValue = Rest from db_FarLogistic.SumStrThree( @Summa, @TempValue, 2, 'тысяча', 'тысячи', 'тысяч')
If @TempValue = 0 return @Summa

select @Summa = Txt, @TempValue = Rest from db_FarLogistic.SumStrThree( @Summa, @TempValue, 1, 'миллион', 'миллиона', 'миллионов')
If @TempValue = 0 return @Summa

select @Summa = Txt, @TempValue = Rest from db_FarLogistic.SumStrThree( @Summa, @TempValue, 1, 'миллиард', 'миллиарда', 'миллиардов')
If @TempValue = 0 return @Summa

select @Summa = Txt, @TempValue = Rest from db_FarLogistic.SumStrThree( @Summa, @TempValue, 1, 'трилллион', 'триллиона', 'триллионов')

return @Summa

End;