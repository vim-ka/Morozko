-- проверка остатков на складах для ценовых спецификаций заданного отдела, 3=Сетевой по умолчанию:
CREATE procedure dbo.NetspecRestCheck @DepID int=3
as
declare @Hitag int,@PrevHitag int, @nmid int,  @SS varchar(500)
begin
  create table #s(Nmid int);
  
  insert into #s(nmid)
  select distinct nmid from (
  select
    ns.nmid, ns.code, ns.CodeTip,ns.htid,
    case when ns.CodeTip=0 then 'Все'
    when ns.CodeTip=1 then obl.OblName
    when ns.CodeTip=2 then rn.RName
    when ns.CodeTip=3 then deps.DName
    when ns.CodeTip=4 then df.Fullname
    when ns.CodeTip=5 then ps.Fio
    when ns.CodeTip=6 then pa.Fio
    when ns.CodeTip>=7 then Def.BrName
    end as Name,
    isnull(CT.TipName,'любой') as TipName
  from
    netspec2_who ns
    inner join netspec2_main MA on MA.nmid=ns.nmid
    left join obl on obl_id=ns.Code and ns.CodeTip=1
    left join raions rn on rn.Rn_id=ns.Code and ns.CodeTip=2
    left join deps on deps.DepID=ns.Code and ns.CodeTip=3
    left join DefFormatWide df on df.dfid=ns.code and ns.codetip=4
    left join Agentlist SV on SV.AG_ID=ns.Code and ns.CodeTip=5 
      left join Person PS on PS.P_ID=sv.P_ID
    left join Agentlist A on A.AG_ID=ns.Code and ns.CodeTip=6
    left join Person PA on PA.P_ID=A.P_ID
    left join Def on def.pin=ns.Code and ns.CodeTip>=7 and def.tip=1
    left join DefContractTip CT on CT.ContrTip=ns.ContrTip
  where 
    MA.Activ=1
    and ns.nmid>0
    and ns.CodeTip>=4
   ) E 
   where e.code in (
    select distinct pin from DefContract DC inner join Agentlist A on A.ag_id=dc.ag_id 
    where dc.Actual=1 and dc.ContrTip=2 and A.DepID=@DepID);

  

  create table #rest(hitag int, flgWeight bit, Qty decimal(10,3))
  insert into #rest(hitag, flgWeight, qty)
    select 
      v.hitag, 
      nm.flgWeight,
      sum((v.morn-v.sell+v.isprav-v.REMOV)*
        case when nm.flgWeight=0 then 1
        when nm.flgWeight=1 and v.weight>0 then v.WEIGHT
        else nm.netto 
        end) as Rest
    from 
      tdvi v
      inner join nomen nm on nm.hitag=v.hitag
      inner join skladlist S on S.skladno=v.SKLAD
      inner join SkladGroups G on G.skg=S.skg 
    where  G.Plid=1
    group by v.hitag,nm.flgWeight;
  create index rest_tmp_idx on #rest(hitag);

  -- select top 10 * from #rest order by qty desc;

  create table #g(hitag int, SList varchar(500));
  declare C1 cursor FAST_FORWARD for 
    select 
      ns.code as Hitag, #s.nmid
    from 
      #s
      inner join netspec2_what ns on ns.nmid=#s.nmid
    WHERE
      ns.codetip=30
    order by ns.code, #s.nmid;
  open C1;
  FETCH from C1 into @hitag, @nmid;
  while @@fetch_status=0 BEGIN
    set @PrevHitag=@Hitag;
    set @ss='';
    while @@fetch_status=0 and @PrevHitag=@Hitag BEGIN
      if @ss='' set @ss=cast(@nmid as varchar) else set @ss=@ss+','+cast(@nmid as varchar);
      FETCH from C1 into @hitag, @nmid;  
    end;
    insert into #g(hitag, slist) values(@PrevHitag, @SS)
  end;
  close c1;
  deallocate c1;
  create index gg_tmp_idx on #G(hitag);
  

  create table #FN(hitag int, Ngrp int, FullGroup varchar(500));
  
  insert into  #FN(hitag) 
  select distinct E.Hitag
    from (
      select 
        #s.nmid, 
        ns.code as Hitag
      from 
        #s
        inner join netspec2_what ns on ns.nmid=#s.nmid
      WHERE ns.codetip=30 ) E 
    inner join #g on #g.hitag=E.Hitag;

  update #FN set Ngrp=nm.Ngrp from #FN inner join Nomen nm on nm.hitag=#fn.hitag;
  update #fn set FullGroup=gr.grpname, Ngrp=gr.parent from #fn inner join gr on gr.ngrp=#fn.ngrp;
  update #fn set FullGroup=gr.grpname+'/'+FullGroup, Ngrp=gr.parent from #fn inner join gr on gr.ngrp=#fn.ngrp where #fn.ngrp>0;
  update #fn set FullGroup=gr.grpname+'/'+FullGroup, Ngrp=gr.parent from #fn inner join gr on gr.ngrp=#fn.ngrp where #fn.ngrp>0;
  update #fn set FullGroup=gr.grpname+'/'+FullGroup, Ngrp=gr.parent from #fn inner join gr on gr.ngrp=#fn.ngrp where #fn.ngrp>0;
  update #fn set FullGroup=gr.grpname+'/'+FullGroup, Ngrp=gr.parent from #fn inner join gr on gr.ngrp=#fn.ngrp where #fn.ngrp>0;
  update #FN set Ngrp=nm.Ngrp from #FN inner join Nomen nm on nm.hitag=#fn.hitag;

  -- select * from #fn;


  select distinct
    gr.ngrp, #FN.FullGroup, E.hitag, NM.Name, nm.flgWeight, #rest.qty, #G.slist
  from (
    select 
      #s.nmid, 
      ns.code as Hitag
    from 
      #s
      inner join netspec2_what ns on ns.nmid=#s.nmid
    WHERE ns.codetip=30 ) E 
  left join #rest on #rest.hitag=e.Hitag
  inner join #g on #g.hitag=E.Hitag
  inner join Nomen nm on nm.hitag=e.Hitag
  inner join Gr on Gr.ngrp=nm.Ngrp
  left join #FN on #FN.hitag=E.Hitag
  order by #FN.FullGroup, nm.name;

end;