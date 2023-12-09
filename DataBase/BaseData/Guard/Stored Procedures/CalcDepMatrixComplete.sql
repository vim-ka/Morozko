CREATE procedure Guard.CalcDepMatrixComplete @ND datetime
as
declare @Comp varchar(30), @SV_ID int, @AG_ID int,  @Mode smallint, @B_ID int, @MLID int, @Cnt int;
begin
  set @Comp=Host_name();

  if OBJECT_ID('tempdb..#t') is not null drop table #t;
  create table #t (sv_id int, ag_id int, b_id int, ngrp int, GrpName varchar(100), hitag int, Name varchar(100),
    flgWeight bit, MinQty int, FactRest decimal(10,3), SkladRest decimal(10,3),
    BoxSkladRest decimal(10,3), BoxMinP int, Sell decimal(10,3) default 0, Req decimal(10,3));

  -- Список продаж
  if OBJECT_ID('tempdb..#s') is not null drop table #s;
  create table #s(hitag int, Sell decimal(10,3));

  declare c2 cursor FAST_FORWARD for
    select distinct sv_id,ag_id,pin,mlid
    from guard.DepMatrixComplete
    where MLiD>0 and Comp=@Comp;
  open c2;
  fetch next from c2 into @sv_id,@ag_id,@B_ID,@MLID;
  set @Cnt=10000 -- ДЛЯ ОТЛАДКИ! Надо 10000

  while @@fetch_status=0 and @Cnt>0 BEGIN

    truncate table #t;
    truncate table #s;

    insert into #t(sv_id,ag_id,b_id,ngrp, grpname, hitag, [name], flgWeight, MinQty, FactRest)
    select 
      @sv_id, @ag_id, @b_id,
      n.ngrp,  gr.grpname, n.hitag, n.name, n.flgWeight,
      isnull(L.MinQty,0) MinQty,
      isnull(sum(r.qty),0) as FactRest
    from
      guard.MatrixLDet L
      inner join  nomen n on n.Hitag=L.Hitag
      inner join GR on GR.Ngrp=N.Ngrp
      left join Rests R on R.hitag=n.hitag and R.NeedDay = @nd and R.ag_id = @ag_id
         and r.DCK in (select dck from defcontract where pin = @B_ID)
    where L.MLID = @MLID
    group by n.ngrp,  gr.grpname, n.hitag, n.name, n.flgWeight, isnull(L.MinQty,0)
    order by n.ngrp, n.name;

    update #t set #t.SkladRest=(select sum((v.morn-v.sell+v.ISPRAV-v.REMOV-v.BAD-v.REZERV)*iif(v.weight=0,1,v.WEIGHT))
      from
        tdvi v
        inner join SkladList sl on sl.SkladNo=v.SKLAD
        inner join SkladGroups sg on sg.skg=sl.skg
      where
        v.hitag=#t.hitag
        and v.OnlyMinP=0
        and v.LOCKED=0
        and sl.Locked=0 and sl.AgInvis=0 and sl.SafeCust=0 and sl.Discard=0 and sl.SkladOperLock=0 and sl.Equipment=0
        and sg.PLID=1 and sg.Our_ID=7
        );
    
    update #t set #t.BoxSkladRest=(select sum((v.morn-v.sell+v.ISPRAV-v.REMOV-v.BAD-v.REZERV)*iif(v.weight=0,1,v.WEIGHT))
      from
        tdvi v
        inner join SkladList sl on sl.SkladNo=v.SKLAD
        inner join SkladGroups sg on sg.skg=sl.skg
      where
        v.hitag=#t.hitag
        and v.OnlyMinP=1
        and v.LOCKED=0
        and sl.Locked=0 and sl.AgInvis=0 and sl.SafeCust=0 and sl.Discard=0 and sl.SkladOperLock=0 and sl.Equipment=0
        and sg.PLID=1 and sg.Our_ID=7
        );

    update #t set #t.BoxMinP=(select max(v.Minp)
      from
        tdvi v
        inner join SkladList sl on sl.SkladNo=v.SKLAD
        inner join SkladGroups sg on sg.skg=sl.skg
      where
        v.hitag=#t.hitag
        and v.OnlyMinP=1
        and v.LOCKED=0
        and sl.Locked=0 and sl.AgInvis=0 and sl.SafeCust=0 and sl.Discard=0 and sl.SkladOperLock=0 and sl.Equipment=0
        and sg.PLID=1 and sg.Our_ID=7
        );
    if @nd=dbo.today()
      insert into #s(hitag,sell)
      select #t.hitag, sum(nv.kol*(iif(#t.flgWeight=1, v.weight, 1)))
      from
        nc
        inner join nv on nv.datnom=nc.datnom
        inner join #t on #t.hitag=nv.hitag
        inner join tdvi v on v.id=nv.tekid
      where
        nc.nd=@ND
        and nv.kol>0
        and nc.b_id=@b_id
      group by #t.Hitag;
    ELSE
      insert into #s(hitag,sell)
      select #t.hitag, sum(nv.kol*(iif(#t.flgWeight=1, v.weight, 1)))
      from
        nc
        inner join nv on nv.datnom=nc.datnom
        inner join #t on #t.hitag=nv.hitag
        inner join visual v on v.id=nv.tekid
      where
        nc.nd=@ND
        and nv.kol>0
        and nc.b_id=@b_id
      group by #t.Hitag;
    
    update #t set sell=#s.sell from #t inner join #s on #s.hitag=#t.hitag;
  
    update #t set Req=isnull(MinQty,0)-isnull(FactRest,0);
    update #t set Req=0 where Req<0;
    update #t set Req=round(Req,0) where flgWeight=0;
    update #t set Req=iif(SkladRest<0,0,SkladRest)+iif(BoxSkladRest<0,0,BoxSkladRest) where Req>iif(SkladRest<0,0,SkladRest)+iif(BoxSkladRest<0,0,BoxSkladRest)

    --  req:=Max(0,qryZakazMinQty.Value-qryZakazFactRest.AsFloat);
    --  if not qryZakazflgWeight.Value then req:=Round(req);
    --  req:=Min(req, Max(0,qryZakazSkladRest.Value)+Max(0,qryZakazBoxSkladRest.Value));
    --  if req>0 then qryZakazRequest.Value:=req;  
  
PRINT('КОНТРОЛЬНАЯ ТОЧКА 1 ПРОЙДЕНА');
--SELECT 'Табл.#T' as remark,* from #t;
    update guard.DepMatrixComplete set MinQty=isnull(MinQty,0)+(select sum(isnull(MinQty,0)) from #t) where @Comp=@Comp and sv_id=@sv_id and ag_id=@Ag_id and pin=@b_id;
if exists(select * from guard.DepMatrixComplete where Comp='it4' and pin in (15295,52511,3886)) select * from guard.DepMatrixComplete where Comp='it4' and pin in (15295,52511,3886);

--SELECT 'Рез.' as remark, * FROM guard.DepMatrixComplete  where @Comp=@Comp and sv_id=@sv_id and ag_id=@Ag_id and pin=@b_id;
  update guard.DepMatrixComplete set ForSale=(select sum(isnull(req,0)) from #t) where @Comp=@Comp and sv_id=@sv_id and ag_id=@Ag_id and pin=@b_id;
    update guard.DepMatrixComplete set FactSale=(select sum(isnull(Sell,0)) from #t) where @Comp=@Comp and sv_id=@sv_id and ag_id=@Ag_id and pin=@b_id;

   -- select * from #t;

    fetch next from c2 into @sv_id,@ag_id,@B_ID,@MLID;
    set @Cnt=@Cnt-1;
  end;
  close c2;
  deallocate c2;


/*






select * from #t order by ngrp,name;
*/
 

end