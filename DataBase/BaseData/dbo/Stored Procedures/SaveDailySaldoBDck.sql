create procedure SaveDailySaldoBDck
@nd datetime
as
begin
  exec SaveDailySaldoDCK @nd
end