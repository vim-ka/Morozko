CREATE PROCEDURE [db_FarLogistic].dlJorney_Insert
@IDMarsh int,
@ZeroPoint int,
@IDUsr int,
@IDClienta int,
@IDAction int,
@IDPoint int,
@Count int,
@IDLoadingUnit int,
@IDReq int,
@isCom bit 
AS
	declare @i int
	declare @zp int
  declare @flgFirst bit 
  declare @Numb int   
	
  select @i = max(j.ZeroPoint) from [db_FarLogistic].dlJorney j where j.IDdlMarsh = @IDMarsh
	select @zp = (case 
								when @i is null then 1
																else @i + 1
								end)
	
  select @flgFirst = (case
											when @ZeroPoint is null then 1
                      												else 0 
											end)
  
  select @ZeroPoint = (case
											when @ZeroPoint is null then @zp
                      												else @ZeroPoint 
											end)
	if @flgFirst <> 1
  begin
    select @numb = COUNT(j.ZeroPoint) 
    from [db_FarLogistic].dlJorney j 
    where j.IDdlMarsh = @IDMarsh and j.ZeroPoint = @ZeroPoint
  end 
  
  if @flgFirst = 1
  	begin
    	insert into [db_FarLogistic].dlJorney 
      						([db_FarLogistic].dlJorney.IDdlMarsh,
                  [db_FarLogistic].dlJorney.ZeroPoint,
                  [db_FarLogistic].dlJorney.ClientID,
                  [db_FarLogistic].dlJorney.IDdlDelivPoint,
                  [db_FarLogistic].dlJorney.IDdlPointAction,
                  [db_FarLogistic].dlJorney.CountID,
                  [db_FarLogistic].dlJorney.Count,
                  [db_FarLogistic].dlJorney.Usr,
                  [db_FarLogistic].dlJorney.Numb,
                  [db_FarLogistic].dlJorney.IDReq,
                  [db_FarLogistic].dlJorney.isCommerce)
      values 			(	@IDMarsh, 
      							@ZeroPoint, 
                    @IDClienta, 
                    @IDPoint, 
                    9, 
                    NULL, 
                    NULL, 
                    @IDUsr,
                    1,
                    @IDReq,
                    @isCom)
    end 
   else
   	begin
    	insert into [db_FarLogistic].dlJorney 
      						([db_FarLogistic].dlJorney.IDdlMarsh,
                  [db_FarLogistic].dlJorney.ZeroPoint,
                  [db_FarLogistic].dlJorney.ClientID,
                  [db_FarLogistic].dlJorney.IDdlDelivPoint,
                  [db_FarLogistic].dlJorney.IDdlPointAction,
                  [db_FarLogistic].dlJorney.CountID,
                  [db_FarLogistic].dlJorney.Count,
                  [db_FarLogistic].dlJorney.Usr,
                  [db_FarLogistic].dlJorney.Numb,
                  [db_FarLogistic].dlJorney.IDReq,
                  [db_FarLogistic].dlJorney.isCommerce)
      values 			(	@IDMarsh, 
      							@ZeroPoint, 
                    @IDClienta, 
                    @IDPoint, 
                    @IDAction, 
                    @IDLoadingUnit, 
                    @Count, 
                    @IDUsr,
                    @Numb+1,
                    @IDReq,
                    @isCom)
    end