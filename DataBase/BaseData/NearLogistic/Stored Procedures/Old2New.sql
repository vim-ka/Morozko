
CREATE PROCEDURE [NearLogistic].Old2New 
@mhid int,
@op int
AS
BEGIN
  insert into NearLogistic.MarshRequests(mhID,ReqID,ReqType,ReqAction,ReqOrder,OP,PINTo,PINFrom,ag_id,DelivCancel) 
  select mhID,datnom,0,1,0,@op,b_id,b_id2,ag_id,DelivCancel
  from nc 
  where datnom not in (select ReqID from NearLogistic.MarshRequests where mhid=@mhid and ReqType=0)
  and mhid=@mhid  
END