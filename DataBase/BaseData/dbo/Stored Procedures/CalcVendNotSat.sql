CREATE PROCEDURE CalcVendNotSat @day0 datetime, @day1 datetime
AS
BEGIN
  select n.*, nn.*, (select fam from vendors where ncod = n.ncod) ffam
   from NotSat n   
   left join nomen nn on n.hitag=nn.hitag  
   where n.nd >= @day0 and n.nd <= @day1 
   order by n.ncod, n.hitag

END