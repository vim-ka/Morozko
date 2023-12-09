CREATE PROCEDURE dbo.NewPrihodReq
@dck int,
@pin int,
@ncod int,
@op int,
@safe bit,
@ndoc varchar(20)=null,
@ntn varchar(30)=null,
@docdate datetime=null,
@tndate datetime=null,
@PrihodReqID int OUT 
AS
BEGIN
  insert into prihodreq (	PrihodRDefContract,
                          PrihodRVenderPin,
                          PrihodRVendersID,
                          PrihodRDefSafeCust,
                          PrihodRDocNum,
                          PrihodRTNNum,
                          PrihodRDocDate,
                          PrihodRTNDate,
                          PrihodROperatorID,
                          PrihodRDone,
                          PrihodRDate)
	values (@dck,
  				@pin,
          @ncod,
          @safe,
          @ndoc,
          @ntn,
          @docdate,
          @tndate,
          @op,
          0,
          convert(varchar,getdate(),4))
          
 	set @PrihodReqID=@@IDENTITY         
	select @PrihodReqID
END