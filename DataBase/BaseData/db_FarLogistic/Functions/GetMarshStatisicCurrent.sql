CREATE FUNCTION db_FarLogistic.GetMarshStatisicCurrent (@id int, @MarshID int)
RETURNS int
AS
begin
	declare @res int
	set @res=
		(select s.delta 
		from db_FarLogistic.GetMarshStatistic(@MarshID) s
		where s.id=@id)
	return @res
end