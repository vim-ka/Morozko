CREATE FUNCTION [db_FarLogistic].CheckForMaster(@a ntext)
RETURNS @t table (res bit, CashID int) AS
BEGIN
	declare @jorneytype int
  declare @casher int
  declare @Scasher int
  declare @Res bit
  
  declare cur_jor cursor for
  select ji.JorneyTypeID, ji.CasherID from db_FarLogistic.dlJorneyInfo ji
  where ji.IDReq in (select * from db_FarLogistic.String_to_Int(@a))
  
  open cur_jor
  
  fetch next from cur_jor into
  @jorneytype, @casher
  
  set @Scasher=@casher
  set @res=0
  
  while @@FETCH_STATUS=0 
  begin
  	if @jorneytype in (3,4) or @Scasher<>@casher
    begin
    	set @res=1
      break
    end	
    fetch next from cur_jor into
  	@jorneytype, @casher
  end
  
  close cur_jor 
  deallocate cur_jor
  
  insert into @t(res, CashID) values (@res, @Scasher)
      
  return 
END