CREATE PROCEDURE db_FarLogistic.AppendNewExpence
@IDs varchar(500),
@Sum money,
@Type int,
@Com varchar(500),
@ND datetime
AS
BEGIN
	declare @cnt int
	declare @gr int
	declare @tmp table(i int)
	
	insert into @tmp 
	exec db_FarLogistic.DynTable @ids, ','
  
	select @cnt=count(*) from @tmp
	
	if @cnt=1 
		set @gr=-1
	else
		select @gr=max(z.GroupsID)+1 from db_FarLogistic.dlVehicleExpence z
	
	if @cnt>=1
	begin	
	insert into db_FarLogistic.dlVehicleExpence (ExpenceDate,ExpenceSum,dlVehicleID,ExpenceCom,ExpenceListID,GroupsID)				
	select 	@nd,
					@Sum/@cnt,
					i,
					@Com+'{'+'сумма: '+cast(@Sum as varchar)+' распределено между '+cast(@cnt as varchar)+' ТС'+'}',
					@Type,
					@gr
	from @tmp
	end
END