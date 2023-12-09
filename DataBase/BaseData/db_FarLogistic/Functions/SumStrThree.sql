CREATE function db_FarLogistic.[SumStrThree] ( @Summa varchar(4000), @TempValue bigint, @Rod int, @w1 varchar(40), @w2to4 varchar(40), @w5to10 varchar(40) )
RETURNS @tab TABLE ( Txt varchar(4000), Rest bigint )
as begin
/*
— — Формирования строки для трехзначного числа:
— (последний трех знаков TempValue
— Eсли нужно оперировать с числами > 2 147 483 647
— замените в описании на TempValue AS DOUBLE
--====================================
*/

declare @Rest int, @Rest1 int, @EndWord varchar(100), @s1 varchar(40), @s10 varchar(40), @s100 varchar(40)
set @Rest = @TempValue % 1000
set @TempValue = @TempValue / 1000

If @Rest = 0 begin 
If @Summa = '' 
set @Summa = @w5to10 + ' '
insert into @tab
select @Summa, @TempValue 
return
End 

set @EndWord = @w5to10

Select @s100 = Case @Rest / 100
when 0 then ''
when 1 then 'сто '
when 2 then 'двести '
when 3 then 'триста '
when 4 then 'четыреста '
when 5 then 'пятьсот '
when 6 then 'шестьсот '
when 7 then 'семьсот '
when 8 then 'восемьсот '
when 9 then 'девятьсот '
End 


set @Rest = @Rest % 100
set @Rest1 = @Rest / 10
set @s1 = ''
Select @s10 = Case @Rest1
when 0 then ''
when 1 then 
Case @Rest
when 10 then 'десять '
when 11 then 'одиннадцать '
when 12 then 'двенадцать '
when 13 then 'тринадцать '
when 14 then 'четырнадцать '
when 15 then 'пятнадцать '
when 16 then 'шестнадцать '
when 17 then 'семнадцать '
when 18 then 'восемнадцать '
when 19 then 'девятнадцать '
End 
when 2 then 'двадцать '
when 3 then 'тридцать '
when 4 then 'сорок '
when 5 then 'пятьдесят '
when 6 then 'шестьдесят '
when 7 then 'семьдесят '
when 8 then 'восемьдесят '
when 9 then 'девяносто '
End 
If @Rest1 <> 1 begin 

if @Rest % 10 = 1
set @EndWord = @w1
else if @Rest % 10 between 2 and 4
set @EndWord = @w2to4

Select @s1 = Case @Rest % 10
when 0 then ''
when 1 then
Case @Rod
when 1 then 'один '
when 2 then 'одна '
when 3 then 'одно '
End

when 2 then
Case 
when @Rod = 2 
then 'две '
else 'два '
End
when 3 then 'три '
when 4 then 'четыре '
when 5 then 'пять '
when 6 then 'шесть '
when 7 then 'семь '
when 8 then 'восемь '
when 9 then 'девять '
End
End 

insert into @Tab
select Txt = RTrim(RTrim( @s100 + @s10 + @s1 + @EndWord) + ' ' + @Summa), @TempValue

return
End