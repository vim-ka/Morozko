CREATE PROCEDURE dbo.SyncRequestsBySell @op int, @Datnom int, @NCod int=694 -- 694 - это Морозко
AS
declare @ErrReg int, @dt datetime,@OrdID int,@PrihodRID int, @dck int, @Pin int
begin
  set @ErrReg=0
  set @dt=dbo.today()
  set @pin=(select pin from def where Ncod=@Ncod)
  set @Dck=(select top 1 dc.dck from defcontract dc where dc.pin=@Ncod and dc.Actual=1 and dc.ContrMain=1 and dc.ContrTip=1)

  begin tran SyncRequestsBySell
    
    -- Заголовок запроса прихода:
   	insert into PrihodReq(PrihodRDate, PrihodROperatorID, PrihodRVendersID, PrihodRSumPrice, PrihodRSumCost,
      PrihodRDone, PrihodROurID,PrihodRDocNum,PrihodRDocDate,PrihodROrdersID,PrihodRTNNum,PrihodRTNDate,PrihodRDefContract,
      PrihodRDefSafeCust,PrihodRSaveTo,PrihodRVenderPin,PrihodRNDS10,PrihodRNDS18,PrihodRSumNDS,NeedReCalc)
  	select getdate(),	@OP, @Ncod,nc.SP, nc.SC, 0,10,'',@dt,0,'',@dt,@dck, 0,0,@Pin,0,0,0,1
  	from nc where nc.datnom = @datnom


    set @errReg=@errReg+@@ERROR
      
    if @errReg=0 begin
      -- Детализация:
      select @PrihodRID=SCOPE_IDENTITY()
      if Object_Id('tempdb..#t') is not null drop table #t;
      -- Заготовка, цена прихода равна исходной цене продажи:
      create table #t(hitag int, Kol int, Price decimal(12,2), cost decimal(15,5), Sklad int default 100, flgWeight bit, SumWeight decimal(10,3));

      insert into #t(hitag,kol,cost,SumWeight, flgWeight)
        SELECT 
          nv.hitag, 
          sum(nv.kol) Kol, 
          sum(nv.kol*nv.Price*(1.0+0.01*nc.extra)) / sum(nv.kol) as AvgPrice,
          sum(nv.kol*iif(v.weight=0,nm.netto,v.weight)),
          nm.flgWeight
        from 
          NC
          inner join nv on nv.datnom=nc.datnom
          inner join nomen nm on nm.hitag=nv.hitag
          inner join tdvi v on v.id=nv.tekid
        where nc.datnom=@Datnom and nv.kol>0
        group by nv.hitag, nm.flgWeight;

      -- Возможно, что-то еще лежит в необработанных заявках на весовой склад:
      insert into #t(hitag,kol,cost,SumWeight, flgWeight)
      select 
        z.Hitag, z.Zakaz, z.Price*(1.0+0.01*nc.extra), z.zakaz*nm.netto as SumWeight, nm.flgWeight
      from 
        NC
        inner join nvZakaz Z on Z.datnom=NC.DatNom
        inner join Nomen nm on nm.hitag=z.hitag
      where 
        nc.datnom=@Datnom and Z.Done=0;



      -- Недостающую информацию подтягиваем из NomenVend:
      update #t set 
        -- Price=nomenvend.price*iif(nomenvend.flgWeight=1 and #t.SumWeight>0, #t.SumWeight, 1),
        Sklad=nomenvend.sklad
      from #t inner join nomenvend on nomenvend.hitag=#t.hitag
      where nomenvend.Ncod=@ncod;

      
      
      -- С ценой в NomenVend как-то неладно. Лучше вытащу последнюю цену продажи из Inpdet
      if OBJECT_ID('tempdb..#i') is not null drop table #i;
      create table #i(hitag int, MaxID int, Price decimal(15,5));
      insert into #i(hitag,maxid) select #t.hitag, max(i.id) 
      from 
        #t 
        inner join inpdet i on i.hitag=#t.hitag 
        inner join Comman cm on cm.ncom=i.ncom
      where cm.Ncod = @Ncod
      group by #t.hitag;

      update #i set Price=i.Price from #i inner join inpdet i on i.id=#i.maxid;
      update #t set 
        Price=#i.price*iif(#t.flgWeight=1 and #t.SumWeight>0, #t.SumWeight, 1)
      from #t inner join #i on #i.hitag=#t.hitag; 
      


      update #t set sumWeight=0 where flgWeight=0;

  --select #t.*, nm.name, nm.flgWeight from #t inner join nomen nm on nm.hitag=#t.hitag;
    
      insert into PrihodReqDet (PrihodRID,PrihodRDetHitag,PrihodRDetPrice,
        PrihodRDetCost, PrihodRDetSummaCost,PrihodRDetSummaPrice,PrihodRDetLocked,
        PrihodRDetKolStr, PrihodRDetOperatorID,PrihodRDetSkladID,PrihodRDetIsSave,
        PrihodRDetCheck,  PrihodRDetKol,PrihodRDetWeigth)
      select @PrihodRID as PrihodRID, #t.Hitag,#t.price,
        #t.cost,  #t.Kol*#t.Cost as SummaCost, #t.Kol*#t.Price as SummaPrice, 0 as Locked,
        case when #t.flgWeight=1 and #t.SumWeight>0 then cast(#t.SumWeight as varchar) 
        else (select dbo.UnitInStr((cast(cast(#t.kol as int) as varchar(10))),nm.minp)) end as KolStr,
        @OP as OP,#t.sklad,
        0 as IsSave,0 as PrihodRDetCheck,#t.kol,#t.sumWeight
      from 
        #t
        inner join nomen nm on nm.hitag=#t.hitag;
    	set @errReg=@errReg+@@ERROR
    end;

  if @ErrReg=0 begin
  	commit tran SyncRequestsBySell
  	select cast(0 as bit) as [n], '' as [Res]
  end
  else begin
  	rollback tran SyncRequestsBySell
  	select cast(1 as bit) as [n], 'Во время синхронизации произошла ошибка' as [Res]
  end
END