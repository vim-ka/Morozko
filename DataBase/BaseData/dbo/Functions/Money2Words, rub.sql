create function dbo.[Money2Words, rub]( @Money money )
returns varchar(max)
as begin 

declare @Source bigint
declare @minus varchar(10)
declare @sum varchar(max)

if @Money < 0 begin
set @minus = 'Минус '
set @Money = -@Money
end else
set @minus = ''

declare @Cent int, @CentTxt varchar(20)

set @Source = floor(@Money )

set @Cent = (@Money - 1. * @Source ) * 100
set @sum = @Minus + dbo.SumStr( @source, 1, 'рубль', 'рубля', 'рублей' )

if @Cent < 10
set @CentTxt = ' 0' + convert(varchar, @Cent) + ' коп.'
else
set @CentTxt = ' ' + convert(varchar(3), @Cent) + ' коп.'

set @sum = Upper( SubString( @sum,1,1) ) + SubString( @sum, 2, len(@sum)-1) + @CentTxt
return @sum
end