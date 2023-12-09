CREATE procedure AddNewNomen
  @name varchar(90), @nds tinyint, @Grp int, @Hitag int out, @MinP int=1, @Mpu int=1
as 
declare @ND datetime
begin
  -- Сегодня:
  set @ND=CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),0)),0);
  
  declare CH cursor fast_forward  for select hitag+1 as H from nomen
  EXCEPT select hitag as H from nomen;
   
  open CH;
  fetch next from CH into @Hitag;
  if (@Hitag is not null) and (@Hitag<99999)
    insert into Nomen(Hitag,NAME,Nds,Ngrp,MinP, Mpu, DateCreate) 
    values(@Hitag,@NAME,@Nds,@grp, @MinP, @Mpu, @ND);
  close CH;
  deallocate CH;

  select @Hitag;

end;