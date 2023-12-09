-- create table ArcBr (Pin int not null primary key, Fam varchar(30), ag_ID int default 0)

create procedure EditBr @pin int, @fam varchar(30), @ag_id int
AS 
declare @OrigPin int
begin
  set @OrigPin=(select pin from ArcBr where Pin=@Pin);
  if @OrigPin=@Pin 
    update ArcBr set Fam=@Fam, Ag_ID=@Ag_Id 
    where Pin=@Pin and (Fam<>@Fam or Ag_ID<>@Ag_ID);
  else insert into ArcBr(pin,fam,ag_id) values(@Pin,@Fam,@Ag_Id);
end;