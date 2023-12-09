CREATE PROCEDURE dbo.PrihodRAdd
  @PrihodRDate datetime,@PrihodROperatorID int,@PrihodRVendersID int,
  @PrihodRSumPrice money,@PrihodRSumCost money,
  @PrihodRDone tinyint,@PrihodRDocNum varchar(10),@PrihodRDocDate datetime,
  @PrihodRComp varchar(16),@PrihodRTNNum  varchar(30),@PrihodRTNDate datetime,
  @PrihodRDefContract int,@PrihodROrdersID int,@PrihodRid int OUT
as
BEGIN

insert into PrihodReq (PrihodRDate,PrihodROperatorID,PrihodRVendersID,PrihodRSumPrice,PrihodRSumCost,PrihodRDone,
PrihodRDocNum,PrihodRDocDate,PrihodRComp,PrihodRTNNum,PrihodRTNDate,PrihodRDefContract,PrihodROrdersID)
values (@PrihodRDate,@PrihodROperatorID,@PrihodRVendersID,@PrihodRSumPrice,@PrihodRSumCost,@PrihodRDone,
@PrihodRDocNum,@PrihodRDocDate,@PrihodRComp,@PrihodRTNNum,@PrihodRTNDate,@PrihodRDefContract,@PrihodROrdersID);

 set @PrihodRid=@@IDENTITY
 select @PrihodRid  
END