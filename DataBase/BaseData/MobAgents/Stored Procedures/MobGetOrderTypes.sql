CREATE PROCEDURE MobAgents.[MobGetOrderTypes] @ag_id int
AS
BEGIN

  select  
    Ident,
    TypeName,
    [Order],
    Rest,
    flgAllowBaseUnit,
    flgAllowZeroCount,
    flgNoSaleStatistic
  from 
    MobAgents.OrderTypes;
    
END