CREATE procedure NearLogistic.print_bills
	@bill_stack_id int, @casher_id int, @is_old bit, @nal int =0
as
begin
	set nocount on
	select *, NearLogistic.get_marsh_string (x.mhid, x.casher_id) [bill_remark], @nal [nal] from (
  select our.ourname, our.ouraddr, our.ouraddr [ouraddr1], our.ourbik, our.ourcschet, our.ourrschet, our.ourinn, our.kpp,
  			 our.nds, our.phone, our.direktor, our.glavbuh, our.ourbank, our.ourfullname,our.ogrn,our.ogrndate, 
         isnull(c.casher_name, isnull(fc.ourname,isnull(f.gpname, f.brname))) [bill_casher],
         cast(b.bill_stack_id as varchar)+'/'+cast(b.casher_id as varchar) [bill_nom],
  			 format(s.date_create,'dd.MM.yyyy') [bill_date],
         round(sum(b.req_pay/iif(b.nal=1,1.18,1.0)),2) [bill_sum], iif(our.nds=1, round(sum(b.req_pay) - sum(b.req_pay) / 1.18,2), 0) [bill_nds],
         isnull(c.inn, isnull(fc.ourinn,isnull(f.gpinn, f.brinn))) [bill_casher_inn],
         isnull(c.kpp, isnull(fc.kpp,isnull(f.gpkpp, f.brkpp))) [bill_casher_kpp],
         isnull(c.casher_addres, isnull(fc.ouraddr,isnull(f.gpaddr, f.braddr))) [bill_casher_addres],
         isnull(c.phone, isnull(fc.phone,isnull(f.gpphone, f.brphone))) [bill_casher_phone],
         b.bill_stack_id, b.casher_id, b.mhid, b.is_old
  --from nearlogistic.bills b
  from nearlogistic.billsSum b
  left join nearlogistic.bill_stack s on s.bill_stack_id=b.bill_stack_id
  join dbo.firmsconfig our on our.our_id=22
  left join dbo.firmsconfig fc on fc.our_id=b.casher_id and b.is_old=1
  left join nearlogistic.marshrequests_cashers c on c.casher_id=b.casher_id and b.is_old=0
  left join dbo.defcontract dc on dc.dck=b.casher_id and b.is_old=1
	left join dbo.def f on f.pin=dc.pin
  where b.bill_stack_id=@bill_stack_id and b.is_old=iif(@casher_id=0,b.is_old,@is_old)
  			and b.casher_id=iif(@casher_id=0,b.casher_id,@casher_id) and b.nal=case when @nal=0 then 0 when @nal=1 then 1 else b.nal end 
  group by cast(b.bill_stack_id as varchar)+'/'+cast(b.casher_id as varchar),b.mhid,our.ourfullname,
  			 	 format(s.date_create,'dd.MM.yyyy'),isnull(c.casher_name, isnull(fc.ourname,isnull(f.gpname, f.brname))),
           our.ourname,our.ouraddr,our.ouraddr,our.ourbik,our.ourcschet,our.ourrschet,our.ourinn,our.kpp,our.nds,our.phone,our.direktor,our.glavbuh,
           our.ourbank,isnull(c.inn, isnull(fc.ourinn,isnull(f.gpinn, f.brinn))),isnull(c.kpp, isnull(fc.kpp,isnull(f.gpkpp, f.brkpp))),
         	 isnull(c.casher_addres, isnull(fc.ouraddr,isnull(f.gpaddr, f.braddr))),isnull(c.phone, isnull(fc.phone,isnull(f.gpphone, f.brphone))),
           b.bill_stack_id, our.ogrn, our.ogrndate, b.casher_id, b.mhid, b.is_old) x 
  set nocount off       
end