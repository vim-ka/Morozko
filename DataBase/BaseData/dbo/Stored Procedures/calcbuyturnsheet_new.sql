CREATE procedure dbo.calcbuyturnsheet_new
@pin int,
@use_net bit,
@dcklist varchar(100),
@nd1 datetime,
@nd2 datetime
as
begin
--переменные
set nocount on
declare @datnom1 bigint
declare @datnom2 bigint
declare @our_id int

declare @actn int
declare @saldo decimal(20,4)
declare @saldo1 decimal(20,4)
declare @saldo2 decimal(20,4)
declare @sp decimal(20,4)
declare @sum decimal(20,4)
declare @izm decimal(20,4)
declare @back decimal(20,4)
declare @ourName varchar(100), @ID int

set @datnom1=dbo.indatnom(0,@nd1)
set @datnom2=dbo.indatnom(99999,@nd2)

if object_id('tempdb..#res') is not null drop table #res
if object_id('tempdb..#contracts') is not null drop table #contracts
create table #contracts(dck int, gpname varchar(255),contact varchar(50),gpphone varchar(50),brphone varchar(50),master int)
create nonclustered index contracts_idx on #contracts(dck)

if isnull(@dcklist,'')<>''
begin
	insert into #contracts 
  select dc.dck, d.gpname, d.contact, d.gpphone, d.brphone, iif(@use_net=1,dc.dckmaster,dc.dck) [master]     
  from dbo.defcontract dc 
  join dbo.def d on d.pin=dc.pin
  join string_split(@dcklist,',') s on s.value=iif(@use_net=1,dc.dckmaster,dc.dck) 
  group by dc.dck, d.gpname, d.contact, d.gpphone, d.brphone, iif(@use_net=1,dc.dckmaster,dc.dck)
end
else 
begin
	insert into #contracts 
  select dc.dck, d.gpname, d.Contact, d.gpphone, d.brphone, iif(@use_net=1,dc.dckmaster,dc.dck) [master]     
  from dbo.defcontract dc 
  join dbo.def d on d.pin=dc.pin
  where iif(@use_net=1,d.master,d.pin)=@pin 
  group by dc.dck, d.gpname, d.contact, d.gpphone, d.brphone, iif(@use_net=1,dc.dckmaster,dc.dck)    
end

select @our_id=max(our_id) from dbo.defcontract where dck in (select dck from #contracts)
set @ourName=(select ourName from FirmsConfig where our_id=@Our_ID)

--выборка накдадных 

select * into #res from (
select c.datnom as id,c.nd, c.b_id, c.tm, cast(c.datnom%10000 as varchar) [datnumber],
       cast(isnull(c.actn,0) as bit) [actn], c.srok, c.sp, c.sc, c.extra, c.ourid, 0 [sum],
       null [izmsum], null [back], 
       case when c.sp>0 then cast(c.b_id as varchar)+' '+d.gpname
       			when c.sp<0 and c.docnom is not null and c.docdate is not null then '(№'+c.docnom+' от '+convert(varchar,c.docdate,104)+')'
            else '' end [remark],
			 null [bank], null [kassid], c.dck, isnull(c.docnom,'') [docnom], c.docdate,
       0 [type]                          
from dbo.nc c
     join #contracts d on d.dck=c.dck 
where  c.datnom between @datnom1 and @datnom2
       and c.tara=0 and c.frizer=0 
group by c.nd, c.b_id, c.tm, c.actn, c.datnom, c.srok, c.sp, c.sc, c.extra, c.ourid, c.back, c.dck, c.docnom, c.docdate, d.gpname

union --выборка кассовых операций

select max(ks.kassid) as id,iif(isnull(ks.bank_id,0)<>0, ks.bankday, ks.nd) [nd], min(ks.B_Id), min(ks.Tm), null, cast(IsNull(ks.Actn,0) as bit), null,
       null, null, null, null, iif(ks.act='ВЫ',sum(ks.plata),null), null, iif(ks.act='ВО',sum(ks.plata),null),
       ks.Remark + isnull(' Дов. №'+ d.dovnom+' от '+ convert(char(10),d.dovnom,104)+'г.','') [remark],
       ks.bank_id, min(ks.kassid), min(ks.dck) [dck], isnull(d.dovnom,''), d.ndbeg,
       1 [type]
from dbo.kassa1 ks 
     join #contracts c on c.dck=ks.dck
     join dbo.nc a on a.datnom=ks.sourdatNom 
     left join dbo.dover d on ks.origrecn=d.dovid
where a.Tara = 0 and a.Frizer = 0 and a.Actn = 0 and
      ks.oper=-2 and (ks.act='ВЫ' or ks.act='ВО')      
     	and ((isnull(ks.bank_id,0)=0 and ks.nd between @nd1 and @nd2) or (isnull(ks.bank_id,0)<>0 and ks.bankday between @nd1 and @nd2)) 
group by ks.nd,ks.bankday, ks.actn,ks.act,ks.remark,ks.bank_id,d.dovnom,d.ndbeg

union --выборка переоценки по накладным

select max(izm.nid) as id, izm.nd, min(izm.b_id), min(izm.tm), null, cast(0 as bit), null, null, null, null, null, null,
       sum(izm.izmen), null, izm.remark, null, null, izm.dck, null, null,
       2 [type]
from dbo.ncizmen izm
join #contracts d on d.dck=izm.dck 
where izm.nd between @nd1 and @nd2
group by izm.nd,izm.remark,izm.dck  

union --выборка возвратов

select r.Rk as id, convert(varchar,r.nd, 104), n.pin, r.tm, cast(r.rk as varchar), cast(1 as bit) [actn], null, (-1)*sum(rd.kol*rd.tovprice), null, null, null, null,
       null, null, 'Заявка на возврат №'+cast(r.rk as varchar), null, null, n.dck, null, null,
       3 [type]
from dbo.requests r 
     join dbo.reqreturn n on r.rk=n.reqnum
     join #contracts d on d.dck=n.dck
     join dbo.reqreturndet rd on rd.reqretid=n.reqnum
where r.rs not in (6,7)
group by r.nd, n.pin, r.tm, r.rk, n.dck ) [res]


alter table #res add saldo1 decimal(20,4), saldo2 decimal(20,4)
--/*
set @saldo=isnull((
    select sum(sp) from dbo.nc c
    join #contracts d on d.dck=c.dck 
    where  c.datnom<@datnom1 and c.tara=0 and c.frizer=0 and c.actn=0),0)

set @saldo=@saldo-isnull((
    select sum(ks.plata) from dbo.kassa1 ks 
    join #contracts c on c.dck=ks.dck
    join dbo.nc a on a.datnom=ks.sourdatNom 
    where a.Tara = 0 and a.Frizer = 0 and ks.oper=-2 and (ks.act='ВЫ' or ks.act='ВО')    
          and ((isnull(ks.bank_id,0)=0 and ks.nd<@nd1) or (isnull(ks.bank_id,0)<>0 and ks.bankday<@nd1))),0)

set @saldo=@saldo+isnull((
    select sum(izmen) from dbo.ncizmen izm
    join #contracts d on d.dck=izm.dck 
    where izm.nd<@nd1),0)
--*/     
set @saldo1=@saldo
declare oborot_cursor cursor for
select id, actn,sp,sum,izmsum,back from #res order by nd, tm--for update

open oborot_cursor
fetch next from oborot_cursor into @id, @actn,@sp,@sum,@izm,@back
while @@fetch_status=0
begin
	if (@actn = 0)
  begin               
    if (@sp is not null) set @saldo2=@saldo1+@sp
    else if (@sum is not null) set @saldo2=@saldo1-@sum            
    else if (@izm is not null) set @saldo2=@saldo1+@izm
    else if (@back is not null) set @saldo2=@saldo1-@back
  end
  else
  if ((@actn=1) and (@sp is not null))
  begin
    set @saldo2=@saldo1
  end
  else 
  begin
    if (@sum is not null) set @saldo2=@saldo1-@sum            
    else if (@izm is not null) set @saldo2=@saldo1+@izm
    else if (@back is not null) set @saldo2=@saldo1-@back  
  end
	
  update a set a.saldo1=@saldo1,
               a.saldo2=@saldo2
  from #res a
  where id=@ID--current of oborot_cursor
  
  fetch next from oborot_cursor into @id,@actn,@sp,@sum,@izm,@back
  set @saldo1=@saldo2
end
close oborot_cursor
deallocate oborot_cursor

select *, @Our_ID as PrintOur_ID, @ourName as OurName from #res
join #contracts on #res.dck=#contracts.dck
order by nd,tm

if object_id('tempdb..#contracts') is not null drop table #contracts
if object_id('tempdb..#res') is not null drop table #res
set nocount off
end