CREATE PROCEDURE [db_FarLogistic].DefUpdateFromJorney
AS
declare @p int
declare cur_def cursor for 
select distinct j.VendorID from db_FarLogistic.dlJorneyInfo j where not j.VendorID is null
open cur_def 
fetch next from cur_def into @p
while @@FETCH_STATUS=0
begin
	if not exists(select d.ID from db_FarLogistic.dlDef d where d.id=@p)
  begin
  	insert into db_FarLogistic.dlDef (db_FarLogistic.dlDef.MorozDefPin)
    values (@p)
  end
  fetch next from cur_def into @p
end
close cur_def
deallocate cur_def