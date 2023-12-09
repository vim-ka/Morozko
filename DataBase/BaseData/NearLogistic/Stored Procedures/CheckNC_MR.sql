
CREATE PROCEDURE [NearLogistic].CheckNC_MR @ND datetime, @Correct bit 
AS
BEGIN

  declare @datnom Bigint 
  
  set @Datnom=dbo.InDatNom(0, @ND)

  select c.datnom, c.mhid into #TempNC 
  from nc c 
  where c.datnom>=@datnom and c.mhid not in (select mhid from marsh where marsh=99 and nd>=@ND)

  select r.reqid as datnom, r.mhid into #TempMR
  from nearlogistic.marshrequests r
  where r.dt>=@ND and r.ReqType=0 and r.mhid<>271367

  select t.* from 
  (select c.datnom as datnom_nc, c.mhid as mhid_nc, r.mhid as mhid_MR, r.datnom as datnom_MR
  from #TempNC c full join #TempMR r on c.datnom=r.datnom 
   ) t
   where isnull(t.mhid_NC,0)<>isnull(t.mhid_MR,0) and isnull(t.mhid_NC,0)<>-99
      
   order by 3,1
   
  drop table #TempNC
  drop table #TempMR
   
   if @Correct = 1 
   begin
   
     update c set c.marsh=x.marsh,
               c.mhid=x.mhid
     from dbo.nc c 
     join ( 
     select m.mhid, m.marsh, mr.reqid [datnom]
     from NearLogistic.MarshRequests mr 
     join dbo.marsh m on mr.mhID=m.mhid
     where m.nd between @ND and @ND
   and not m.marsh in (0,99)
      and mr.reqtype=0) x on x.datnom=c.datnom
   
   end;
   
 /*  select r.*
from [NearLogistic].MarshRequests m left join ReqReturn r on m.ReqID=r.reqnum and m.ReqType=1
where r.mhid<>m.mhid
order by 2

select r.*, m.mhid
from [NearLogistic].MarshRequests m right join ReqReturn r on m.ReqID=r.reqnum and m.ReqType=1
where r.mhid<>isnull(m.mhid,0)
order by 2

update ReqReturn set mhid = (select m.mhid from [NearLogistic].MarshRequests m where m.ReqID=ReqReturn.reqnum and m.ReqType=1)
where reqnum in
(select r.reqnum
from [NearLogistic].MarshRequests m left join ReqReturn r on m.ReqID=r.reqnum and m.ReqType=1
where r.mhid<>m.mhid)

update ReqReturn set mhid=0 where reqnum in 
(
select r.reqnum
from [NearLogistic].MarshRequests m right join ReqReturn r on m.ReqID=r.reqnum and m.ReqType=1
where r.mhid<>isnull(m.mhid,0))
order by 2
*/
   
END