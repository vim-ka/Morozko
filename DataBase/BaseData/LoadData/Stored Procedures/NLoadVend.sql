CREATE PROCEDURE [LoadData].[NLoadVend] @Type smallint, @StartND datetime, @EndND datetime, @Ncod varchar(50)
AS
BEGIN
  declare @d_id as varchar(20)
  declare @DistrName as varchar(30)
  
  if @Ncod=1674
  begin
    set @d_id='"ВП00000137"'
    set @DistrName='"Морозко"'
  end 
  else
  if @Ncod=1740 and @Type=2
  begin
    set @StartND='20170606'
    set @EndND=dbo.today();
    set @DistrName='Морозко'
  end 
  else
  begin
    set @d_id='ВП00000137'
    set @DistrName='Морозко'
  end 
  

  if @type = 1  --Отгрузки
  begin
  
     select 
            @DistrName as DistrName,  
            left((convert(varchar, getdate(),126)),19) as NDgenerate,
            convert(varchar, @StartND,104)+' 00:00:00' as StartND,
            convert(varchar, @EndND,104)+' 23:59:59' as EndND,
            '1' as TypeUnload,
            convert(varchar,c.nd,104)+' '+c.tm as DtDoc,
            @d_id as BranchCode,
            c.b_id as ClientCode,
            cast(dc.srok as varchar) as Srok, 
            iif(isnull(c.stfnom,'')='',cast(dbo.InNNak(c.datnom) as varchar), c.stfnom) as DocNumber,
            convert(varchar,c.nd,104)+' '+c.tm as DocDate,
            ne.exttag as ExtTag,
            iif(n.fname is null, n.name, n.fname) as SkuName,
            iif(n.flgWeight=1, 'кг','шт') as EdIzm,
            cast(iif(n.flgWeight=1, i.weight, n.netto) as varchar) as Massa1SKU,
            cast(iif(n.flgWeight=1, i.weight, n.netto)*v.kol as varchar) as Massa,
            iif(n.flgWeight=1, i.weight, n.netto)*v.kol as MassaFl,
            cast(v.kol as varchar) as Qty,
            cast(v.kol*v.price*(1+c.extra/100)*100/(100+n.nds) as varchar) as Sm,          
            v.kol*v.price*(1+c.extra/100)*100/(100+n.nds) as SmFl,          
            cast((1+c.extra/100)*v.price*v.kol*n.nds/(100+n.nds) as varchar) as NDS,
            v.hitag,
            d.gpName as ClientName,
            isnull(pa.fio,'') as FTDFIOTP
    from nc c join nv v on c.datnom=v.datnom        
              join defcontract dc on c.dck=dc.dck 
              join visual i on v.tekid=i.id
              join def d on c.b_id=d.pin
              join defformat fmt on d.dfID=fmt.dfID
              join nomen n on n.hitag=v.hitag
              left join nomenvend ne on n.hitag=ne.hitag and i.dck=ne.dck
              left join agentlist a on  [LoadData].GetAddAg_ID(c.ag_id,c.dck) = a.ag_id-- c.ag_id=a.ag_id
              left join person pa on a.p_id=pa.p_id
              left join agentlist s on a.sv_ag_id=s.ag_id
              left join person ps on s.p_id=ps.p_id
              left join deps e on a.DepID=e.DepID
    where c.ND>=@StartND and c.ND<=@EndND and i.Ncod in (select K from dbo.Str2intarray(@Ncod))         
          and c.stip<>4 and v.kol<>0 
  end
  else
          
  if @type = 2 --Клиенты
  begin
 
    
    select 
            distinct 
            @DistrName as DistrName,  
            left((convert(varchar, getdate(),126)),19) as NDgenerate,
            convert(varchar, @StartND,104)+' 00:00:00' as StartND,
            convert(varchar, @EndND,104)+' 23:59:59' as EndND,
            cast(c.b_id as varchar) as ClientCode,
            cast(c.b_id as varchar) as PayerCode,
            cast(d.brInn as varchar) as INN, 
            cast(isnull(d.brKpp,'') as varchar) as KPP, 
            cast(replace(d.gpName,'"','quot')  as varchar) as gpName, 
            d.gpAddr as gpAddr,
            '' as FTDRegion,
            isnull(pa.fio,'') as FTDFIOTP,
            '' as FTDFormShip,
            '' as FTDSposobShip,
            '' as FTDNetType,
            '' as FTDFormat,
            isnull(fmt.dfName,'') as FTDChannel
            
            
    from nc c join nv v on c.datnom=v.datnom        
              join defcontract dc on c.dck=dc.dck 
              join visual i on v.tekid=i.id
              join def d on c.b_id=d.pin
              join nomen n on n.hitag=v.hitag
              left join nomenvend ne on n.hitag=ne.hitag and i.dck=ne.dck
              left join agentlist a on [LoadData].GetAddAg_ID(c.ag_id,c.dck) = a.ag_id
              left join person pa on a.p_id=pa.p_id
              left join agentlist s on a.sv_ag_id=s.ag_id
              left join person ps on s.p_id=ps.p_id
              left join deps e on a.DepID=e.DepID
              left join defformat fmt on d.dfID=fmt.dfID
    where c.ND>=@StartND and c.ND<=@EndND and i.Ncod in (select K from dbo.Str2intarray(@Ncod))         
          and c.stip<>4 and v.kol<>0
    
  end
  else
  if @type = 3
  begin

     select t.id,
            t.EveningRest as MornRest,
            t.EveningRest*t.cost as Stoim,
            t.sklad,
            t.Hitag,
            t.dck
            into #EndOstat
     from   MorozArc.dbo.ArcVI t 
     where t.WorkDate=@EndND and t.Ncod in (select K from dbo.Str2intarray(@Ncod)) and
           t.hitag not in (95007,90858) and t.EveningRest<>0
           
      
      select @d_id as d_id,
            iif(n.fname is null, n.name, n.fname) as sku_name,
            n.hitag as sku_id,
            n.barcode as sku_barcode, 
            @EndND+1 as date,
            sum(e.MornRest) as amount,
            sum(e.Stoim) as sum
      from  #EndOstat e join nomen n on n.hitag=e.hitag
                        join visual v on v.id=e.id
                        join defcontract d on d.dck=e.dck
      where d.Contrtip=1 
            
            
      group by iif(n.fname is null, n.name, n.fname),
               n.hitag,
               n.barcode 
      having sum(e.MornRest)<>0              
               
     drop table #EndOstat
   
  end
  
END