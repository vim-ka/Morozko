CREATE PROCEDURE NearLogistic.DestroyMarshruts
@mhid int,
@op int
AS
BEGIN
  declare @ids varchar(5000)
  declare @mes varchar(1000)
  set @mes=''
  select @ids=stuff((
        select N'#'+cast(mr.ReqID as varchar)+';'+cast(mr.ReqType as varchar)+';'+cast(mr.ReqAction as varchar)
              from NearLogistic.MarshRequests mr
              where mr.mhid=@mhid
              for xml path(''), type).value('.','varchar(max)'),1,0,'')
  
  exec NearLogistic.MarshRequetOperations @ids, 0, @op, 1, @mes
  if @mes=''
   delete from [dbo].marsh where mhid=@mhid
END