CREATE PROCEDURE dbo.ChangeMeasPrihodReq
@PrihodRID int,
@InBox bit 
AS
declare @tranname varchar(20)
set @tranname='CheangeMeasPrihodReq'
begin tran @tranname
	declare @PrihodRDetID int
  declare @kol varchar(20)
  declare @minp int
  declare @res int
  declare @IsWeight bit 
  declare cur_det cursor for
  select PrihodRDetID, PrihodRDetKolStr, minp, flgWeight
  from PrihodReqDet 
  join nomen on hitag=PrihodRDetHitag
  where PrihodRID=@PrihodRID
	open cur_det
  
  fetch next from cur_det into
  @PrihodRDetID, @kol, @minp, @IsWeight
  
  while @@fetch_status=0 
  begin
  	
  	if (patindex('%.%', @kol)=0) and (@IsWeight=0)
    begin
    	exec dbo.TransInUnit @kol, @minp, @res out
    	if @InBox=1
      begin      	
      	update PrihodReqDet set PrihodRDetKolStr=dbo.UnitInStr(cast(@res as varchar(10)),@minp)
        where PrihodRDetID=@PrihodRDetID	
      end
      else
      begin
    	 	update PrihodReqDet set PrihodRDetKolStr='+'+cast(@res as varchar(9))
        where PrihodRDetID=@PrihodRDetID
      end
    end
  
  	fetch next from cur_det into
  	@PrihodRDetID, @kol, @minp, @IsWeight
  end
  
  close cur_det
  deallocate cur_det

if @@error=0
	begin
  	commit tran @tranname
  	select cast(0 as bit) n, cast('' as varchar(100)) as Res
  end
else
	begin
		rollback tran @tranname
  	select cast(1 as bit) n, cast('При изменении возникла ошибка' as varchar(100)) as Res
  end