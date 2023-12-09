create procedure SaveKsInfoGroup @StartKassId int, @Op int
as
declare @Ncod int
declare @Ncod0 int
declare @Remark varchar(60)
declare @Remark0 varchar(60)
declare @Tm char(8)
declare @Tm0 char(8)
declare @Ok bit
declare @Total decimal(10,2)
declare @Plata decimal(10,2)
declare @DepId int
declare @DepId0 int
declare @Oper int
declare @Oper0 int
declare @RashFlag int

BEGIN
  declare C1 cursor fast_forward for 
    select Ncod, Tm, Plata, Remark, DepID, Oper, RashFlag
    from Kassa1 k 
    where kassid>=@StartKassId
    order by kassid
  
  set @Ok=1
  set @Total=0.00

  open C1
  
  fetch next from C1 into @Ncod0, @Tm0, @Plata, @Remark0, @DepId0, @Oper0, @RashFlag
  
  WHILE (@@FETCH_STATUS=0) and (@Ok=1) BEGIN
    set @Total=@Total+@Plata;    
    fetch next from C1 into @Ncod, @Tm, @Plata, @Remark, @DepId, @Oper, @RashFlag;

    if (@Ncod<>@Ncod0) or (@Tm<>@Tm0) or (@Remark<>@Remark0) 
    or (@DepID<>@DepId0) or (@Oper<>@Oper0)
    set @Ok=0;
  end;
  close C1
  deallocate C1
  
  insert into KsInfo(DepIdCust, DepIdExec, Op,Plata,KsOper,Nal,RashFlag,KassID)
  values(@DepID0, 7, @OP, @Total, @Oper0, 1, @RashFlag, @StartKassId)

  select @Total   
  
end