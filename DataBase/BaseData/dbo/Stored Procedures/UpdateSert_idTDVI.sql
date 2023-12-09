CREATE PROCEDURE dbo.UpdateSert_idTDVI
@hitag int,
@sert_id int,
@producer_id int
AS
BEGIN
  update tdvi set sert_id=@sert_id, ProducerID=@producer_id
  where hitag=@hitag
  
  update nomen set sert_id=@sert_id, LastProducerID=@producer_id
  where hitag=@hitag
END