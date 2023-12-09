CREATE FUNCTION dbo.NewSert_id ()
RETURNS int
AS
begin
	declare @res int
	set @res=(select max(sert_id)+1 from sertif)
	return @res
end