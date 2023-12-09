create procedure nearlogistic.create_casher
@casher_id int output, @name nvarchar(50)
as
begin
 insert into nearlogistic.marshrequests_cashers(casher_name)
  values(@name)
  set @casher_id=@@identity
end