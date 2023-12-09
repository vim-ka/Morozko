
create procedure PodborVl @day0 datetime, @day1 datetime
as 
declare @Cnt int;
declare @Mhid int;
declare @V_ID int;
declare @ND datetime;
declare @Driver varchar(80);
begin
  IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[#UPDMAR]') )
    DROP TABLE [dbo].[#UPDMAR];
  create table #UPDMAR (mhid int, v_id int);
  
  declare CurEmp cursor fast_forward
    for select Mhid, Driver, ND from Marsh
    where nd between @day0 and @day1 and v_id=0 and Driver<>''
    order by mhid;
--  set @Cnt=20;
  
  open CurEmp;
  fetch next from CurEmp into @Mhid, @Driver, @ND;
  WHILE ((@@FETCH_STATUS=0)  /*and (@Cnt>0)*/)  BEGIN
    set @V_ID=(select max(v_id) from Marsh where Driver=@Driver and ND<=@ND /* and V_ID>0 order by ND desc, Mhid desc*/);  
    if  (@V_ID is not null)and(@V_ID>0) -- insert into #Updmar(mhid,v_id) values(@mhid,@v_id)
    update Marsh set V_ID=@V_ID where Mhid=@Mhid;
--    set @Cnt=@Cnt-1;
    fetch next from CurEmp into @Mhid, @Driver, @ND;
  end;
  close CurEmp;
  deallocate CurEmp;
end;