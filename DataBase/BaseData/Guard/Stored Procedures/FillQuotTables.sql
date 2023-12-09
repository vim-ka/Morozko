CREATE procedure Guard.FillQuotTables @CoID int, @ag_id int, @Pin int, @Hitag int, @PlanQty int, @PlanWeight decimal(10,1)
as
declare @DqID int;
BEGIN
  --  if @PlanQty=0 and @PlanWeight=0 BEGIN
  --    if 
  --  end;
  if @Ag_ID=0
    update Guard.CommonQuot set PlanWeight=@PlanWeight, PlanQty=@PlanQty where CoID=@CoID;
  else
    set @DqID=(select DqID from Guard.DetailQuot where CoID=@CoID and Ag_ID=@Ag_ID and B_ID=@Pin and Hitag=@Hitag);
    if @DqID is NULL begin
      if @PlanQty<>0 or @PlanWeight<>0
	      insert into Guard.DetailQuot(CoID,AG_ID,B_ID,Hitag,PlanQty,PlanWeight) values(@CoID,@AG_ID,@Pin,@Hitag,@PlanQty,@PlanWeight);
    end;
    else begin
      if @PlanQty=0 and @PlanWeight=0 
      	delete from Guard.DetailQuot where DqID=@DqID;
	  else	
	     update Guard.DetailQuot 
         set PlanWeight=@PlanWeight, PlanQty=@PlanQty 
         where DqID=@DqID;
         -- where CoID=@CoID and Ag_ID=@Ag_ID and B_ID=@Pin and Hitag=@Hitag;
    end;
end;