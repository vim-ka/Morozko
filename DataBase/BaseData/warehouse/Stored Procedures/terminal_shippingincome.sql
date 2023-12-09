CREATE procedure warehouse.terminal_shippingincome
@id int output,
@parentid int,
@qty int,
@dater datetime,
@srokh datetime,
@mode int,
@groupid int
as
begin
set nocount on
declare @reqid int, @erreg int, @tran varchar(50), @msg varchar(1000), @kolstr varchar(20), @flgweight bit
set @erreg=0; set @tran='warehouse.terminal_shippingincome'; set @msg=''
begin tran @tran
if @id<=0 
begin
if @parentid=0 set @erreg=1
else
begin
	--дублирование информации с родительской строки
  insert into dbo.prihodreqdet (PrihodRID, PrihodRDetHitag, PrihodRDetPrice, PrihodRDetCost, 
                                PrihodRDetTaraDSK, PrihodRDetLocked, PrihodRDetStorage, PrihodRDetLevel,
  			 			                  PrihodRDetIndex, PrihodRDetNLine, PrihodRDetDepth, PrihodRDetVolum, 
                                PrihodRDetGtd, PrihodRDetAddrID, PrihodRDetClone, PrihodRDetCloneMain,
  			 			                  PrihodRDetSummaPrice, PrihodRDetKolStr, PrihodRDetSummaCost, PrihodRDetOperatorID, 
                                PrihodRDetSkladID, PrihodRDetIsSave, PrihodRDetTara, PrihodRDetCheck, PrihodRDetNCom, 
                                PrihodRDetKol, PrihodRDetWeigth, PrihodRDetTaraVendID, PrihodRDetShelfLife,
  			 			                  PrihodRDetShelfLifeAdd, PrihodRDetLockID, PrihodRDetAfterParty, PrihodRDetMainCloneKolStr, 
                                PrihodRDetMainCloneKol, PrihodRDetflg1kg)
	select PrihodRID, PrihodRDetHitag, PrihodRDetPrice, PrihodRDetCost, 
         PrihodRDetTaraDSK, PrihodRDetLocked, PrihodRDetStorage, PrihodRDetLevel,
  			 PrihodRDetIndex, PrihodRDetNLine, PrihodRDetDepth, PrihodRDetVolum, 
         PrihodRDetGtd, PrihodRDetAddrID, 0, 1, 0, '', 0, -1, PrihodRDetSkladID, 
         0, PrihodRDetTara, 0, 0, 0, 0, PrihodRDetTaraVendID, PrihodRDetShelfLife, 
         PrihodRDetShelfLifeAdd, PrihodRDetLockID, 0, '', 1, PrihodRDetflg1kg
  from dbo.prihodreqdet 
  where prihodrdetid=@parentid
  select @id=@@identity
end
end

if @id<=0 set @erreg=2 else
begin
	select @reqid=prihodrid from dbo.prihodreqdet where prihodrdetid=@id
  update d set d.prihodrdetkolstr=iif(n.flgweight=1,warehouse.weight_gram_to_str(@qty),'+'+cast(@qty as varchar)),
               d.prihodrdetdate=@dater, d.prihodrdetsrokh=@srokh, d.sklad_done=cast(1 as bit),
               d.shipping_mode=@mode, d.sklad_group_id=@groupid
  from dbo.prihodreqdet d
  join dbo.nomen n on n.hitag=d.prihodrdethitag
  where d.prihodrdetid=@id
	--/*
  update n set n.shelflife=datediff(day, @dater, @srokh)
  from dbo.nomen n 
  join dbo.prihodreqdet d on n.hitag=d.prihodrdethitag
  where d.prihodrdetid=@id
  --*/
end

if (@erreg & 1)<>0 set @msg=@msg+'не объявлен код заявки для создания;'+char(13)+char(10) 
if (@erreg & 2)<>0 set @msg=@msg+'не удалось дублировать строку;'+char(13)+char(10) 
if @erreg=0 and @@trancount>0 commit tran @tran else rollback tran @tran
select cast(iif(@erreg=0,0,1) as bit) [res], @msg [msg]
if @msg='' exec dbo.calcprihod @reqid
set nocount off
end