CREATE PROCEDURE dbo.test
AS
  SELECT def.pin, def.brname, def.braddr, def.brinn, def.gpAddr
    FROM def
  ORDER BY def.brname ASC 
  
  SELECT 
    'КОД' as pin, 'Наименование' AS brname, 'Юридический адрес' AS braddr, 'ИНН' as brinn, 'Физический адрес' AS gpAddr