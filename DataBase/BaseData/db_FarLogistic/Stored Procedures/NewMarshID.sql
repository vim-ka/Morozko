CREATE PROCEDURE db_FarLogistic.NewMarshID
@uin int
AS
declare @count int
declare @newID int

select @count = count(m.dlMarshID)
from db_FarLogistic.dlMarsh m
where left(m.dlMarshID,2)=right(year(getdate()),2)
			and right(left(m.dlMarshID,4),2) = month(getdate())

select 	@newID=
				right(year(getdate()),2)*100000+
				month(getdate())*1000+
        @count +1
				
insert into db_FarLogistic.dlMarsh (
						dlMarshID, 
            date_creation,
            IDdlDrivers,
            IDdlVehicles,
            idTrailer,
            IDdlMarshStatus,
						IDUsrPwd)
values	(		@newID,
						getdate(),
            -1,
            -1,
            -1,
            1,
            @uin)
						
select @newID [newID]