create procedure guard.SaveNormativ @pin int, @hitag int, @minrest int
as
begin
  if @minrest=0 delete from guard.normativ where pin=@pin and hitag=@hitag;
  else if exists(select * from guard.normativ where pin=@pin and hitag=@hitag)
  update guard.normativ set MinRest=@MinRest where pin=@pin and hitag=@hitag;
  else insert into guard.normativ(pin,hitag,minrest) values(@pin,@hitag,@minrest);
end