CREATE PROCEDURE dbo.StatPrih @nd1 datetime, @nd2 datetime
AS
BEGIN
  select c.date,YEAR(c.date)+0.01*MONTH(c.date) as P, count(c.ncom) as KolPrih, (select count(i.id) from inpdet i where i.nd=c.date) as KolStrok 
  from comman c
  where  c.date>=@nd1 and c.date<=@nd2
  group by c.date,month(c.date)
  order by c.date
END