CREATE PROCEDURE dbo.DeletePrihodRDet
@PrihodRDetID int
AS
declare @tranname varchar(16)
set @tranname='DeletePrihodRDet'
begin tran @tranname
/*
	declare @NClone int
  declare @MainCloneKolStr varchar(10)
  declare @DeleteKolStr varchar(10)
  declare @MainCloneKol int
  declare @DeleteKol int
  declare @minp int
  declare @isWeight bit
  declare @PrihodRID int
  
  select @NClone=PrihodRDetClone,
         @PrihodRID=PrihodRID 
  from PrihodReqDet 
  where PrihodRDetID=@PrihodRDetID
  
  if @NClone=0
  begin
  	delete from PrihodReqDet where PrihodRDetID=@PrihodRDetID
  end
  else
  begin
  	if exists(select * from PrihodReqDet where PrihodRDetID=@PrihodRDetID and PrihodRDetCloneMain=1)
    begin
    	select 	@MainCloneKolStr=PrihodRDetMainCloneKolStr,
      				@DeleteKolStr=PrihodRDetKolStr,
              @MainCloneKol=PrihodRDetMainCloneKol,
              @DeleteKol=PrihodRDetKol,
              @minp=nn.minp,
              @isWeight=nn.flgWeight
      from PrihodReqDet 
      join nomen nn on nn.hitag=PrihodRDethitag
      where PrihodRDetID=@PrihodRDetID
      
      if @isWeight=0 
      begin
      	exec dbo.TransInUnit @MainCloneKolStr, @minp, @MainCloneKol output 
      	exec dbo.TransInUnit @DeleteKolStr, @minp, @DeleteKol output 
      end
            
      update PrihodReqDet set PrihodRDetCloneMain=1,
      												PrihodRDetMainCloneKolStr=dbo.UnitInStr(cast(@MainCloneKol-@DeleteKol as varchar(10)), @minp),
                              PrihodRDetMainCloneKol=@MainCloneKol-@DeleteKol
      where PrihodRDetID=(select top 1 PrihodRDetID
      										from PrihodReqDet
                          where PrihodRDetClone=@NClone and
                          			PrihodRDetCloneMain=0 and
                          			PrihodRID=(select PrihodRID 
                          								 from PrihodReqDet
                                           where PrihodRDetID=@PrihodRDetID))
			
      delete from PrihodReqDet where PrihodRDetID=@PrihodRDetID
                                                 
    end
    else
    begin
    	select 	@DeleteKolStr=PrihodRDetKolStr,
      				@DeleteKol=PrihodRDetKol,
              @minp=nn.minp
      from PrihodReqDet 
      join nomen nn on nn.hitag=PrihodRDethitag
      where PrihodRDetID=@PrihodRDetID
      
      select 	@MainCloneKolStr=PrihodRDetKolStr,
      				@MainCloneKol=PrihodRDetKol
      from PrihodReqDet 
      where PrihodRDetID=(select PrihodRDetID 
      										from PrihodReqDet
                          where PrihodRDetCloneMain=1 and
                          			PrihodRDetClone=@NClone and
                          			PrihodRID=(select PrihodRID 
                                					 from PrihodReqDet
                                           where PrihodRDetID=@PrihodRDetID))
      
      if @isWeight=0
      begin
      	exec dbo.TransInUnit @MainCloneKolStr, @minp, @MainCloneKol output 
      	exec dbo.TransInUnit @DeleteKolStr, @minp, @DeleteKol output
      end
      
      update PrihodReqDet set PrihodRDetKolStr=dbo.UnitInStr(cast(@MainCloneKol+@DeleteKol as varchar(10)), @minp),
      												PrihodRDetKol=@MainCloneKol+@DeleteKol
      where PrihodRDetID=(select PrihodRDetID 
      										from PrihodReqDet
                          where PrihodRDetCloneMain=1 and
                          			PrihodRDetClone=@NClone and
                          			PrihodRID=(select PrihodRID 
                                					 from PrihodReqDet
                                           where PrihodRDetID=@PrihodRDetID)) 
      
      delete from PrihodReqDet where PrihodRDetID=@PrihodRDetID 
    end
  end
	
  if not exists(select * from PrihodReqDet where PrihodRID=@PrihodRID and PrihodRDetClone=@NClone and PrihodRDetCloneMain=0)
  	update PrihodReqDet set PrihodRDetClone=0
    where PrihodRID=@PrihodRID and PrihodRDetClone=@NClone


  */


delete from PrihodReqDet where PrihodRDetID=@PrihodRDetID

if @@error=0 
	begin
  	commit tran @tranname
  	select cast(0 as bit) as n, cast('' as varchar(100)) as Res
  end
else
	begin
		rollback tran @tranname
  	select cast(1 as bit) as n, cast('При удалении возникла ошибка' as varchar(100)) as Res
  end