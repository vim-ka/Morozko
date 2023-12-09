CREATE PROCEDURE dbo.GetNCDatnomFromMarsh
@datnom bigint
AS
BEGIN
  declare @m int
  declare @nd datetime 


  select @m=m.marsh, @nd=c.nd
  from nc c 
  JOIN marsh m ON c.mhID = m.mhid
  where c.datnom=@datnom

  select c.datnom
  from nc c
  JOIN marsh m ON c.mhID = m.mhid
  where c.nd=@nd and m.marsh=@m
END