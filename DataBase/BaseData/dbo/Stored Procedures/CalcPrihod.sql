CREATE PROCEDURE dbo.CalcPrihod 
@PrihodReqID int,
@res bit=1 OUT 
AS
BEGIN
declare @ErrReg int
declare @tranName varchar(20)
set @tranname='CalcPrihod'
begin tran @tranname
	set @ErrReg=0
	declare @PrihodRDetID int
	declare @hitag int
  DECLARE @kol_int INT
  declare @minp int
	declare @kolstr varchar(10)
  declare @QTY DECIMAL(18,4)
	declare @cost money 
	declare @price money 
  DECLARE @unid int

	declare cur_pri cursor for 
  	select 		p.PrihodRDetID,
							p.PrihodRDetHitag, 
							p.PrihodRDetKolStr,
							p.QTY,
              p.unid,
              n.minp,
							isnull(p.PrihodRDetCost,0),
							isnull(p.PrihodRDetPrice,0)
  from prihodreqdet p
  join nomen n on n.hitag=p.PrihodRDetHitag
  where p.PrihodRID=@PrihodReqID and p.PrihodRDetCheck=1
	
  open cur_pri 
  
  fetch next from cur_pri into
  @PrihodRDetID, @hitag, @kolstr, @QTY, @unid, @minp, @cost, @price 
  
  while @@fetch_status=0 
  begin
  	/*
  	if @IsWeight=0 
  		exec dbo.TransInUnit @kolstr, @minp, @kol output
    else
    begin    	
    	update PrihodReqDet set PrihodRDetWeigth=(case when @kol=0 then 0 else cast(@kolstr as float)/@kol end)
      where PrihodRDetID=@PrihodRDetID
      set @ErrReg=@ErrReg+@@error
    end 
 
    update PrihodReqDet set PrihodRDetWeigth=(select n.Netto from nomen n where n.hitag=@hitag)
  	where PrihodRDetID=@PrihodRDetID and isnull(PrihodRDetWeigth,0)=0 
    */



    IF @unid = 0
      begin
    	 update PrihodReqDet 
          SET PrihodRDetKolStr = (select dbo.UnitInStr(CAST(CAST(@QTY AS float) as varchar(10)), @minp))
        where PrihodRDetID=@PrihodRDetID
          set @ErrReg=@ErrReg+@@error
       end
    ELSE 
      begin
    	 update PrihodReqDet 
          SET PrihodRDetKolStr = CAST(@QTY as varchar(10))
        where PrihodRDetID=@PrihodRDetID
          set @ErrReg=@ErrReg+@@error
        end

    update PrihodReqDet set QTY=(select n.Netto from nomen n where n.hitag=@hitag)
  	where PrihodRDetID=@PrihodRDetID and isnull(QTY,0)=0

    set @ErrReg=@ErrReg+@@error  


    update PrihodReqDet 
       set QTY = @QTY,
           PrihodRDetCost =  IIF(@cost=0, 
                                 CASE WHEN @QTY=0 then 0 else PrihodRDetSummaCost/@QTY END, 
                                 PrihodRDetCost),
           PrihodRDetSummaCost = IIF(@cost = 0, PrihodRDetSummaCost, PrihodRDetCost*@QTY),  
           PrihodRDetPrice = IIF(@price = 0, 
                                 CASE WHEN @QTY=0 then 0 else PrihodRDetSummaPrice/@QTY END,
                                 PrihodRDetPrice),
           PrihodRDetSummaPrice = IIF(@price=0, PrihodRDetSummaPrice, PrihodRDetPrice*@QTY)

     where PrihodRDetID=@PrihodRDetID
           
    set @ErrReg=@ErrReg+@@error



    /*    
  	if @cost=0 
    begin
        update PrihodReqDet set PrihodRDetCost=(case when @kol=0 then 0 else PrihodRDetSummaCost/@kol end), 
                                PrihodRDetKol=@kol
        where PrihodRDetID=@PrihodRDetID
        set @ErrReg=@ErrReg+@@error
    end
    else
    begin
    	if @IsWeight=0
      begin
				update PrihodReqDet set PrihodRDetSummaCost=PrihodRDetCost*@kol, 
																PrihodRDetKol=@kol
				where PrihodRDetID=@PrihodRDetID 
				set @ErrReg=@ErrReg+@@error  
      end
      else
      begin
				if @flg1kg=1
				begin
					update PrihodReqDet set PrihodRDetSummaCost=case when @kol=0 then 0 else PrihodRDetCost*PrihodRDetWeigth*@kol end
					where PrihodRDetID=@PrihodRDetID 
					set @ErrReg=@ErrReg+@@error
					
					update PrihodReqDet set PrihodRDetCost=case when @kol=0 then 0 else PrihodRDetSummaCost/@kol end
					where PrihodRDetID=@PrihodRDetID 
					set @ErrReg=@ErrReg+@@error
				end
				else
				begin
					update PrihodReqDet set PrihodRDetCost=case when @kol=0 then 0 else PrihodRDetSummaCost/@kol end
					where PrihodRDetID=@PrihodRDetID 
					set @ErrReg=@ErrReg+@@error
				end
      end
    end	


    if @price=0 
    begin
        update PrihodReqDet set PrihodRDetPrice=(case when @kol=0 then 0 else PrihodRDetSummaPrice/@kol end), 
                                PrihodRDetKol=@kol
        where PrihodRDetID=@PrihodRDetID
        set @ErrReg=@ErrReg+@@error
    end
    else
    begin
    	if @IsWeight=1 
      begin
				if @flg1kg=2
				begin
					update PrihodReqDet set PrihodRDetSummaPrice=PrihodRDetPrice*PrihodRDetWeigth*@kol
					where PrihodRDetID=@PrihodRDetID
					set @ErrReg=@ErrReg+@@error
					
					update PrihodReqDet set PrihodRDetPrice=case when @kol=0 then 0 else PrihodRDetSummaPrice/@kol end
					where PrihodRDetID=@PrihodRDetID
					set @ErrReg=@ErrReg+@@error
				end
				else
				begin
					update PrihodReqDet set PrihodRDetPrice=case when @kol=0 then 0 else PrihodRDetSummaPrice/@kol end
					where PrihodRDetID=@PrihodRDetID
					set @ErrReg=@ErrReg+@@error
				end
      end
      else
      begin      	      
        update PrihodReqDet set PrihodRDetSummaPrice=PrihodRDetPrice*@kol, 
        												PrihodRDetKol=@kol
        where PrihodRDetID=@PrihodRDetID
        set @ErrReg=@ErrReg+@@error
      end
    end  
		

		update PrihodReqDet set PrihodRDetflg1kg=0  
		where PrihodRDetID=@PrihodRDetID
		set @ErrReg=@ErrReg+@@error
  	*/

  	fetch next from cur_pri into
  	@PrihodRDetID, @hitag, @kolstr, @QTY, @unid, @minp, @cost, @price
  end 
  
  close cur_pri
  deallocate cur_pri
  
  update prihodreq set 	PrihodRSumCost=(select sum(p.PrihodRDetSummaCost) from PrihodReqDet p where p.PrihodRID=@PrihodReqID),
  						PrihodRSumPrice=(select sum(p.PrihodRDetSummaPrice) from PrihodReqDet p where p.PrihodRID=@PrihodReqID),
                        PrihodRNDS10=(select isnull((sum(p.PrihodRDetSummaCost)*10)/110,0) from PrihodReqDet p join nomen n on n.hitag=p.PrihodRDetHitag where p.PrihodRID=@PrihodReqID and n.nds=10),
                        PrihodRNDS18=(select isnull((sum(p.PrihodRDetSummaCost)*18)/118,0) from PrihodReqDet p join nomen n on n.hitag=p.PrihodRDetHitag where p.PrihodRID=@PrihodReqID and n.nds=18),
                        PrihodRNDS20=(select isnull((sum(p.PrihodRDetSummaCost)*20)/120,0) from PrihodReqDet p join nomen n on n.hitag=p.PrihodRDetHitag where p.PrihodRID=@PrihodReqID and n.nds=20)
  where PrihodRID=@PrihodReqID 
  set @ErrReg=@ErrReg+@@error
  
  update prihodreq set PrihodRSumNDS=PrihodRNDS10+PrihodRNDS18
  where PrihodRID=@PrihodReqID 
  set @ErrReg=@ErrReg+@@error
  
if @ErrReg=0 
begin
	commit tran @tranname
  update PrihodReq set NeedReCalc=0 where PrihodRID=@PrihodReqID
	set @res=1
end
else
begin
	rollback tran @tranname
	set @res=0
end
select @res [res]

END