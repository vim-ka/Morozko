CREATE PROCEDURE dbo.AdditionalKassaList @P_ID int, @OP int
AS
BEGIN
  declare @PersID int

  set @PersID=isnull((select max(p.HRPersID) from morozdata.dbo.person p where p.P_ID=@P_ID and p.closed=0),0)

  if @PersID <> 0 and not exists(select 1 from KassaLock where p_id=@P_ID and comp<>host_name())
  begin
    insert into dbo.KassaLock (op, p_id, persid, comp) 
    values (@OP, @P_ID, @PersID, host_name()); 
  
    if object_id('tempdb..#list') is not null
        drop table #list

    create table #list (PersID int, 
                                            AddID int, 
                        p_id int, 
                        fio varchar(200), 
                        sm money,
                        dt1 datetime,
                        dt2 datetime)
       
    insert into #list  
    select PersID, 
                 max(AdditionalHeaderID) AddID, 
           null, 
           PersFIO, 
           0,
           null,
           null
    from hrmain.dbo.Additional where PersID=@PersID
    group by PersID, PersFIO

    create unique index idx_list on #list(PersID,AddID)

    update #list set p_id=(select top 1 p.p_id from morozdata.dbo.person p where p.hrpersid=#list.persid and p.closed=0)

    update #list set fio='[???]'+fio
    where p_id is null

    update #list set dt1=h.AdditionalHeaderPeriodStart,
                                     dt2=h.AdditionalHeaderPeriodEnd
    from #list l
    inner join hrmain.dbo.AdditionalHeader h on l.addid=h.AdditionalHeaderID

    update #list set sm=sm+(select sum from hrmain.dbo.additional a where a.AdditionalHeaderID=#list.AddID and a.PersID=#list.Persid and a.AdditionalTypeID=998)

    update #list set sm=sm-(select sum from hrmain.dbo.additional a where a.AdditionalHeaderID=#list.AddID and a.PersID=#list.Persid and a.AdditionalTypeID=999)

    select 'Зарплатная ведомость' as Osn,* from #list

    drop table #list
    
  end 
END