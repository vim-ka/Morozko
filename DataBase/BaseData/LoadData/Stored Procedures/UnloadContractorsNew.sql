CREATE PROCEDURE [LoadData].UnloadContractorsNew @our_id int, @NeedDay datetime
AS
BEGIN
  select distinct d.upin,d.brName,d.contact,d.brINN,d.brKPP,d.brBank,d.BrPhone,d.gpAddr, d.brAddr,d.brRs,d.brBIK,d.brCs,d.OKPO, 
       cast(d.master as varchar) as master, 
       cast(d.Obl_ID as varchar) as Obl_Id,
       d.Reg_id,
       d.Ncod as oldpin,
       c.ContrTip
  from def d join defcontract c on d.pin=c.pin 
  where d.BeginDate>=@NeedDay and (d.pin=d.master or isnull(d.master,0)=0) 
       and (exists(select t.* from defcontract t where t.pin=d.ncod and t.our_id=@our_id) 
       or exists(select t.* from defcontract t where t.pin=d.ncod and t.our_id=@our_id)
       or exists(select t.* from defcontract t where t.pin=d.pin and t.our_id=@our_id))
END