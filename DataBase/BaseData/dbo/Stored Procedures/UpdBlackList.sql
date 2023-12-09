CREATE procedure UpdBlackList
@B_ID int, @Hitag int, @Disab tinyint
as
declare @State tinyint
begin
  set @State = (select Disab from BlackList where B_ID=@B_ID and Hitag=@Hitag);

  if (@State is null) begin
    if (@Disab=1)  insert into BlackList(B_ID,Hitag,Disab) values(@B_ID, @Hitag,1);
  end;
  else if (@State<>@Disab) update BlackList set Disab=@Disab where B_ID=@B_ID and Hitag=@Hitag;

end