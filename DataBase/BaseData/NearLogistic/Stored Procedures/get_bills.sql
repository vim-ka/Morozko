CREATE procedure NearLogistic.get_bills @mhid int, @force bit=0, @sum INT = 3, @error int out, @msg varchar(500) out
as 
begin
set nocount on
 
--перерасчет временных данных
if @force=1 exec nearlogistic.calculate_prebill_sum @mhid, 0, @error out, @msg out
DECLARE @mode int
--вывести счета к оплате
IF @sum = 1 --вручную
BEGIN
  IF NOT EXISTS(SELECT 1 FROM nearlogistic.billsSum bs WHERE bs.mhid = @mhid)  
  SET @mode = 1
  ELSE SET @mode = 3
  --заполняем отсутствующими данными
  INSERT INTO NearLogistic.billsSum(mhid, casher_id, nal)
  SELECT DISTINCT b.mhid, b.casher_id, b.nal
    FROM nearlogistic.bills b 
   WHERE b.mhid = @mhid
  EXCEPT
  SELECT DISTINCT bs.mhid, bs.casher_id, bs.nal
    FROM nearlogistic.billsSum bs
   WHERE bs.mhid = @mhid
  -------------------------------------------------------------------------
  --вывод данных
  select bs.bill_id, bs.casher_id, isnull(c.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))) [casher_name], 
         bs.recCount AS cnt, mas, vol, 
  			 bs.distance, bs.realdist, bs.req_pay AS sum, bs.bill_stack_id, bs.nal, @mode AS mode, nlTariffParamsID
  from nearlogistic.billsSum bs
  left join nearlogistic.marshrequests_cashers c on c.casher_id = bs.casher_id --and bs.is_old=0
  left join dbo.firmsconfig fc on fc.our_id = bs.casher_id --and bs.is_old=1
  left join dbo.defcontract dc on dc.dck = bs.casher_id --and bs.is_old=1
  left join dbo.def f on f.pin=dc.pin
  where bs.mhid=@mhid
END
ELSE IF @sum = 2  --автоматически    
select -1 AS bill_id, b.casher_id, isnull(c.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))) [casher_name], 
       count(b.reqid) [cnt], sum(mas) [mas], sum(vol) [vol], 
			 sum(distance) [distance], 0.0 [realdist],
       sum(b.req_pay) [sum], b.bill_stack_id, b.nal, 2 AS mode, nlTariffParamsID
from nearlogistic.bills b
left join nearlogistic.marshrequests_cashers c on c.casher_id=b.casher_id and b.is_old=0
left join dbo.firmsconfig fc on fc.our_id=b.casher_id and b.is_old=1
left join dbo.defcontract dc on dc.dck=b.casher_id and b.is_old=1
left join dbo.def f on f.pin=dc.pin
where b.mhid=@mhid
group by b.casher_id, isnull(c.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))), 
         b.bill_stack_id, b.nal, nlTariffParamsID

ELSE IF @sum = 3  --проверка
BEGIN
  IF EXISTS (SELECT 1 FROM nearlogistic.billsSum bs WHERE bs.mhid = @mhid)
  --если заполнено вручную
  select bs.bill_id, bs.casher_id, isnull(c.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))) [casher_name], 
         bs.recCount AS cnt, mas, vol, 
			   bs.distance, bs.realdist, bs.req_pay AS sum, bs.bill_stack_id, bs.nal, 3 AS mode, nlTariffParamsID
    from nearlogistic.billsSum bs
    left join nearlogistic.marshrequests_cashers c on c.casher_id = bs.casher_id --and bs.is_old=0
    left join dbo.firmsconfig fc on fc.our_id = bs.casher_id --and bs.is_old=1
    left join dbo.defcontract dc on dc.dck = bs.casher_id --and bs.is_old=1
    left join dbo.def f on f.pin=dc.pin
    where bs.mhid=@mhid  
  ELSE  --если вручную не заполнено
  select -1 AS bill_id, b.casher_id, isnull(c.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))) [casher_name], 
         count(b.reqid) [cnt], sum(mas) [mas], sum(vol) [vol], 
  			 sum(distance) [distance], 0.0 [realdist], sum(b.req_pay) [sum], b.bill_stack_id, b.nal, 2 AS mode, nlTariffParamsID
  from nearlogistic.bills b
  left join nearlogistic.marshrequests_cashers c on c.casher_id=b.casher_id and b.is_old=0
  left join dbo.firmsconfig fc on fc.our_id=b.casher_id and b.is_old=1
  left join dbo.defcontract dc on dc.dck=b.casher_id and b.is_old=1
  left join dbo.def f on f.pin=dc.pin
  where b.mhid=@mhid
  group by b.casher_id, isnull(c.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))), 
           b.bill_stack_id, b.nal, b.nlTariffParamsID
END


set nocount off
end