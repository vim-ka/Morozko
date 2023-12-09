CREATE PROCEDURE NearLogistic.CheckMarshBeforePrint_
@mhID int
AS
BEGIN
  declare @res bit 
  declare @msg varchar(max)
  set @res=cast(0 as bit)
  set @msg=''
  --не прошла
  if exists(select 1 from dbo.nc c join nearlogistic.marshrequests mr on mr.reqid=c.datnom and mr.reqtype=0 where c.done=0 and c.delivcancel=0 and mr.mhid=@mhid)
  begin
   set @msg=@msg+
         isnull(
           stuff((select N''+'№'+cast(c.datnom % 10000 as varchar)+' '+isnull(c.Fam,'<..>')+' - не готова;'+char(13)+char(10)
        from dbo.nc c 
             join nearlogistic.marshrequests mr on mr.reqid=c.datnom and mr.reqtype=0
             where mr.mhid=@mhid
                 and c.done=0
                   and c.DelivCancel=0
             for xml path(''), type).value('.','varchar(max)'),1,0,''),
             '<..>')     
    
    set @res=cast(1 as bit)
  end
  
  --не набрана
  /*
  if exists(select 1 from dbo.nc c join dbo.nvzakaz z on c.datnom=z.datnom join nearlogistic.marshrequests mr on mr.reqid=c.datnom and mr.reqtype=0 where mr.mhid=@mhid and z.done=0 and c.delivcancel=0)
  begin
   set @msg=@msg+
         isnull(
           stuff((select N''+'№'+cast(c.datnom % 10000 as varchar)+' '+isnull(c.Fam,'<..>')+' - не набрана;'+char(13)+char(10)
        from dbo.nc c
             join nearlogistic.marshrequests mr on mr.reqid=c.datnom and mr.reqtype=0              
             join dbo.nvzakaz z on c.datnom=z.datnom
             where mr.mhid=@mhid
                 and c.delivcancel=0
                   and z.done=0
             group by c.datnom,c.Fam
             for xml path(''), type).value('.','varchar(max)'),1,0,''),
             '<..>')     
    
    set @res=cast(1 as bit)
  end
  */
  
  --водитель<->машина
  if exists(select 1 from dbo.marsh m join dbo.vehicle v on v.v_id=m.v_id join dbo.drivers d on d.drid=m.drid where m.mhid=@mhid and v.crid<>d.crid and d.crid<>7)
  begin
   set @msg=@msg+'Водитель не на той машине'
    set @res=cast(1 as bit)
  end
  
  select @res [res], @msg [msg]
END