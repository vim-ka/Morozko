CREATE PROCEDURE NearLogistic.GetReasonToReturn
AS
BEGIN
  select *,
      iif(Parent_Id=0,cast(1 as bit),cast(0 as bit)) [isHeader] 
  from dbo.ReasonToRtrn 
  where isDel=0
  order by iif(Parent_Id=0,Reason_Id,Parent_Id),[isHeader] desc
END