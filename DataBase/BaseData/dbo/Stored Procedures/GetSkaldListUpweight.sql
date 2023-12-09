CREATE PROCEDURE dbo.GetSkaldListUpweight
@selected varchar(200)
AS
BEGIN
	create table #UpSkald (s int)  
  if @selected=''  
  	set @selected='-1'
  declare @sql varchar(max)
  set @sql=''
  set @sql='insert into #UpSkald select '+replace(@selected,',','union select ')	
  exec(@sql)
  
  select cast(iif(exists(select 1 from #UpSkald where s=SkladNo),1,0) as bit) [x],
  			 SkladNo,
         SkladName
  from SkladList
  where UpWeight=1
  			--and AgInvis=0
END