CREATE PROCEDURE LoadData.UnloadKassa @DateStart datetime, @DateEnd datetime, @our_id int
AS
BEGIN
  select c.ckID,
       c.nd,
       --dbo.today()-1 AS nd, 
       case when isnull(d.master,0)>0 then d2.upin else d.upin end as b_id,
       c.remark,
       c.plata,
       isnull(c.nds10,0) as nds10,
       isnull(c.nds18,0) as nds18,
       n.startdatnom as vk,
       c.Back,
       isnull(d.brINN,0) as brINN
  from ck c left join def d on c.b_id=d.pin
            left join def d2 on d2.pin=d.master
            left join nc n on c.datnom=n.datnom
  where c.our_id=@our_id and c.nd>=@DateStart and c.nd<=@DateEnd
        and c.typeCK=1-- AND c.b_id IN (15979,34271)
END