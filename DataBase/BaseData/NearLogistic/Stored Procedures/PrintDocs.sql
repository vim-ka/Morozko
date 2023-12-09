CREATE PROCEDURE NearLogistic.PrintDocs @mhid INT, @doctype int
AS 
  SELECT DISTINCT 
         mr.mrID, 
         m.Marsh, m.ND, 
         ISNULL(m.TimePlan, '0:00:00') TimePlan,
         ISNULL(mc.casher_name, '') goName, 
         ISNULL(mc.casher_addres, '') goAddr, 
         ISNULL(mp.point_name, '') gpName, 
         ISNULL(mp.point_adress, '') gpAddr, 
         ISNULL(fc.OurName, '') bkName, 
         ISNULL(fc.OurADDR, '') bkAddr, 
         ISNULL(d.Fio, '') bkDriver, 
         ISNULL(d.Phone1, '') bkPhone,  
         ISNULL(v.Model, '') bkVehicle, 
         ISNULL(v.RegNom, '') bkStateNumber,
         ISNULL(mr.Weight_, mrf.weight) weight,
         IIF(ISNULL(mr.ReqID,0)<>0, mr.ReqID, ISNULL(mrf.DocNumber, '')) DocNum,
         IIF(ISNULL(mr.ReqID,0)<>0, 
                    CAST(CONVERT(VARCHAR, mr.dt, 104) AS DATETIME), 
                    CAST(CONVERT(VARCHAR, mrf.DocDate, 104) AS DATETIME)) DocDate,
         IIF(ISNULL(mr.ReqID,0)<>0, mr.Cost_, mrf.cost) cost 
  FROM NearLogistic.MarshRequests_free mrf
  LEFT JOIN NearLogistic.MarshRequests mr ON mr.mhID = mrf.mhID AND mr.ReqID = mrf.mrfID
  LEFT JOIN NearLogistic.marshrequestsdet mrd ON mrf.mrfid = mrd.mrfid AND mrd.action_id=6
  LEFT JOIN NearLogistic.marshrequests_cashers mc ON mrf.pin = mc.casher_id
  LEFT JOIN NearLogistic.marshrequests_points mp ON mrd.point_id = mp.point_id
  LEFT JOIN FirmsConfig fc ON fc.Our_id = 22
  LEFT JOIN marsh m ON mr.mhID = m.mhid
  LEFT JOIN Vehicle v ON m.V_ID = v.v_id
  LEFT JOIN Drivers d ON m.drId = d.drId
  WHERE m.mhid = @mhid