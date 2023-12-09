CREATE PROCEDURE [db_FarLogistic].CopyEmpowerment
@driverid int, 
@pricepID int, 
@vehicleID int,
@uin int, 
@ActID int,
@CopyCount int,
@our_id int,
@iStart int

AS
declare @TranName varchar(8)
select @TranName = 'CopyEmp'
  
BEGIN TRAN @TranName
declare @i int
set @i=@iStart
while @i<@CopyCount
begin
  insert into db_FarLogistic.dlEmpowerment(
  						db_FarLogistic.dlEmpowerment.dlEmpowermentID,
              db_FarLogistic.dlEmpowerment.DriverID,
              db_FarLogistic.dlEmpowerment.PricepID,
              db_FarLogistic.dlEmpowerment.VehicleID,
              db_FarLogistic.dlEmpowerment.DateCreate,
              db_FarLogistic.dlEmpowerment.uin,
              db_FarLogistic.dlEmpowerment.ActID,
              db_FarLogistic.dlEmpowerment.Our_ID)
  values (@i, @driverid, @pricepID, @vehicleID, GETDATE(),
          @uin, @ActID, @our_id)
	set @i=@i+1
end        
if @@ERROR = 0 
COMMIT TRAN @TranName
ELSE ROLLBACK TRAN @TranName