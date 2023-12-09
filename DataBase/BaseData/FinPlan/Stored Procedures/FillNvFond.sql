CREATE procedure FinPlan.FillNvFond @StartDay datetime='10.01.2018'
as
declare @TD datetime
begin
  set @TD=dbo.today()
  create table #T(datnom bigint, hitag int, nvid int, price decimal(10,2), BasePrice decimal(10,2), 
    nmid int, fgid int, flgWeight bit, EffWeight decimal(12,3));
 
  insert into #t(datnom, hitag, nvid, price, BasePrice,nmid,fgid, flgWeight)
  SELECT distinct
    nc.datnom, nv.hitag, nv.nvid, nv.price, ns.RezMax as BasePrice, nw.nmid,ns.FgID, 0 as flgWeight
  from 
    NC
    inner join nv on nv.datnom=nc.DatNom
    inner join Def on Def.pin=nc.b_id
    inner join netspec2_who nw on 
      (nw.CodeTip=8 and nw.Code=nc.b_id) -- 7-сеть, 8-клиент
      or (def.master>0 and nw.CodeTip=7 and nw.Code=def.master )
    inner join netspec2_what ns on ns.nmid=nw.nmid 
      and ns.Code=nv.hitag 
      /* and abs(ns.RezMax-nv.Baseprice)<=0.01  */
      and abs(ns.Rez-nv.price)<=0.01
    inner join netspec2_main m on m.nmid=nw.nmid
    inner join finplan.FondGroups FG on FG.FgID=ns.FgID
    inner join Nomen nm on nm.hitag=nv.hitag
    left join tdvi V on nc.nd=@TD and v.id=nv.tekid
    left join Visual V0 on nc.nd<>@TD and v0.id=nv.tekid
  where 
    nc.nd>=@StartDay
    and ns.rez<>ns.rezmax
    and m.Activ=1
    and ns.FgID>0
    and nm.flgWeight=0
    and ((nc.nd=@TD and V.weight=0) or  (nc.nd<>@TD and V0.weight=0))
    and m.StartDate<=nc.nd and m.FinishDate>=nc.nd

  -- select * from #t where datnom=1802062097 and hitag=14862;
  -- select distinct #t.datnom, nc.b_id,nc.fam,nc.sp from #t inner join nc on nc.datnom=#t.datnom order by #t.datnom;

  insert into nvFond(datnom,nvid,NmID,fgid,fpId,P_id,delta,flgWeight)
    select #t.datnom, #t.nvid, #t.nmid, #t.fgid, FP.fpID, FP.p_id, FP.Delta,#t.flgWeight
    from 
      #T
      inner join finplan.FondGroups FG on FG.FgID=#t.fgid
      inner join finplan.FondParts FP on FP.FgID=FG.FgID and FP.Hitag=#t.hitag
      inner join netspec2_main M on M.nmid=FP.NmID
    where 
      #t.datnom not in (select distinct datnom from nvFond)
      and m.Activ=1;

  truncate table #t;

-- НАД ЭТИМ ПОДУМАТЬ:
  insert into #t(datnom, hitag, nvid, price, BasePrice,nmid,fgid, flgWeight,EffWeight)
  select E.datnom, E.hitag, E.NvId, E.Price,  E.RezMax*E.EffWeight BasePrice,E.nmid,E.FGID,14 as flgWeight, E.EffWeight
  from (
    SELECT distinct
      nc.datnom, nv.hitag, nv.nvid, nv.price, ns.rez,ns.RezMax, nw.nmid, ns.FgID,
      case 
        when nc.nd=@TD and v.weight>0 then v.weight
        when nc.nd<>@TD and v0.weight>0 then v0.weight
        when nm.flgWeight=1 and nc.nd=@TD and v.weight=0 and nm.netto<>0 then nm.netto
        when nm.flgWeight=1 and nc.nd<>@TD and v0.weight=0 and nm.netto<>0 then nm.netto
        else 1.00
      end as EffWeight
    from 
      NC
      inner join nv on nv.datnom=nc.DatNom
      inner join Nomen nm on nm.hitag=nv.hitag
      inner join Def on Def.pin=nc.b_id
      left join tdvi V on nc.nd=@TD and v.id=nv.tekid
      left join Visual V0 on nc.nd<>@TD and v0.id=nv.tekid
      inner join netspec2_who nw on 
        (nw.CodeTip=8 and nw.Code=nc.b_id) -- 7-сеть, 8-клиент
        or (def.master>0 and nw.CodeTip=7 and nw.Code=def.master )
      inner join netspec2_what ns on ns.nmid=nw.nmid 
        and ns.Code=nv.hitag 
        and abs(ns.Rez * case 
                          when nc.nd=@TD and v.weight>0 then v.weight
                          when nc.nd<>@TD and v0.weight>0 then v0.weight
                          when nm.flgWeight=1 and nc.nd=@TD and v.weight=0 and nm.netto<>0 then nm.netto
                          when nm.flgWeight=1 and nc.nd<>@TD and v0.weight=0 and nm.netto<>0 then nm.netto
                          else 1.00
                         end - nv.price
               ) <= 0.10
      inner join netspec2_main m on m.nmid=nw.nmid
      inner join finplan.FondGroups FG on FG.FgID=ns.FgID
    where 
      nc.nd>=@StartDay
      and ns.rez<>ns.rezmax
      and m.Activ=1
      and ns.FgID>0
      and not ( nm.flgWeight=0 and ((nc.nd=@TD and V.weight=0) or  (nc.nd<>@TD and V0.weight=0)))
  ) E
  select * from #t;

  insert into nvFond(datnom,nvid,NmID,fgid,fpId,P_id,delta,flgWeight,EffWeight)
    select 
      #t.datnom, #t.nvid, #t.nmid, #t.fgid, FP.fpID, FP.p_id, 
      round(FP.Delta*#T.EffWeight,0) as Delta,
      #t.flgWeight,#T.EffWeight
    from 
      #T
      inner join finplan.FondGroups FG on FG.FgID=#t.fgid
      inner join finplan.FondParts FP on FP.FgID=FG.FgID and FP.Hitag=#t.hitag
      inner join netspec2_main M on M.nmid=FP.NmID
    where 
      #t.datnom not in (select distinct datnom from nvFond)
      and m.Activ=1;

  -- select * from nvFond;
end