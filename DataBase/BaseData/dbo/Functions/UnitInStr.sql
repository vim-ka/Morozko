CREATE FUNCTION dbo.UnitInStr (@kol varchar(10), @minp int)
RETURNS varchar(10)
WITH EXECUTE AS CALLER
AS
begin
  /*
return 	case when cast(@kol as int) % @minp =0 
				then	cast(cast(@kol as int) / @minp as varchar(10))
        else 	cast(cast(cast(@kol as int) / @minp as varchar(10))+'+'+cast(cast(@kol as int) % @minp as varchar(10)) as varchar(10)) end
end
  */


  DECLARE @fract DECIMAL(18,4), @z INT 
  SET @z = CAST(CAST(@kol AS FLOAT) as int)
  SET @fract = CAST(@kol AS FLOAT) - FLOOR(CAST(@kol AS FLOAT))
  
  return  case WHEN @z%@minp = 0 
  				THEN CAST(@z/@minp as varchar(10))  
               + IIF(@fract = 0, '', '+'+ CAST(@fract AS varchar(10)))
          else cast(cast(@z / @minp as varchar(10)) + '+'
               + cast(cast(CAST(@kol AS FLOAT) as int) % @minp + @fract as varchar(10)) as varchar(10))
          end
end