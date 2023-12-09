CREATE PROCEDURE dbo.SyncRequests
@op int
AS
declare @ErrReg int
set @ErrReg=0
declare @tranname varchar(13)
set @tranname='SyncRequests'
begin tran @tranname 
  declare @dt datetime
  set @dt=convert(varchar, getdate(),4)
    	
  update PrihodReq set PrihodROpSave=1 
  where 	PrihodReq.PrihodRDone=30 and  
          exists(	select *
                  from PrihodReqDet D 
                  where d.PrihodRDetHitag in  (select distinct t.TaraTag 
                                               from taracode2 t)  and 
                        d.PrihodRID=PrihodReq.PrihodRID)
  set @ErrReg=@ErrReg+@@ERROR
  /*                    
  delete from PrihodReq 
  where PrihodRDate < @dt and 
  PrihodRSaveTo=0 and 
  PrihodROpSave=1
  set @ErrReg=@ErrReg+@@ERROR
  */
  update PrihodReq set PrihodRDate=convert(varchar,getdate(),4) 
  where PrihodRDone<30 and  
  		PrihodRDate<@dt and 
  		PrihodRSaveTo=1
  set @ErrReg=@ErrReg+@@ERROR
  /*
  delete from PrihodReqDet 
  where PrihodRID not in (select PrihodRID	from PrihodReq)
	set @ErrReg=@ErrReg+@@ERROR
  */
  declare @OrdID int
  declare @PrihodRID int
  declare cur cursor for
  select o.OrdID
  from orders o 
  where o.DateComm=convert(varchar,getdate(),4) and 
        not exists(select * from prihodreq where prihodrordersid=o.OrdID)
  
  open cur 
  
  fetch next from cur into @OrdID 
  print @OrdID  
  while @@fetch_status=0 
  begin
  	insert into PrihodReq (	PrihodRDate,
                            PrihodROperatorID,
                            PrihodRVendersID,
                            PrihodRSumPrice,
                            PrihodRSumCost,
                            PrihodRDone,
                            PrihodROurID,
                            PrihodRDocNum,
                            PrihodRDocDate,
                            PrihodROrdersID,
                            PrihodRTNNum,
                            PrihodRTNDate,
                            PrihodRDefContract,
                            PrihodRDefSafeCust,
                            PrihodRSaveTo,
                            PrihodRVenderPin,
                            PrihodRNDS10,
                            PrihodRNDS18,
                            PrihodRSumNDS,
                            NeedReCalc,
                            dlMarshID,
                            dlMarshCost)
		select 				convert(varchar,getdate(),4),
  							@OP,
                            o.Ncod,
                            o.summaprice,
                            o.summacost,
                            0,
                            7,
                            '',
                            convert(varchar,getdate(),4),
                            @OrdID,
                            '',
                            convert(varchar,getdate(),4),
                            case when isnull(o.dck,0)=0 then (select top 1 dc.dck from defcontract dc where dc.pin=o.Ncod and dc.Actual=1 and dc.ContrMain=1 and dc.ContrTip=1) else o.dck end,
                            0,
                            0,
                            case when isnull(o.pin,0)=0 then (select top 1 d.pin from def d where d.ncod=o.ncod and d.Actual=1) else o.pin end,
                            0,
                            0,
                            0,
                            1,
                            iif(isnull(o.ShipingCost,0)=0,0,-1),
                            isnull(o.ShipingCost,0)                            
  	from orders o 
  	where o.OrdID=@OrdID
    set @errReg=@errReg+@@ERROR
    
    select @PrihodRID=@@IDENTITY
    declare @dck int 
    select @dck=PrihodRDefContract from PrihodReq where PrihodRID=@PrihodRID
    
    insert into PrihodReqDet (PrihodRID,
                              PrihodRDetHitag,
                              PrihodRDetPrice,
                              PrihodRDetCost,
                              PrihodRDetSummaCost,
                              PrihodRDetSummaPrice,
                              PrihodRDetLocked,
                              PrihodRDetKolStr,
                              PrihodRDetOperatorID,
                              PrihodRDetSkladID,
                              PrihodRDetIsSave,
                              PrihodRDetCheck,
                              --PrihodRDetKol,
                              --PrihodRDetWeigth,
                              QTY,
                              PrihodRDetKolStr_plan)
    select 					  @PrihodRID,
    						  od.Hitag,
                              nv.Price,
                              nv.cost,
                              od.Qty*nv.Cost,
                              od.Qty*nv.Price,
                              0,
                              (select dbo.UnitInStr((cast(od.Qty as varchar(10))),n.minp)),
                              @OP,
                              iif(isnull(nv.sklad,0)=0,n.LastSkladID,nv.sklad),
                              0,
                              0,
                              od.Qty,
                              --od.Weight,
                              (select dbo.UnitInStr((cast(od.Qty as varchar(10))),n.minp))                              
    from Orddet od 
    join nomen n on n.hitag=od.Hitag
    left join nomenvend nv on nv.Hitag=od.Hitag and nv.dck=@dck
    where od.OrdID=@OrdID
	
  	set @errReg=@errReg+@@ERROR
    
  	fetch next from cur into @OrdID 
  end
  
  close cur
  deallocate cur
  
if @ErrReg=0 
begin
	commit tran @tranname
	select cast(0 as bit) as [n], '' as [Res]
end
else
begin
	rollback tran @tranname
	select cast(1 as bit) as [n], 'Во время синхронизации произошла ошибка' as [Res]
end