CREATE procedure warehouse.terminal_get_cancel_remark
@nzid int
as
begin
	select *, 
  			 case when crid=3 then 255 
         else 0 end [crColor]
  from (
	select row_number() over(order by value) [crID], value [crName] 
  from string_split('Малый остаток,Поздняя заявка,Товар испорчен',',')) x
end