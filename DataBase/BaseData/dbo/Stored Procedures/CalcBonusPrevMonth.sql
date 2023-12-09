CREATE procedure CalcBonusPrevMonth @nd datetime, @nd1 datetime
as
begin

  if exists(select * from sys.objects 
    where object_id = object_id('BonusPrevMonth') and type = ('u'))
    truncate table BonusPrevMonth;
  else create table BonusPrevMonth (sv_id int);    

  create table #t0 (sv_id int, datnom int, Closed bit default 0)

  insert into #t0(sv_id, datnom)
    select 
      a.sv_id, nc.datnom
    from 
      nc inner join def on def.pin=nc.b_id and def.tip=1
      inner join Agents A on A.ag_id=Def.brag_id
      left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND and k.oper=-2 and k.Act in ('ВЫ','ВО')
      left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND group by i.datnom) Z on Z.datnom=nc.datnom
    where nc.Actn=0 and nc.Frizer=0 and nc.SP>0 and NC.Tara=0
    group by a.sv_id, nc.datnom, nc.nd,nc.sp, nc.srok, z.nziz
    having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)>=5 and cast( @ND - (nc.nd+nc.srok) as int)>=30
    order by a.sv_id, nc.datnom


  create table #t1 (datnom int)

  insert into #t1(datnom)
    select 
      nc.datnom
    from 
      nc inner join #t0 on #t0.datnom=nc.datnom
      left join Kassa1 k on k.sourdatnom=nc.datnom and k.nd<=@ND1 and k.oper=-2 and k.Act in ('ВЫ','ВО')
      left join (select i.datnom, sum(i.izmen) as NzIz from NcIzmen i where i.nd<=@ND1 group by i.datnom) Z on Z.datnom=nc.datnom
    where nc.Actn=0 and nc.Frizer=0 and nc.SP>0 and NC.Tara=0
    group by nc.datnom, nc.nd,nc.sp, nc.srok, z.nziz
    having nc.sp-sum(isnull(k.plata,0))+ISNULL(Z.NzIz,0)<5
    order by nc.datnom

  update #t0 set Closed=1 where datnom in (select datnom from #t1);
  
  insert into BonusPrevMonth(sv_id)  
  select sv_id from (
    select sv_id-- , count(*), sum(case when closed=1 then 1 else 0 end) 
    from #t0 
    group by sv_id 
    having count(*)=sum(case when closed=1 then 1 else 0 end)
  ) F;
  
  select * from BonusPrevMonth;
end