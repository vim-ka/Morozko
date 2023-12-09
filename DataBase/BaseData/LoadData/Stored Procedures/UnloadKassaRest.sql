CREATE PROCEDURE [LoadData].UnloadKassaRest @DateStart datetime, @DateEnd datetime, @our_id int
AS
BEGIN

  select
       c.oper,
       c.nd, 
       c.p_id,
       c.plata,
       c.remark
  from kassa1 c 
  where c.our_id=@our_id and c.nd>=@DateStart and c.nd<=@DateEnd and c.oper=59
END