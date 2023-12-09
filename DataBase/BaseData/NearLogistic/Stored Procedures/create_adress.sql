
create procedure nearlogistic.create_adress
@point_id int output, @adress nvarchar(500)
as
begin
 insert into nearlogistic.marshrequests_points(point_adress)
  values(@adress)
  set @point_id=@@identity
end