CREATE PROCEDURE ArrivalBuh.CheckCommanToRollback
@ncom int
AS
BEGIN
declare @res bit
declare @msg varchar(50)
declare @kolErr int
set @kolErr=0
set @res=0
set @msg=''

if exists(select 1 from nv where tekid in (select id from tdvi where ncom=@ncom)) set @kolErr=@kolErr+1

if @kolErr & 1 <> 0
	set @msg=@msg+'Существуют продажи товара в выделенной комиссии'

set @res=iif(@kolErr<>0,cast(1 as bit),cast(0 as bit))
  
select @res [res],@msg [msg]
END