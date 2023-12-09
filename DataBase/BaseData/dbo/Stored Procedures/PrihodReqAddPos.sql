CREATE PROCEDURE dbo.PrihodReqAddPos
@PrihodReqID int,
@hitag int,
@op int,
@NeedKol bit=0,
--@copykolstr varchar(12)='',
--@copykol int=0,
@QTY DECIMAL(12,3),
@unid INT
AS
declare @tranname varchar(15)
set @tranname='PrihodReqAddPos'
begin tran @tranname 

  declare @cost money 
  declare @price money 
  declare @dck int 
  declare @AfterParty bit
  declare @sklad int
  declare @weight decimal(10,3)
  declare @kol int
  declare @minp int
	declare @erReg int
  declare @curDetID int
	
	set @erReg=0
	
  select @dck=PrihodRDefContract 
  from prihodreq 
  where PrihodRID=@PrihodReqID

  select 	@sklad=n.LastSkladID, 
  				--@weight=(case when n.flgWeight=1 then 0 else n.Netto end),
          @kol=(case when n.UnID=0 then 1 else 0 end),
          @minp=isnull(n.minp,1)
  from nomen n 
  where hitag=@hitag

  select @AfterParty=(case when p.PrihodRDone=30 then 1 else 0 end)
  from PrihodReq p 
  where p.PrihodRID=@PrihodReqID 

  select 	@cost=isnull(n.cost,0),
          @price=isnull(n.price,0)
  from nomenvend n 
  where n.DCK=@dck and n.Hitag=@hitag
	
  
  
  insert into prihodreqdet (PrihodRID,
                            PrihodRDetHitag,
                            PrihodRDetKolStr,
                            --PrihodRDetKol,
                            --PrihodRDetWeigth,
                            PrihodRDetSkladID,
                            PrihodRDetCost,
                            PrihodRDetPrice,
                            PrihodRDetOperatorID,
                            PrihodRDetAfterParty,
                            QTY,  
                            unID)
  values (@PrihodReqID,
          @hitag,         
          0,
          --(select dbo.UnitInStr(cast(@kol as varchar(10)), @minp)),
          --@kol,
          --@weight,
          @sklad,
          @cost,
          @price,
          @op,
          @AfterParty,
          @QTY,
          @unid)
	set @erReg=@erReg+@@error
	
	if not exists(select * from PrihodReqDet where PrihodRDetHitag=@hitag and PrihodRDetCloneMain=1)
	begin
		UPDATE PrihodReqDet set PrihodRDetCloneMain=1
		from PrihodReqDet b
		inner join (select top 1 * 
								from PrihodReqDet a
								where a.PrihodRDetHitag=@hitag 
											and a.PrihodRDetAfterParty<>1 
											and a.PrihodRID=@PrihodReqID) c on b.PrihodRDetID=c.PrihodRDetID
	end
	
	if @NeedKol=1 
	begin
		select @curDetID=@@identity 
		
		update PrihodReqDet set	--PrihodRDetKol=@copykol, 
														--PrihodRDetKolStr=@copykolstr,
														PrihodRDetCheck=1
		where PrihodRDetID=@curDetID
		set @erReg=@erReg+@@error
	end
if @@ERROR=0 
	commit tran @tranname
else
	rollback tran @tranname