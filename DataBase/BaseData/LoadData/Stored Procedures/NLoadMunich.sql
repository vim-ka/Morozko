CREATE PROCEDURE [LoadData].NLoadMunich @Type smallint, @StartND datetime, @EndND datetime, @Ncod varchar(50)
AS
BEGIN
  declare @d_id as varchar(20)
   if @Ncod=1674 set @d_id='ВП00000137'

  if @type = 1
  begin
      select 
            @d_id as d_id,
            --iif(isnull(c.stfnom,'')='',cast(dbo.InNNak(c.datnom) as varchar), c.stfnom) as doc_num,
            cast(c.datnom as varchar) as doc_num,
            d.gpName as p_name,
            d.pin as p_id,
            d.gpAddr as p_adr,
            d.gpInn as p_inn, 
            d.gpKpp as p_kpp,
            iif(n.fname is null, n.name, n.fname) as sku_name,
            v.hitag as sku_id,
            n.barcode as sku_barcode,
            iif(c.stfdate is null or c.stfdate<='20100101', c.nd, c.stfdate) as date,
            v.kol as amount,
            v.price*v.kol as sum,
            pa.fio as sale_agent,  
            ps.fio as supervisor,  
            e.dname as unit,
            fmt.dfName as p_format,
            iif(c.mhid>0, 'доставка', 'самовывоз' ) as sh_type, 
            iif(c.srok=0, 'отсрочка', 'факт') as pay_type,
            '' as action
          
            
    from nc c join nv v on c.datnom=v.datnom        
              join visual i on v.tekid=i.id
              join def d on c.b_id=d.pin
              join nomen n on n.hitag=v.hitag
              join agentlist a on c.ag_id=a.ag_id
              join person pa on a.p_id=pa.p_id
              join agentlist s on a.sv_ag_id=s.ag_id
              join person ps on s.p_id=ps.p_id
              join deps e on a.DepID=e.DepID
              join defformat fmt on d.dfID=fmt.dfID
    where c.ND>=@StartND and c.ND<=@EndND and i.Ncod in (select K from dbo.Str2intarray(@Ncod))         
          and c.stip<>4 and v.kol<>0
    order by p_name      
  end
  else
          
  if @type = 2
  begin

   
    
    select @d_id as d_id,
            f.brName as shipper,
            c.ncom as doc_num,
            iif(n.fname is null, n.name, n.fname) as sku_name,
            i.hitag as sku_id,
            n.barcode as sku_barcode,
            c.[date] as date,
            i.kol as amount,
            i.cost*i.kol as sum
    from comman c join inpdet i on c.ncom=i.ncom
                  join nomen n on n.hitag=i.hitag
                  join DefContract d on c.dck=d.dck
                  join def f on c.pin=f.pin
    where c.[Date]>=@StartND and c.[Date]<=@EndND and c.Ncod in (select K from dbo.Str2intarray(@Ncod))
          and d.ContrTip=1 and i.hitag not in (95007,90858)
    
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