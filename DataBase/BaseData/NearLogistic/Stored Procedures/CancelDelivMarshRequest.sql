
CREATE PROCEDURE NearLogistic.CancelDelivMarshRequest
@ids varchar(max), --формат строки mhid;mrID;nvID#
@mhID int,
@ResID int,
@remark varchar(500),
@op int,
@isSet bit
AS
BEGIN
if object_id('tempdb..#reqlist_') is not null drop table #reqlist_
 
create table #reqlist_ (mhid int, mrid int, nvid int)
declare @ttable varchar(50) 
declare @ermsg varchar(1000)
set @ermsg=''
set @ttable='##'+host_name()+'_reqlist_cancel'
declare @ids_req varchar(5000)
declare @sql varchar(max)
declare @mhid_req int
set @ids_req=''+char(10)+char(13)
set @sql=''
set @sql='if object_id(''tempdb..'+@ttable+''') is not null drop table '+@ttable+' '
set @sql=@sql+' exec nearlogistic.gettablefromstrings '''+@ids+''',''mhID;mrID;nvID'','';'',''#'','''+@ttable+''''
set @sql=@sql+' insert into #reqlist_ select cast(mhID as int),cast(mrID as int),cast(nvID as int) from '+@ttable+' '
set @sql=@sql+' drop table '+@ttable+' '
exec(@sql)
   
if exists(select 1 from #reqlist_ where isnull(mhid,0)<>0)
begin
--отмена доставки маршрутов
  update m set m.DelivCancel=@isSet,
         m.mstatus=iif(@isSet=1,5,0)
  from dbo.marsh m
  inner join (select #reqlist_.mhid from #reqlist_ where isnull(#reqlist_.mhid,0)<>0) r on r.mhid=m.mhid
  
  update c set c.DelivCancel=@isSet
  from dbo.nc c
  where c.datnom in (select mr.ReqID 
            from NearLogistic.MarshRequests mr
                     inner join (select #reqlist_.mhid from #reqlist_ where isnull(#reqlist_.mhid,0)<>0) r on r.mhid=mr.mhid
                     where mr.ReqType=0)
  
  delete d
  from dbo.DelivCancel d 
  inner join (select #reqlist_.mhid from #reqlist_ where isnull(#reqlist_.mhid,0)<>0) r on r.mhid=d.mhid                     
  
  if @isSet=1                   
 insert into dbo.DelivCancel(mhID,Marsh,NDMarsh,Datnom,nvID,FCancel,Remark,OP,resID)
  select m.mhid,m.marsh,m.nd,0,0,@isSet,@remark,@op,@resID
  from dbo.marsh m
  inner join (select #reqlist_.mhid from #reqlist_ where isnull(#reqlist_.mhid,0)<>0) r on r.mhid=m.mhid                     
  
  update mr set mr.DelivCancel=@isSet
  from NearLogistic.MarshRequests mr
  where mr.mhid in (select isnull(#reqlist_.mhid,0) from #reqlist_ where isnull(#reqlist_.mhid,0)<>0)
  
  --выбрасывание возвратов
  if @isSet=1
  begin
   select @ids_req=stuff((
                select N'#'+cast(mr.ReqID as varchar)+';'+cast(mr.ReqType as varchar)+';'+cast(mr.ReqAction as varchar)
                from NearLogistic.MarshRequests mr
                where mr.mhid in (select #reqlist_.mhid from #reqlist_ where isnull(#reqlist_.mhid,0)<>0)
                   and mr.ReqType=1                      
                group by mr.reqid, mr.reqtype, mr.reqaction
                for xml path(''), type).value('.','varchar(max)'),1,0,'')
   --print 'exec NearLogistic.MarshRequetOperations'  
    --print '@ids_req='+@ids_req
    exec NearLogistic.MarshRequetOperations @ids_req, 0, @op, 1, @ermsg, 1
    --print '@ermsg= '+@ermsg    
  end 
end

if exists(select 1 from #reqlist_ where isnull(mrid,0)<>0)
begin
--отмена доставки накладных 
 update c set c.DelivCancel=@isSet
  from dbo.nc c 
  inner join NearLogistic.MarshRequests mr on mr.reqid=c.datnom and reqtype=0
  inner join (select #reqlist_.mrid from #reqlist_ where isnull(#reqlist_.mrid,0)<>0) r on r.mrid=mr.mrid
  
  delete d
  from dbo.DelivCancel d 
  inner join NearLogistic.MarshRequests mr on mr.reqid=d.datnom and mr.reqtype in (0,1)
  inner join (select #reqlist_.mrid from #reqlist_ where isnull(#reqlist_.mrid,0)<>0) r on r.mrid=mr.mrid  
  
  if @isSet=1
  begin
  insert into dbo.DelivCancel(mhID,Marsh,NDMarsh,Datnom,nvID,FCancel,Remark,OP,resID,reqid,reqtype)
   select 0,0,mr.ReqND,iif(mr.reqtype=0,mr.ReqID,0),0,@isSet,@remark,@op,@resID,mr.reqid,mr.reqtype
   from NearLogistic.MarshRequests mr 
   inner join (select #reqlist_.mrid from #reqlist_ where isnull(#reqlist_.mrid,0)<>0) r on r.mrid=mr.mrid        
    where mr.reqtype in (0,1)
  end
  
  update mr set mr.DelivCancel=@isSet
  from NearLogistic.MarshRequests mr
  inner join (select #reqlist_.mrid from #reqlist_ where isnull(#reqlist_.mrid,0)<>0) r on r.mrid=mr.mrid 
  
  --выбрасывание возвратов
  if @isSet=1
  begin
   set @mhid_req=(select top 1 mhid from NearLogistic.MarshRequests mr where mr.mrid in (select #reqlist_.mrid from #reqlist_ where isnull(#reqlist_.mrid,0)<>0))
    select @ids_req=stuff((
                select N'#'+cast(mr.ReqID as varchar)+';'+cast(mr.ReqType as varchar)+';'+cast(mr.ReqAction as varchar)
                from NearLogistic.MarshRequests mr
                where mr.mhid=@mhid_req
                   and mr.ReqType=1
                      and (mr.PINTo in (select mr.PINto from NearLogistic.MarshRequests mr where mr.mrid in (select #reqlist_.mrid from #reqlist_ where isnull(#reqlist_.mrid,0)<>0))
                      or mr.PINTo in   (select f.vmaster from NearLogistic.MarshRequests mr join dbo.def f on f.pin=mr.pinto where mr.mrid in (select #reqlist_.mrid from #reqlist_ where isnull(#reqlist_.mrid,0)<>0))
                      or mr.PINTo in   (select f.pin from NearLogistic.MarshRequests mr join dbo.def f on f.vmaster=mr.pinto where mr.mrid in (select #reqlist_.mrid from #reqlist_ where isnull(#reqlist_.mrid,0)<>0))
                      )
                      --and not exists(select 1 from #reqlist_ where isnull(#reqlist_.mrid,0)=mr.mrid)
                      
                group by mr.reqid, mr.reqtype, mr.reqaction
                for xml path(''), type).value('.','varchar(max)'),1,1,'')
   
   insert into dbo.DelivCancel(mhID,Marsh,NDMarsh,Datnom,nvID,FCancel,Remark,OP,resID,reqid,reqtype)
   select distinct 0,0,mr.ReqND,iif(mr.reqtype=0,mr.ReqID,0),0,@isSet,@remark,@op,@resID,mr.reqid,mr.reqtype
   from NearLogistic.MarshRequests mr 
   where mr.mhid=@mhid_req
          and mr.ReqType=1
          and (mr.PINTo in (select mr.PINto from NearLogistic.MarshRequests mr where mr.mrid in (select #reqlist_.mrid from #reqlist_ where isnull(#reqlist_.mrid,0)<>0))
          or mr.PINTo in   (select f.vmaster from NearLogistic.MarshRequests mr join dbo.def f on f.pin=mr.pinto where mr.mrid in (select #reqlist_.mrid from #reqlist_ where isnull(#reqlist_.mrid,0)<>0))
          or mr.PINTo in   (select f.pin from NearLogistic.MarshRequests mr join dbo.def f on f.vmaster=mr.pinto where mr.mrid in (select #reqlist_.mrid from #reqlist_ where isnull(#reqlist_.mrid,0)<>0))
          )
    
    exec NearLogistic.MarshRequetOperations @ids_req, 0, @op, 1, @ermsg, 1
    --print '@ermsg= '+@ermsg
  end   
end

if exists(select 1 from #reqlist_ where isnull(nvid,0)<>0)
begin
--отмена доставки товаров
/*
 update v set v.DelivCancel=@isSet
  from dbo.nv v
  inner join (select #reqlist_.nvid from #reqlist_ where isnull(#reqlist_.nvid,0)<>0) r on r.nvid=v.nvid
*/  
  delete d
  from dbo.DelivCancel d 
  inner join (select #reqlist_.nvid from #reqlist_ where isnull(#reqlist_.nvid,0)<>0) r on d.nvid=v.nvid
  
  if @isSet=1
  insert into dbo.DelivCancel(mhID,Marsh,NDMarsh,Datnom,nvID,FCancel,Remark,OP,resID)
  select 0,0,c.nd,v.datnom,v.nvid,@isSet,@remark,@op,@resID
  from dbo.nv v with (nolock, index(nv_datnom_idx)) 
 inner join dbo.nc c on c.datnom=v.datnom
  inner join (select #reqlist_.nvid from #reqlist_ where isnull(#reqlist_.nvid,0)<>0) r on d.nvid=v.nvid
end

if object_id('tempdb..#reqlist_') is not null drop table #reqlist_
END