CREATE PROCEDURE NearLogistic.GetMarshListForSelect
@reqs varchar(2000),
@nd datetime,
@trans bit =0
with recompile
as 
begin
 if object_id('tempdb..#marshs') is not null drop table #marshs
 
  if object_id('tempdb..#reqlist') is not null drop table #reqlist
  create table #reqlist (id int, type int, act int)
  declare @ttable varchar(50) 
  set @ttable='##'+host_name()+'_reqlist'
  declare @sql varchar(max)
  set @sql=''
  set @sql='if object_id(''tempdb..'+@ttable+''') is not null drop table '+@ttable+' '
  set @sql=@sql+' exec nearlogistic.gettablefromstrings '''+@reqs+''',''id;type;act'','';'',''#'','''+@ttable+''''
  set @sql=@sql+' insert into #reqlist select cast(id as int),cast(type as int),cast(act as int) from '+@ttable+' '
  set @sql=@sql+' drop table '+@ttable+' '
  exec(@sql)
  
  declare @smas decimal(15,2)
  declare @svol decimal(15,2)
  
  alter table #reqlist add reg_id varchar(5),
                pin int
    
  update r set r.reg_id=d.Reg_ID,
         r.pin=iif(c.b_id2=0,c.b_id,c.b_id)
  from #reqlist r
  inner join dbo.nc c on r.id=c.datnom
  inner join dbo.def d on d.pin=iif(c.b_id2=0,c.b_id,c.b_id2)
  where r.type=0
 
  update r set r.reg_id=d.Reg_ID,
         r.pin=d.pin
  from #reqlist r
  inner join dbo.reqreturn rr on rr.reqnum=r.id
  inner join dbo.def d on d.pin=rr.pin
  where r.type=1
  
  update r set r.reg_id=d.Reg_ID,
         r.pin=iif(f.rneedact=3,f.rtpcode2,f.rtpcode)
  from #reqlist r
  inner join dbo.frizrequest f on f.rcmplxid=r.id
  inner join dbo.def d on d.pin=iif(f.rtpcode2=0,f.rtpcode,f.rtpcode2)
  where r.type=2

  update r set r.reg_id=d.Reg_ID,
         r.pin=d.pin
  from #reqlist r
  inner join nearlogistic.moneybackrequest mbr on mbr.mbrID=r.id
  inner join dbo.def d on d.pin=mbr.pin
  where r.type=3
  
  update r set r.reg_id=p.reg_id,
         r.pin=f.pin
  from #reqlist r
  join nearlogistic.MarshRequests_free f on f.mrfID=r.id
  join nearlogistic.marshrequestsdet d on d.mrfid=f.mrfid and d.action_id=6
  join NearLogistic.marshrequests_points p on p.point_id=d.point_id
  where r.type=-2
  
  select @smas=sum(x.Weight),
      @svol=sum(x.Volume)
  from (select r.id,
               r.Type,
               c.sp [cost],
               isnull(sum((n.volminp / n.minp)*v.kol),0) [volume],
               isnull(sum(iif(n.flgweight=0,n.netto,/*iif(c.datnom>=dbo.indatnom(0,getdate()),*/isnull(t.weight,s.weight))*v.kol),0) [weight],
               isnull(sum(ceiling(v.kol/iif(isnull(n.minp,0)=0,1,n.minp))),0) [kolbox]
        from dbo.nc c 
        inner join #reqlist r on r.id=c.datnom
        inner join dbo.nv v on c.datnom=v.datnom
        inner join dbo.nomen n on n.hitag=v.hitag
        left join dbo.tdvi t on t.id=v.tekid
        left join dbo.visual s on s.id=v.tekid 
        where r.type=0
        group by r.ID,c.sp,r.Type
          
        union
          
        select r1.id,
               r1.Type,
               0,
               isnull(sum((n.volminp / n.minp)*d.kol),0),
               isnull(sum(d.fact_weight),0),
               isnull(count(distinct d.hitag),0)
        from dbo.reqreturn r  
        inner join dbo.requests q on q.rk=r.reqnum
        inner join dbo.reqreturndet d on r.reqnum=d.reqretid
        inner join dbo.nomen n on n.hitag=d.hitag
        inner join #reqlist r1 on r1.id=r.reqnum
        where r1.type=1
        group by r1.ID,r1.Type
          
        union
          
        select r.id,
               r.Type,
               0,
               isnull(sum(fm.VolumeBox),0),
               isnull(sum(fm.weight),0),
               isnull(count(distinct f.rcmplxid),0)
        from frizrequest f
        inner join #reqlist r on r.id=f.rcmplxid
        inner join frizrequestinvnom i on i.frizreqid=f.rcmplxid
        inner join frizer z on z.nom=i.frizernom 
        inner join dbo.FrizerModel fm on fm.FMod=z.FMod 
        where r.Type=2
        group by r.ID,r.Type
          
        union
          
        select r.id,
               r.Type,
               mbr.sumpay,
               0.001,
               0.001,
               1
        from nearlogistic.moneybackrequest mbr 
        inner join #reqlist r on r.id=mbr.mbrid
        where r.type=3
        
        union
          
        select r.id,
               r.Type,
               mf.cost,
               mf.weight,
               mf.volume,
               mf.kolbox
        from nearlogistic.MarshRequests_free mf 
        inner join #reqlist r on r.id=mf.mrfID
        where r.type=-1        
        ) x
  select m.mhid,
         cast(m.[marsh] as varchar)+': '+isnull(m.direction,'')+char(13)+char(10)+rs.RegName [direction],
         isnull(v.model,'--')+' '+isnull(v.regnom,'--') [vehname],
         isnull(d.fio,'--')+' '+isnull(d.phone,'--') [drname],
         cast(isnull(v.limitweight,0)-sum(isnull(mr.weight_,0)) as decimal(10,2)) [leftweight],
         cast(isnull(v.volum,0)-sum(isnull(mr.volume_,0)) as decimal(10,2)) [leftvolume],
         m.marsh
  into #marshs
  from dbo.marsh m
  left join dbo.drivers d on d.drid=m.drid
  left join dbo.vehicle v on v.v_id=m.v_id
  left join nearlogistic.marshrequests mr on mr.mhid=m.mhid
  left join NearLogistic.GetRegsString(@nd) rs on rs.mhid=m.mhid
  where datediff(day,m.nd,@nd)=0
     and m.MStatus in (0,1,2)
        and m.SelfShip=0
        and not m.marsh in (0,99)
        and ((m.marsh>=500 and @trans=1)or(@trans=0))
  group by m.mhid,cast(m.[marsh] as varchar)+': '+isnull(m.direction,''),isnull(v.model,'--')+' '+isnull(v.regnom,'--'),
       isnull(d.fio,'--')+' '+isnull(d.phone,'--'),v.volum,v.limitweight,m.marsh,rs.RegName

  select -1 [mhID],
         cast('создать новый маршрут' as varchar(250)) [direction],
         cast('-- --' as varchar(250)) [vehname],
         cast('-- --' as varchar(250)) [drname],
         cast(0.0 as decimal(15,2)) [leftweight],
         cast(0.0 as decimal(15,2)) [leftvolume],
         0 [ord],
         0 [type],
         cast(0 as bit) [isHeader]
  into #res
  
  if exists(select 1 
       from NearLogistic.MarshRequests mr
            join #marshs m on m.mhid=mr.mhID
            where mr.pinto in (select r.pin from #reqlist r))
  begin
    insert into #res
    select -1,'Рейсы с выделенными клиентами',cast('-- --' as varchar(250)),cast('-- --' as varchar(250)),0,0,0,1,cast(1 as bit)
    union 
    select mhid,left(direction,250),[vehname],[drname],[leftweight],[leftvolume],[marsh],1,cast(0 as bit)
    from #marshs m
    where m.mhid in (select m.mhid 
                     from NearLogistic.MarshRequests mr
                 inner join #marshs m on m.mhid=mr.mhID
                 where mr.pinto in (select r.pin from #reqlist r))
  end
    
  if exists(select 1 
       from NearLogistic.MarshRequests mr
            inner join #marshs m on m.mhid=mr.mhID
            inner join dbo.def d on d.pin=iif(mr.PINFrom=0,mr.pinto,mr.PINFrom)
            where d.Reg_ID in (select r.reg_id from #reqlist r))
  begin
    insert into #res
    select -1,'Рейсы с выделенными регионами',cast('-- --' as varchar(250)),cast('-- --' as varchar(250)),0,0,0,2,cast(1 as bit)
    union 
    select mhid,left(direction,250),[vehname],[drname],[leftweight],[leftvolume],[marsh],2,cast(0 as bit)
    from #marshs m
    where m.mhid in (select m.mhid 
                     from NearLogistic.MarshRequests mr
                     inner join #marshs m on m.mhid=mr.mhID
                     inner join dbo.def d on d.pin=iif(mr.PINFrom=0,mr.pinto,mr.PINFrom)
                     where d.Reg_ID in (select r.reg_id from #reqlist r))
  end
  
  if exists(select 1 
       from #marshs m 
            where m.[leftweight]-@smas>0 
               and m.[leftvolume]-@svol>0
                  and not exists(select 1 from #res r where r.mhid=m.mhid))
  begin
    insert into #res
    select -1,'Подходящие рейсы',cast('-- --' as varchar(250)),cast('-- --' as varchar(250)),0,0,0,3,cast(1 as bit)
    union 
    select mhid,left(direction,250),[vehname],[drname],[leftweight],[leftvolume],[marsh],3,cast(0 as bit)
    from #marshs m
    where m.mhid in (select m.mhid 
                     from #marshs m 
                 where m.[leftweight]-@smas>0 
                  and m.[leftvolume]-@svol>0
                    and not exists(select 1 from #res r where r.mhid=m.mhid))
  end 
  
  if exists(select 1 
       from #marshs m 
            where not exists(select 1 from #res r where r.mhid=m.mhid))
  begin
    insert into #res
    select -1,cast('Остальные рейсы' as varchar(250)),cast('-- --' as varchar(250)),cast('-- --' as varchar(250)),0,0,0,4,cast(1 as bit)
    union 
    select mhid,left(direction,250),[vehname],[drname],[leftweight],[leftvolume],[marsh],4,cast(0 as bit)
    from #marshs m
    where m.mhid in (select m.mhid from #marshs m where not exists(select 1 from #res r where r.mhid=m.mhid))  
  end 
  
  select * from #res order by [type],[isHeader] desc,[ord]

drop table #reqlist
drop table #marshs
drop table #res
end