CREATE FUNCTION dbo.SellDays (@B_ID int, @ND datetime
)
RETURNS varchar(20)
AS
BEGIN
declare	@s varchar(20)

select @s=isNull(@s + ', ', '') + 
 (CASE datepart(dw, nd)
  WHEN 1 THEN 'пн'
  WHEN 2 THEN 'вт'
  WHEN 3 THEN 'ср'
  WHEN 4 THEN 'чт'
  WHEN 5 THEN 'пт'
  WHEN 6 THEN 'сб'
  WHEN 7 THEN 'вс'
 END ) 
   from nc
   where b_id =@B_ID and
         nd between (@ND - (datepart(dw, @ND))) and  @ND
         and sp>0 
   
   order by nd
   set @s = isnull(@s,'')
   return @s
END