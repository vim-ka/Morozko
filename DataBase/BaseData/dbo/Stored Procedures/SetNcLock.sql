CREATE procedure dbo.SetNcLock @HostName varchar(30), @Datnom bigint
as
begin
  delete from NcLock where HostName=@HostName;
  
  if not exists(select * from NcLock where Datnom=@Datnom)
  insert into NcLock(HostName,Datnom)
  values(@HostName, @Datnom);
     
  select * from NcLock where Datnom=@Datnom and HostName<>@HostName;

END