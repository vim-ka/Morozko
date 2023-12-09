
CREATE procedure NearLogistic.calculate_bills
@nd1 datetime, @nd2 datetime, @out_msg varchar(5000) out
as
begin
set @out_msg=''
declare @mhid int, @e int, @msg varchar(500) ='', @marsh varchar(50)
declare cur cursor for 
select mhid from dbo.marsh where nd between @nd1 and @nd2 and hand_calc=0 and mstatus in (3,4)
except select mhid 
       --from nearlogistic.bills 
         from nearlogistic.billsSum  
        where bill_stack_id>0 group by mhid
open cur fetch next from cur into @mhid
while @@fetch_status=0 
begin
	set @e=0; set @msg='';
  --print @mhid
  exec nearlogistic.calculate_prebill @mhid=@mhid,@debug=0,@error=@e out,@msg=@msg out
  
  if @e>0 
  begin
  	select @marsh='#'+cast(marsh as varchar)+' от '+convert(varchar,nd,104)+' ['+cast(mhid as varchar)+']' from dbo.marsh where mhid=@mhid
    set @out_msg=@out_msg+@marsh+': '+char(13)+@msg+char(13)
  end
  
  fetch next from cur into @mhid
end
close cur deallocate cur
if @out_msg='' set @out_msg='данные рассчитаны'
end