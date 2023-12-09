create procedure SaveLogA @Mess varchar(30), @Nom int
as
begin
  insert into SkladPrepLog values (GETDATE(),@Mess,@Nom);
end;