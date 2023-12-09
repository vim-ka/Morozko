create procedure eloadmenager.eload_getadditionalto1c
@nd datetime
as
begin
	exec hrmain.dbo.getadditionalto1C @nd
end