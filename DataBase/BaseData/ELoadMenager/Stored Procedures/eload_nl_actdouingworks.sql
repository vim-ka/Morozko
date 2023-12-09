CREATE procedure ELoadMenager.eload_nl_actdouingworks
@id int
as
begin
	set nocount on
  declare @ahid int
  select @ahid=p.additionalheaderid from nearlogistic.nllistpay p where p.listno=@id
  if object_id('tempdb..#res') is not null drop table #res
  if object_id('tempdb..#base') is not null drop table #base
  
  select a.persid [crid], a.sum [oplata] into #base 
  from hrmain.dbo.additional a
  where a.additionalheaderid=@ahid and a.additionaltypeid=998

	select  c.crid, c.crname, c.urarrd, c.factaddr, c.crbik, c.crcs, c.crrs, c.crinn, c.crkpp,
  				c.nds, isnull(b.bname,'') [bname], l.oplatasum+l.oplataother+l.bonus [oplata], l.listno, l.nd [ndmarsh], l.marsh,
          /*d.fio*/ c.crname [driver], v.model, v.regnom, p.nd, l.mhid, c.pin, 0 [ord],NearLogistic.GetMarshRegString(l.mhid) AS Direction

  into #res
	from nearlogistic.nllistpaydet l
  join nearlogistic.nllistpay p on p.listno=l.listno
	join dbo.vehicle v on v.v_id=l.v_id
	join dbo.carriers c on c.crid=v.crid
  left join dbo.banks b on b.bank_id=c.bank_id
  left join dbo.drivers d on d.drid=l.drid
  where l.listno=@id and c.crid<>7
  
  update a set a.ord=b.ord
  from #res a 
  join (
  select row_number() over(order by crname) [ord], crid from (
  select crid, crname from #res group by crid, crname) x) b on b.crid=a.crid
  
  update b set b.[oplata]=b.[oplata]-x.[oplata]
  from #base b
  join (select crid, sum([oplata]) [oplata] from #res group by #res.crid) x on x.crid=b.crid
  --/*

  update z set z.oplata=z.oplata+b.oplata
  from #res z 
  join #base b on b.crid=z.crid
  where z.mhid in (select c.mhid from (
  								 select a.mhid, row_number() over(partition by crid order by oplata desc) [x] from #res a) c
  								 where c.x=1)
  --*/
  select * from #res order by pin
  --select * from #base
  
  if object_id('tempdb..#res') is not null drop table #res
  set nocount off
end