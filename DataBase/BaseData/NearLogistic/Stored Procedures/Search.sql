
CREATE PROCEDURE NearLogistic.Search
@nd datetime,
@nom int,
@mhid int out,
@mrID int out
AS
BEGIN
 declare @datnom Bigint
  if @nom<10000 set @datnom=dbo.InDatNom(@nom,@nd)
  set @mhid=0
  set @mrid=0
  select @mhid=mhid,
      @mrid=mrID 
  from NearLogistic.MarshRequests 
  where reqid=@nom 
     or reqid=@datnom
END;