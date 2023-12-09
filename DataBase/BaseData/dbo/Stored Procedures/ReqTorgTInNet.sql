CREATE PROCEDURE dbo.ReqTorgTInNet @pin int, @gpName varchar(64), @gpAddr varchar(128), @gpPhone varchar(64), @setiname int
AS
if object_id('tempdb..#rtt') is not null drop table #rtt
create table #rtt(pin int, gpName varchar(64), gpAddr varchar(128), gpPhone varchar(64))

if @pin = -1 and @setiname = 0 --сама выбранная точка
  insert into #rtt 
  select -1 pin, upper(@gpName) gpName, upper(@gpAddr) gpAddr, upper(@gpPhone) gpPhone
if @pin = -1 and @setiname <> 0 --точки, привязанные к мастеру сети
  insert into #rtt 
--  select iif(newpin is null, -1, newpin) pin, upper(naim), upper(factaddress), upper(phonett) from dbo.reqtorgt where setiname = @setiname
  select -1, upper(naim), upper(factaddress), upper(phonett) from dbo.reqtorgt where setiname = @setiname or newpin = @setiname
  union all           
  select -1, iif(gpName is null, upper(brName), upper(gpName)) gpName, iif(gpAddr is null, upper(brAddr), upper(gpAddr)) gpAddr, 
  	iif(gpPhone is null, upper(brPhone), upper(gpPhone)) gpPhone
  from def where master = @setiname and worker = 0 and actual = 1
if @pin <> -1 and @setiname = 0 --точка заведена, но не указан мастер сети
  insert into #rtt 
--  select iif(newpin is null, -1, newpin) pin, upper(naim), upper(factaddress), upper(phonett) from dbo.reqtorgt where setiname = @pin
  select -1, upper(naim), upper(factaddress), upper(phonett) from dbo.reqtorgt where setiname = @pin
  union all  
  select -1, iif(gpName is null, upper(brName), upper(gpName)) gpName, iif(gpAddr is null, upper(brAddr), upper(gpAddr)) gpAddr, 
  	iif(gpPhone is null, upper(brPhone), upper(gpPhone)) gpPhone
  from def where pin = @pin
if @pin <> -1 and @setiname <> 0 --точка заведена и указан мастер сети 
  insert into #rtt 
--  select pin, iif(gpName is null, upper(brName), upper(gpName)) gpName, iif(gpAddr is null, upper(brAddr), upper(gpAddr)) gpAddr, 
  select -1, iif(gpName is null, upper(brName), upper(gpName)) gpName, iif(gpAddr is null, upper(brAddr), upper(gpAddr)) gpAddr, 
  	iif(gpPhone is null, upper(brPhone), upper(gpPhone)) gpPhone
  from def where (master = @pin or master = @setiname or pin = @pin) and worker = 0 and actual = 1

--select distinct * from #rtt
select r.pin, r.gpName, r.gpAddr, (select top 1 gpPhone from #rtt where gpName = r.gpName and gpAddr = r.gpAddr) gpPhone from #rtt r
group by r.pin, r.gpName, r.gpAddr