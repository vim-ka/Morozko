CREATE PROCEDURE [LoadData].ITRPCommLog @DateStart datetime, @DateEnd datetime--, @FirmGroup int
AS
BEGIN
  select c.Ncom as CODE
 from comman c join FirmsConfig f on c.Our_ID=f.Our_id 
               join DefContract  t on c.dck=t.dck
 where c.[date]>=@DateStart and c.[date]<=@DateEnd
       --and f.FirmGroup=@FirmGroup 
       and t.ContrTip=5
 order by c.[date],c.ncom   
END