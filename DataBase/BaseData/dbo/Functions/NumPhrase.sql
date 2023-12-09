

/*************************************************************************/
/*                  NumPhrase function for MSSQL2000                     */
/*                   Gleb Oufimtsev (dnkvpb@nm.ru)                       */
/*                       http://www.gvu.newmail.ru                       */
/*                          Moscow  Russia  2001                         */
/*************************************************************************/
CREATE function [dbo].[NumPhrase] (@Num BIGINT, @IsMaleGender bit=1)
returns nvarchar(255)
as
begin
  declare @nword nvarchar(255), @th tinyint, @gr smallint, @d3 tinyint, @d2
tinyint, @d1 tinyint
  if @Num<0 return '*** Error: Negative value' else if @Num=0 return N'Ноль'
/* особый случай */
  while @Num>0
  begin
    set @th=IsNull(@th,0)+1    set @gr=@Num%1000    set @Num=(@Num-@gr)/1000
    if @gr>0
    begin
      set @d3=(@gr-@gr%100)/100
      set @d1=@gr%10
      set @d2=(@gr-@d3*100-@d1)/10
      if @d2=1 set @d1=10+@d1
      set @nword=case @d3
                  when 1 then N' сто' when 2 then N' двести' when 3 then N'триста'
                  when 4 then N' четыреста' when 5 then N' пятьсот' when 6
then N' шестьсот'
                  when 7 then N' семьсот' when 8 then N' восемьсот' when 9
then N' девятьсот' else '' end
                +case @d2
                  when 2 then N' двадцать' when 3 then N' тридцать' when 4
then N' сорок'
                  when 5 then N' пятьдесят' when 6 then N' шестьдесят' when 7
then N' семьдесят'
                  when 8 then N' восемьдесят' when 9 then N' девяносто' else
'' end
                +case @d1
                  when 1 then (case when @th=2 or (@th=1 and
@IsMaleGender=0) then N' одна' else N' один' end)
                  when 2 then (case when @th=2 or (@th=1 and
@IsMaleGender=0) then N' две' else N' два' end)
                  when 3 then N' три' when 4 then N' четыре' when 5 then N'пять'
                  when 6 then N' шесть' when 7 then N' семь' when 8 then N'восемь'
                  when 9 then N' девять' when 10 then N' десять' when 11 then
N' одиннадцать'
                  when 12 then N' двенадцать' when 13 then N' тринадцать' when
14 then N' четырнадцать'
                  when 15 then N' пятнадцать' when 16 then N' шестнадцать'
when 17 then N' семнадцать'
                  when 18 then N' восемнадцать' when 19 then N' девятнадцать'
else '' end
                +case @th
                  when 2 then N' тысяч'     +(case when @d1=1 then N'а' when
@d1 in (2,3,4) then N'и' else ''   end)
                  when 3 then ' миллион' when 4 then N' миллиард' when 5 then
N' триллион' when 6 then N' квадрилион' when 7 then N' квинтилион'
                  else '' end
                +case when @th in (3,4,5,6,7) then (case when @d1=1 then ''
when @d1 in (2,3,4) then N'а' else N'ов' end) else '' end
                +IsNull(@nword,'')
    end
  end
  return upper(substring(@nword,2,1))+substring(@nword,3,len(@nword)-2)
end