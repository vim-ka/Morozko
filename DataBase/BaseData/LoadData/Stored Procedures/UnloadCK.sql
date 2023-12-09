CREATE PROCEDURE [LoadData].UnloadCK  @DateStart datetime, @DateEnd datetime, @our_id int
AS
BEGIN
  select
       c.b_id as vk,
       n.startdatnom as vkdatnom,
       c.plata,
       c.nd
  from kassa1 c join nc n on c.sourdatnom=n.datnom
  where c.our_id=@our_id and c.nd>=@DateStart and c.nd<=@DateEnd and c.oper=-2 and c.bank_id=0 and c.act='ВЫ'  
        and c.Actn=0 
        and c.remark not like '%компенсация отрицательного сальдо%'
END