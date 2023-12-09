CREATE PROCEDURE users.GetPermsToCopy
@donor int,
@uin int
AS
BEGIN
  select prg,prg [lvl],pid,PermisName
  into #res
  from Permissions

  insert into #res
  select prg,0,0,PrgName
  from Programs 
  where prg>0

  alter table #res add donorHas bit not null default 0
  alter table #res add recipientHas bit not null default 0

  update #res set donorhas=case when exists(select 1 
                                            from dbo.permisscurrent pc 
                                            where pc.uin=@donor 
                                                  and pc.prg=#res.prg 
                                                  and pc.permiss & #res.pid<>0)
                           then cast(1 as bit) else cast(0 as bit) end 

  update #res set recipienthas=case when exists(select 1 
                                                from dbo.permisscurrent pc 
                                                where pc.uin=@uin 
                                                      and pc.prg=#res.prg 
                                                      and pc.permiss & #res.pid<>0)
                           then cast(1 as bit) else cast(0 as bit) end
                           
  delete from #res 
  where lvl<>0
        and donorhas=0
        or recipienthas=1
        
  delete from #res where prg in (select prg from #res group by prg having count(prg)<2)

  select prg,lvl,pid,PermisName,cast(0 as bit) [x] from #res
  order by prg,lvl,pid

  drop table #res
END