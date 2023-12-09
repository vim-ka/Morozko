
CREATE PROCEDURE AddArcSk
  @nd datetime, @tekid int, @startid int,
  @pin int, @hitag int, @sklad tinyint,
  @start float, @startthis float, @morn float,
  @sell float, @price money, @cost money,
  @minp int, @mpu INT
AS
 insert into ArcSK(nd, tekid, pin, hitag, sklad, start, startthis, morn, sell, price, cost, minp, mpu)
 values(@nd, @tekid, @pin, @hitag, @sklad, @start, @startthis, @morn, @sell, @price, @cost, @minp, @mpu)