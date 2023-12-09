create procedure SaveNvExiteInfo (@datnom int, @hitag int, @plu varchar(40))
as begin
  if EXISTS(select * from nv_exiteInfo where datnom=@datnom and hitag=@hitag)
  update nv_exiteInfo set Plu=@Plu where datnom=@datnom and hitag=@hitag;
  else insert into nv_ExiteInfo(datnom,hitag,plu) VALUES(@datnom,@hitag,@plu);
end