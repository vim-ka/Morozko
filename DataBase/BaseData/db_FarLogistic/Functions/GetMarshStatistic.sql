CREATE FUNCTION db_FarLogistic.GetMarshStatistic (@MarshID int)
RETURNS @tbl table (id int, delta int)
AS
begin
	declare @pKM int
	declare @fKM int
	
	select @pKM=c.KM
	from db_FarLogistic.dlTmpMarshCost c
	where c.WorkID=0
				and c.MarshID=@MarshID

	select @fKM=isnull(m.odo_end_fact,0)-isnull(m.odo_beg_fact,0)
	from db_FarLogistic.dlMarsh m
	where m.dlMarshID=@MarshID
	
	insert into @tbl
	select 	x.WorkID,
					case 	when x.WorkID=0 then @fKM-@pKM 
								else case when @pKM=0 then 0 
													else (@fKM-@pKM)*((x.km * 1.0)/(@pKM * 1.0))
										 end 
					end
	from db_FarLogistic.dlTmpMarshCost x
	where x.MarshID= @MarshID
	
	return
end