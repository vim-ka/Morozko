CREATE PROCEDURE MobAgents.MobGetNakl @ag_id int
AS
BEGIN
  declare @NDY datetime
  set @NDY = dateadd(day, -1,  dbo.today())
  --set transaction isolation level read uncommitted
  create table #NeedDCK (dck int)
  
  insert into #NeedDCK (dck)
  select c.dck from defcontract c where c.ag_id=@ag_id or c.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0)
  union
  select b.add_dck from agaddbases b where b.ag_id=@ag_id and b.add_dck<>0


  /* if @ag_id = 243 
  insert into #NeedDCK (dck)
  select c.dck from defcontract c join dailysaldodck d on c.dck=d.dck and d.ND=@NDY
                                  join def f on c.pin=f.pin
  where d.Debt>0 and f.obl_id=1 and c.our_id<>23
*/


  select n.* into #ncTemp from nc n
  where n.dck in (select dck from #NeedDCK) 
        and (n.sp-n.fact+n.izmen>=0)-- and n.refdatnom=0) or (n.sp>0 and n.refdatnom>0))
        and n.tara=0 and n.frizer=0 and n.actn=0 
  

  
/*  select n.dck as pin,
         n.Ourid as Our_id,
         '{'+convert(char(10),n.nd,104)+'}№'+cast(dbo.InNnak(n.datnom) as char(4)) as Nakl,--  case when n.sp>0 then 'РН '+cast(dbo.InNnak(datnom) as varchar) else 'ВозвНак '+cast(dbo.InNnak(datnom) as varchar) end as Rem,
         n.sp-n.fact+n.izmen+isnull(b.sp,0) as Debet
  from #ncTemp n left join (select nd.refdatnom, sum(nd.sp-nd.fact+nd.izmen) as sp
                          from #ncTemp nd where nd.refdatnom>0 and nd.sp-nd.fact+nd.izmen>0.01  
                          group by nd.refdatnom) b on b.refdatnom=n.datnom
  where --n.dck in (select dck from #NeedDCK) 
        --and n.tara=0 and n.frizer=0 and n.actn=0
        ((n.sp-n.fact+n.izmen>0.00) or (isnull(b.sp,0)<>0)) 
        and n.refdatnom=0
  order by n.dck, n.Ourid, nakl                 
  
 */ 
 
 
  select n.dck as pin,
         n.Ourid as Our_id,
         case when n.refdatnom>0 then 
         '{'+convert(char(10),n.nd,104)+'}Добивка №'
         +cast(dbo.InNnak(n.datnom) as char(4))+' от '+convert(varchar(10),dbo.DatnomInDate(n.datnom),104)
         +' к №'
         +cast(dbo.InNnak(n.refdatnom) as char(4))+' от '+convert(varchar(10),dbo.DatnomInDate(n.refdatnom),104)
         else 
         '{'+convert(char(10),n.nd,104)+'}№'+cast(dbo.InNnak(n.datnom) as char(4)) end as Nakl,
         n.sp-n.fact+n.izmen as Debet
  from #ncTemp n 
  where (n.sp-n.fact+n.izmen>0.00) 
  
  order by n.dck, n.Ourid, nakl                 

END