CREATE FUNCTION db_FarLogistic.GetDistancePair (@pID1 int, @pID2 int)
RETURNS int
AS
begin
	declare @res int
	set @res= case when @pID1=@pID2 then 0
						else isnull((select top 1 d.Distance
												from db_FarLogistic.dlDirections d
												where (d.DestinationID=@pID1 and d.OriginID=@pID2)
															or(d.DestinationID=@pID2 and d.OriginID=@pID1)),-1) end
	return @res
end