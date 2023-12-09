CREATE PROCEDURE NearLogistic.ReorderMarshrutRequest
@mhID INT
AS
BEGIN
  SELECT mr.mrID,
         ROW_NUMBER() OVER(ORDER BY mr.ReqOrder) [NewOrder]
  INTO #tmpOrder
  FROM NearLogistic.MarshRequests mr
  WHERE mhID=@mhID

  UPDATE r SET r.ReqOrder=t.NewOrder
  FROM NearLogistic.MarshRequests r
  INNER JOIN #tmpOrder t ON t.mrID=r.mrID

  DROP TABLE #tmpOrder
END