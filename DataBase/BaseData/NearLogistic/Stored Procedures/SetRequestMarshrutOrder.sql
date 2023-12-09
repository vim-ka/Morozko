CREATE PROCEDURE NearLogistic.SetRequestMarshrutOrder
@mrID INT,
@newOrder INT,
@isInsert BIT=0
AS 
BEGIN
  declare @oldOrder int, @oldMrID int, @mhID int 
 if @newOrder>0
  begin
    select @oldOrder=mr.reqorder, @mhID=mr.mhID from nearLogistic.marshrequests mr where mrid=@mrID
    select @oldMrID=mr.mrID from nearLogistic.marshrequests mr where mhid=@mhID and reqorder=@newOrder

    IF @isInsert=1
    begin
      update NearLogistic.MarshRequests set ReqOrder=ReqOrder+1
      where mhID=@mhID and ReqOrder>=@newOrder
    end
    else
    begin
      update NearLogistic.MarshRequests set ReqOrder=@oldOrder
      where mrID=@oldMrID 
    end    

    update NearLogistic.MarshRequests set ReqOrder=@newOrder
    where mrID=@mrID

    exec nearLogistic.reordermarshrutrequest @mhID
  end
END