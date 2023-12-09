CREATE PROCEDURE dbo.ChangeClonePrihodRDet
@PrihodRDetID int,
@old varchar(10),
@new varchar(10),
@old_int int,
@new_int int
AS
declare @tranname varchar(21)
set @tranname='ChangeClonePrihodRDet'
begin tran @tranname
	declare @old_kol int
  declare @new_kol int
  declare @ost_kol int
  declare @ost varchar(10)
  declare @minp int 
  declare @mainost varchar(10)
  declare @mainost_kol int
  declare @isWeght bit
  declare @delta int
  
  select @isWeght=(select flgWeight from nomen where hitag=(select PrihodRDethitag from PrihodReqDet where PrihodRDetID=@PrihodRDetID))
  
  if @isWeght=0
  begin	
    if exists(select * from PrihodReqDet where PrihodRDetID=@PrihodRDetID and PrihodRDetCloneMain=1)
    begin
    --main clone
      select @mainost=isnull(PrihodRDetMainCloneKolStr,0) 
      from PrihodReqDet 
      where PrihodRDetID=@PrihodRDetID
      
      exec dbo.TransInUnit @old, @minp, @old_kol output 
      exec dbo.TransInUnit @new, @minp, @new_kol output  
      exec dbo.TransInUnit @mainost, @minp, @mainost_kol output 
    	
      if @old_kol<@new_kol
      begin    
        update PrihodReqDet set PrihodRDetKolStr=@new,
                                PrihodRDetMainCloneKolStr=dbo.UnitInStr(cast((@new_kol-@old_kol)+@mainost_kol as varchar(10)),@minp)
        where PrihodRDetID=@PrihodRDetID
      end
      else
      begin
        update PrihodReqDet set PrihodRDetKolStr=@new,
                                PrihodRDetMainCloneKolStr=dbo.UnitInStr(cast(@mainost_kol-(@old_kol-@new_kol) as varchar(10)),@minp)
        where PrihodRDetID=@PrihodRDetID
      end
    end
    else
    begin
    --not main clone  	
      select @ost=PrihodRDetKolStr 
      from PrihodReqDet 
      where PrihodRDetCloneMain=1 and
            PrihodRDetClone=(select PrihodRDetClone from PrihodReqDet where PrihodRDetID=@PrihodRDetID) and
            PrihodRID=(select PrihodRID from PrihodReqDet where PrihodRDetID=@PrihodRDetID)
      
      select @minp=n.minp 
      from nomen n 
      where n.hitag=(select PrihodRDetHitag 
                     from PrihodReqDet 
                     where PrihodRDetID=@PrihodRDetID )
    
      exec dbo.TransInUnit @old, @minp, @old_kol output 
      exec dbo.TransInUnit @new, @minp, @new_kol output
      exec dbo.TransInUnit @ost, @minp, @ost_kol output
      
      if @new_kol>@old_kol
      begin
      --rise clone
        if @new_kol>=@ost_kol
        begin
          set @new_kol=@ost
        end
        
        update PrihodReqDet set PrihodRDetKolStr=dbo.UnitInStr(cast(@new_kol as varchar(10)),@minp)
        where PrihodRDetID=@PrihodRDetID
        
        update PrihodReqDet set PrihodRDetKolStr=dbo.UnitInStr(cast(@ost_kol-(@new_kol-@old_kol) as varchar(10)),@minp)
        where PrihodRDetCloneMain=1 and
              PrihodRDetClone=(select PrihodRDetClone from PrihodReqDet where PrihodRDetID=@PrihodRDetID) and
              PrihodRID=(select PrihodRID from PrihodReqDet where PrihodRDetID=@PrihodRDetID)	
      end
      else
      begin
      --down clone
        update PrihodReqDet set PrihodRDetKolStr=dbo.UnitInStr(cast(@new_kol as varchar(10)),@minp)
        where PrihodRDetID=@PrihodRDetID
        
        update PrihodReqDet set PrihodRDetKolStr=dbo.UnitInStr(cast((-@new_kol+@old_kol)+@ost_kol as varchar(10)),@minp)
        where PrihodRDetCloneMain=1 and
              PrihodRDetClone=(select PrihodRDetClone from PrihodReqDet where PrihodRDetID=@PrihodRDetID) and
              PrihodRID=(select PrihodRID from PrihodReqDet where PrihodRDetID=@PrihodRDetID)	
      end
    end
  end
  else
  begin
  	if exists(select * from PrihodReqDet where PrihodRDetID=@PrihodRDetID and PrihodRDetCloneMain=1)
    begin
    	select 	@mainost_kol=PrihodRDetMainCloneKol,
      				@mainost=PrihodRDetMainCloneKolStr
      from PrihodReqDet 
      where PrihodRDetID=@PrihodRDetID
      
      if @new_int<>@old_int 
      begin
      	update PrihodReqDet set PrihodRDetMainCloneKol=@new_int,
        												PrihodRDetKol=@new_int,
        												PrihodRDetWeigth=cast(PrihodRDetMainCloneKolStr as float)/(PrihodRDetMainCloneKol+(@new_int-@old_int)),
                                PrihodRDetKolStr=PrihodRDetMainCloneKolStr
        where PrihodRDetID=@PrihodRDetID
        
        update PrihodReqDet set PrihodRDetWeigth=(select PrihodRDetWeigth from PrihodReqDet where PrihodRDetID=@PrihodRDetID),
        												PrihodRDetKolStr='0',
                                PrihodRDetKol=0
        where PrihodRDetCloneMain=0 and
            	PrihodRDetClone=(select PrihodRDetClone from PrihodReqDet where PrihodRDetID=@PrihodRDetID) and
            	PrihodRID=(select PrihodRID from PrihodReqDet where PrihodRDetID=@PrihodRDetID)
      end
            
      if @new<>@old
      begin
      	update PrihodReqDet set PrihodRDetMainCloneKolStr=@new,
        												PrihodRDetKolStr=@new,
                                PrihodRDetWeigth=cast(@new as float)/PrihodRDetMainCloneKol,
                                PrihodRDetKol=PrihodRDetMainCloneKol
        where PrihodRDetID=@PrihodRDetID
        
        
        update PrihodReqDet set PrihodRDetWeigth=(select PrihodRDetWeigth from PrihodReqDet where PrihodRDetID=@PrihodRDetID),
        												PrihodRDetKolStr='0',
                                PrihodRDetKol=0
        where PrihodRDetCloneMain=0 and
            	PrihodRDetClone=(select PrihodRDetClone from PrihodReqDet where PrihodRDetID=@PrihodRDetID) and
            	PrihodRID=(select PrihodRID from PrihodReqDet where PrihodRDetID=@PrihodRDetID)	
      end
      
    end
    else
    begin
    	select @ost_kol=PrihodRDetKol 
      from PrihodReqDet 
      where PrihodRDetCloneMain=1 and
            PrihodRDetClone=(select PrihodRDetClone from PrihodReqDet where PrihodRDetID=@PrihodRDetID) and
            PrihodRID=(select PrihodRID from PrihodReqDet where PrihodRDetID=@PrihodRDetID)
      
      set @delta=@new_int-@old_int      
      if @delta>@ost_kol
      begin
      	set @delta=@ost_kol
        set @new_int=@delta-@ost_kol
      end
      
      update PrihodReqDet set PrihodRDetKol=@new_int,
      												PrihodRDetKolStr=cast(PrihodRDetWeigth*@new_int as varchar(10))
      where PrihodRDetID=@PrihodRDetID
      
      update PrihodReqDet set PrihodRDetKol=PrihodRDetKol-@delta,
      												PrihodRDetKolStr=cast((PrihodRDetKol-@delta)*PrihodRDetWeigth as varchar(10))
      where PrihodRDetCloneMain=1 and
            	PrihodRDetClone=(select PrihodRDetClone from PrihodReqDet where PrihodRDetID=@PrihodRDetID) and
            	PrihodRID=(select PrihodRID from PrihodReqDet where PrihodRDetID=@PrihodRDetID)
    end
  end

if @@error=0 
	begin
  	commit tran @tranname
  	select cast(0 as bit) n, cast('' as varchar(100)) as Res
  end
else
	begin
		rollback tran @tranname
  	select cast(1 as bit) n, cast('При пересчете клонов возникла ошибка' as varchar(100)) as Res
  end