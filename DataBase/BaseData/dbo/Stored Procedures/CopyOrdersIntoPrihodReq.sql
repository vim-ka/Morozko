CREATE PROCEDURE dbo.CopyOrdersIntoPrihodReq
@OrdID int,
@OP int
AS
	declare @tranname varchar(22)
	declare @errReg int
	set @errReg=0 
	set @tranname='CopyOrdersIntoPrihodReq'
	begin tran @tranname
	declare @PrihodRID int
	
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
    
    select @errReg=@errReg+@@ERROR
    
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
                              --PrihodRDetWeigth
                              QTY)
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
                              od.Qty
                              --iif(n.flgWeight=1 and isnull(od.Weight,0)=0, n.netto*od.Qty,od.Weight)
    from Orddet od 
    join nomen n on n.hitag=od.Hitag
    left join nomenvend nv on nv.Hitag=od.Hitag and nv.dck=@dck
    where od.OrdID=@OrdID
	
  	set @errReg=@errReg+@@ERROR
    
		update orders set a3id=@PrihodRID
    where OrdID=@OrdID
  	
    set @errReg=@errReg+@@ERROR
    
  if @errReg<>0
  begin
		rollback tran @tranname
    select cast(0 as int) [res], 'Во время выполнения произошла ошибка, попробуйте снова' [msg]
	end
  else	
  begin
    commit tran @tranname
    select @PrihodRID [res], '' [msg]
  end