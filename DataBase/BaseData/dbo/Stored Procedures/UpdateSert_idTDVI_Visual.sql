CREATE PROCEDURE dbo.UpdateSert_idTDVI_Visual
@hitag int,
@startid INT,
@sert_id int,
@producer_id int
AS
BEGIN

DECLARE @Dater DATETIME, @Srokh DATETIME

  update tdvi set sert_id=@sert_id, ProducerID=@producer_id
  where hitag=@hitag

  update visual set visual.sert_id = @sert_id, visual.ProducerID=@producer_id
   where visual.startid=@startid

  update nomen set sert_id=@sert_id, LastProducerID=@producer_id
  where hitag=@hitag



  SET @Dater = (SELECT TOP 1 tdvi.DATER FROM tdvi WHERE tdvi.STARTID = @startid AND tdVi.DATER IS NOT NULL) 

  SET @Srokh = (SELECT TOP 1 tdvi.SROKH FROM tdvi WHERE tdvi.STARTID = @startid AND tdvi.SROKH IS NOT NULL)  

  IF @Dater IS NOT NULL 
  BEGIN 
    UPDATE tdvi 
       SET tdvi.DATER = @Dater 
     WHERE tdvi.STARTID = @startid 


    UPDATE visual 
       SET visual.DATER = @Dater 
     WHERE visual.STARTID = @startid 

    END      


  IF @Srokh IS NOT NULL
  BEGIN 
    UPDATE tdvi 
       SET tdvi.SROKH = @Srokh 
     WHERE tdvi.STARTID = @startid 


    UPDATE visual 
       SET visual.SROKH = @Srokh 
     WHERE visual.STARTID = @startid 

    END


END