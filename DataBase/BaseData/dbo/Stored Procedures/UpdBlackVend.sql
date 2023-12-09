--create table BlackVendList (B_ID int, Ncod int, Disab tinyint)
--go

CREATE procedure UpdBlackVend
@B_ID int, @Ncod int, @Disab tinyint
as
declare @State tinyint
begin
  set @State = (select Disab from BlackVendList where B_ID=@B_ID and Ncod=@Ncod);

  if (@State is null) begin
    if (@Disab=1)  insert into BlackVendList(B_ID,Ncod,Disab) values(@B_ID, @Ncod,1);
  end;
  else if (@State<>@Disab) update BlackVendList set Disab=@Disab where B_ID=@B_ID and Ncod=@Ncod;

end