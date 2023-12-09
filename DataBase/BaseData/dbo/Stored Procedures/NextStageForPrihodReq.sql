CREATE PROCEDURE dbo.NextStageForPrihodReq @PrihodRID int, @OP int
AS
declare @ErrReg INT,@tranName varchar(21), 
  @CurStage int, @Ncom int, @hitag int, @price money, @cost money, @sert_id int, @minp int, @mpu int,  
  @dater datetime, @srokh datetime, @Country int, @sklad int, @Locked bit, @NDS int, @Producer int, 
  @MeasID int, @Netto decimal(10,3), @Brutto decimal(10,3), 
  --@flgWeight bit, 
  @Gtd varchar(30), @OnlyBox bit,  
  @PrihodRDetKolStr varchar(10), 
  --@PrihodRDetKol DECIMAL(10,3), 
  @ProducerName varchar(15), @StrDateR varchar(20), @StrSrokh varchar(20),
  @Lock int, @srok int, @TekID int, @ncod int, @pin int, @dck int, @sf bit, @our_id int, 
  --@weight decimal(20,4),
  @qty decimal(18,4), @unid SMALLINT;
set @tranname='NextStageForPrihodReq'
begin tran @tranname
	set @ErrReg=0
 
  select 	@CurStage=PrihodRDone, @ncod=PrihodRVendersID, @pin=PrihodRVenderPin, @dck=PrihodRDefContract, @sf=PrihodRDefSafeCust
    from dbo.prihodreq where PrihodRID=@PrihodRID
  
  if @CurStage=0 begin
  	update dbo.prihodreq set PrihodRDone=10, PrihodROperatorID=@OP where PrihodRID=@PrihodRID;
    set @ErrReg=@ErrReg+@@error;
    delete d from dbo.prihodreqdet d where d.PrihodRID=@PrihodRID and d.PrihodRDetCheck=0;
    set @ErrReg=@ErrReg+@@error;
    update d set d.PrihodRDetKolStr_plan=d.PrihodRDetKolStr
      from dbo.prihodreqdet d where d.PrihodRID=@PrihodRID;
    set @ErrReg=@ErrReg+@@error;
  end
  
  if @CurStage=10 begin
  	update PrihodReq set PrihodRDone=20, PrihodROperatorID=@OP where PrihodRID=@PrihodRID;
    set @ErrReg=@ErrReg+@@error;
    delete from PrihodReqDet where PrihodRID=@PrihodRID and PrihodRDetCheck=0;
    set @ErrReg=@ErrReg+@@error;
    
    update prihodreq set 	
      PrihodRSumCost=(select sum(p.PrihodRDetSummaCost) from PrihodReqDet p where p.PrihodRID=@PrihodRID),
      PrihodRSumPrice=(select sum(p.PrihodRDetSummaPrice) from PrihodReqDet p where p.PrihodRID=@PrihodRID),
      PrihodRNDS10=(select isnull((sum(p.PrihodRDetSummaCost)*10)/110,0) from PrihodReqDet p join nomen n on n.hitag=p.PrihodRDetHitag where p.PrihodRID=@PrihodRID and n.nds=10),
      PrihodRNDS18=(select isnull((sum(p.PrihodRDetSummaCost)*18)/118,0) from PrihodReqDet p join nomen n on n.hitag=p.PrihodRDetHitag where p.PrihodRID=@PrihodRID and n.nds=18),
      PrihodRNDS20=(select isnull((sum(p.PrihodRDetSummaCost)*20)/120,0) from PrihodReqDet p join nomen n on n.hitag=p.PrihodRDetHitag where p.PrihodRID=@PrihodRID and n.nds=20)
    where PrihodRID=@PrihodRID;
    set @ErrReg=@ErrReg+@@error;
    
    update prihodreq set PrihodRSumNDS=PrihodRNDS10+PrihodRNDS18+PrihodRNDS20
      where PrihodRID=@PrihodRID;
    set @ErrReg=@ErrReg+@@error;
  end
  
  if @CurStage in (20,30)
  begin
  	delete from PrihodReqDet where PrihodRID=@PrihodRID and PrihodRDetCheck=0;
    set @ErrReg=@ErrReg+@@error;
    
  	update prihodreq set 	PrihodRSumCost=(select sum(p.PrihodRDetSummaCost) from PrihodReqDet p where p.PrihodRID=@PrihodRID),
      PrihodRSumPrice=(select sum(p.PrihodRDetSummaPrice) from PrihodReqDet p where p.PrihodRID=@PrihodRID),
      PrihodRNDS10=(select isnull((sum(p.PrihodRDetSummaCost)*10)/110,0) from PrihodReqDet p join nomen n on n.hitag=p.PrihodRDetHitag where p.PrihodRID=@PrihodRID and n.nds=10),
      PrihodRNDS18=(select isnull((sum(p.PrihodRDetSummaCost)*18)/118,0) from PrihodReqDet p join nomen n on n.hitag=p.PrihodRDetHitag where p.PrihodRID=@PrihodRID and n.nds=18),
      PrihodRNDS20=(select isnull((sum(p.PrihodRDetSummaCost)*20)/120,0) from PrihodReqDet p join nomen n on n.hitag=p.PrihodRDetHitag where p.PrihodRID=@PrihodRID and n.nds=20)
    where PrihodRID=@PrihodRID;

    set @ErrReg=@ErrReg+@@error;
    
    update prihodreq set PrihodRSumNDS=PrihodRNDS10+PrihodRNDS18+PrihodRNDS20
      where PrihodRID=@PrihodRID;
    set @ErrReg=@ErrReg+@@error;
  	
  	select @Srok=srok, @our_id=our_id 
    from DefContract d 
    join PrihodReq p on d.DCK=p.PrihodRDefContract 
    where p.PrihodRID=@PrihodRid;
    
  	if @CurStage=20
    begin
      select @Ncom=isnull(max(ncom),0)+1 from dbo.comman;
      
      --начало:вставка шапки
      insert into dbo.comman (Ncom,Ncod,[date],[Time],summacost,summaprice,[ostat],realiz,corr,plata,closdate,srok,op,our_id,
        doc_nom,doc_date,comp,izmensc,errflag,copyexists,origdate,DCK,TN_nom,TN_date,OrdersID,SafeCust, 
        PIN,dlMarshID,dlMarshCost,PrihodRID)
      SELECT
        @Ncom,PrihodRVendersID,convert(varchar,getdate(),4),convert(varchar,getdate(),8),PrihodRSumCost,
        PrihodRSumPrice,PrihodRSumCost,0,0,0,null,@srok,@op,@our_id,PrihodRDocNum,PrihodRDocDate,
        PrihodRComp,0,0,0,null,PrihodRDefContract,PrihodRTNNum,PrihodRTNDate,PrihodROrdersID,
        PrihodRDefSafeCust,PrihodRVenderPin,dlMarshID,dlMarshCost,@PrihodRID
      from dbo.prihodreq
      where PrihodRID=@PrihodRid;
      set @ErrReg=@ErrReg+@@error
      --конец:вставка шапки
    end 
    else begin
      set @Ncom= (select top 1 PrihodRDetNCom
      from PrihodReqDet 
      where PrihodRID=@PrihodRid);
      
      update comman 
      set summaprice=pp.PrihodRSumPrice, summacost=pp.PrihodRSumCost, op=@op
      from comman c      
      inner join PrihodReqDet pd on pd.PrihodRDetNCom=c.Ncom 
      inner join PrihodReq pp on pp.PrihodRID=pd.PrihodRID
      where c.Ncom=@Ncom;
      set @ErrReg=@ErrReg+@@error;
    end
    
    --начало:вставка табличной части
    declare CurDet cursor for  
    SELECT PrihodRDetHitag,PrihodRDetPrice,PrihodRDetCost,sert_id,minp,mpu,PrihodRDetDate,
      PrihodRDetSrokh,LastCountryID,PrihodRDetSkladID,PrihodRDetLocked,   nds,LastProducerID,
      MeasID,Netto,Brutto,
      --flgWeight,
      PrihodRDetGtd,s.OnlyMinP,ltrim(RTRIM(p.PrihodRDetKolStr)),
      --PrihodRDetKol,
      pr.ProducerName,
      --p.PrihodRDetWeigth,
      p.QTY,p.unID
    from 
      PrihodReqDet p
      join nomen n on n.hitag=p.PrihodRDetHitag
      join SkladList s on s.SkladNo=p.PrihodRDetSkladID
      left join Producer pr on pr.ProducerID=n.LastProducerID
    where PrihodRID=@PrihodRid and PrihodRDetIsSave=0;
      
    open CurDet
    
    fetch next from CurDet into
      @hitag, @price, @cost, @sert_id, @minp, @mpu, @dater, @srokh, @Country,
      @sklad, @Locked,  @NDS, @Producer,@MeasID, @Netto, @Brutto, 
      --@flgWeight, 
      @Gtd, @OnlyBox, @PrihodRDetKolStr, 
      --@PrihodRDetKol, 
      @ProducerName, 
      --@WEIGHT,
      @qty, @unid;
    
    while @@fetch_status=0
    begin
    	--если штучный товар то вес равен 0
    	--if @flgWeight=0 
      	--set @WEIGHT=0
        
    	-- дата изготовления и срок хранения
      if @dater is null or @Dater<'20000101' 
        begin
          set @dater=null;
          set @StrDateR=null;
        end; 
      else 
        set @StrDater=CONVERT(varchar,@dater,4);
   
      if @srokh is null or @srokh<'20000101' 
        begin
          set @srokh=null;
          set @Strsrokh=null;
        end; 
      else 
        set @Strsrokh=CONVERT(varchar,@srokh,4);
      
      -- если не тара и не исключения типа справок и поддонов, то блокируем
      --set @Lock=(select 0 from taracode2 t where t.TaraTag=@hitag group by t.TaraTag);
      --if @hitag in (5659,2296,90858,95007,15028) set @Lock=0;
      
      --if @Lock is null set @Lock=2;
      set @lock=0
			
      -- в tdvi новый ID товара
--      set @TekID=(select IsNull(max(ID),0)+1 from TDVI);
      
			--обновлен цен в nomen:
			update Nomen set cost=@cost, price=@price where hitag=@hitag;
			
      -- Запись в склад:
      insert into tdVI(ND, StartID,Ncom,Ncod,DatePost,Price,Start,StartThis,Hitag,
        Sklad,Cost,Nalog5,MinP,Mpu,Sert_ID,Morn,Sell,Isprav,REMOV,Bad,DateR,Srokh,
        CountryID,Rezerv,Locked,ProducerID,Gtd,Vitr,Our_ID,
        --WEIGHT,
        SaveDate,MeasID,
        OnlyMinP,DCK,SafeCust,Country,LockID, PIN,unid)
      values(dbo.today(), 0,@Ncom,@Ncod,dbo.today(),@Price,@QTY,
        @QTY,@Hitag,@Sklad,@Cost,0,@MinP,@Mpu,@Sert_ID,@QTY,0,
        0,0,0,@DateR,@Srokh,@Country,0,@Locked,@Producer,@Gtd,0,@Our_ID,
        --@WEIGHT,
        dbo.today(), @MeasID,@OnlyBox,@dck,@sf,@ProducerName,@Lock,@pin,@unid)

      SELECT @TekID= SCOPE_IDENTITY();
      update tdvi set startid=@tekid where id=@tekid;
                                
      set @ErrReg=@ErrReg+@@error;
                        
        -- Запись в Log при изменении блокировки
      if @Lock=2
      insert into Log (OP,Comp,Tip,MESS,Param1,Param2,Param3,Param4)
      select 	0, --попросили выставить блокировку
        host_name(),
        'Блок',
        'Блокировка, Hitag/ID/Rest/Lock:',
        cast(@HITAG as varchar(15)),
        cast(@TekID as varchar(15)),
        --cast(@PrihodRDetKol as varchar(15)),
        cast(@QTY as varchar(15)),
        cast(@Lock as varchar(15));
     set @ErrReg=@ErrReg+@@error;

      -- Запись детализации прихода:
     insert into Inpdet(ND, ncom, id, hitag, price, cost, 
      --kol,
      sert_id,minp,mpu,dater,srokh,
       nalog5,op,sklad,kol_b,summacost,CountryID,ProducerID,
       --[weight],
       qty, unid)
     values(dbo.today(),@ncom, @TekID, @hitag, @price, @cost, 
      --@PrihodRDetKol,
      @sert_id,
       @minp,@mpu,@StrDateR,CONVERT(varchar,@srokh,4),0,@op,@sklad,0,
       --@cost*IsNull(@PrihodRDetKol,0),
       @cost*IsNull(@qty,0),
       @Country, @Producer,
       --@WEIGHT,
       @qty, @unid);
    
     set @ErrReg=@ErrReg+@@error;

     if not exists(select * from nomenvend where dck=@dck and hitag=@hitag)
     begin
      	insert into NomenVend (Hitag,ExtTag,Ncod,nd,DCK,cost,price,pin,sklad)
          values (@hitag,Null,@Ncod,dbo.today(),@dck,@cost,@price,@pin,@sklad);
      	set @ErrReg=@ErrReg+@@error;
      end
      else begin
      	update NomenVend SET Nd=dbo.today(),cost=@cost,price=@price,pin=@pin,sklad=@sklad
        where DCK=@dck and hitag=@hitag;
        set @ErrReg=@ErrReg+@@error;
      end 
      
      if exists(select * from dbo.nomenvend where dck=@dck and hitag=@hitag and isnull(exttag,'')='')
      begin
        declare @exttag varchar(20);
        set @exttag=isnull((
          select top 1 vd.exttag
          from dbo.nomenvend vd
          join dbo.defcontract dc on dc.dck=vd.dck 
          where vd.hitag=@hitag and dc.pin=@pin),'');
        if @exttag<>'' update dbo.nomenvend set exttag=@exttag where dck=@dck and dck=@dck;
      end
      
      if datediff(day,@dater,@srokh)>0 update n set n.shelflife=datediff(day,@dater,dateadd(day,1,@srokh)) from dbo.nomen n where n.hitag=@hitag  
      	
      fetch next from CurDet into
        @hitag, @price, @cost, @sert_id, @minp, @mpu, @dater, @srokh, @Country,
        @sklad, @Locked,  @NDS, @Producer,@MeasID, @Netto, @Brutto, 
        --@flgWeight, 
        @Gtd, @OnlyBox, @PrihodRDetKolStr, 
        --@PrihodRDetKol, 
        @ProducerName, 
        --@WEIGHT, 
        @qty, @unid
    end
    
    close CurDet
    deallocate CurDet 
    
    if @CurStage=20 begin
    	update PrihodReq set PrihodRDate=getdate(), PrihodRSaveTo=0,PrihodRDone=30, PrihodROperatorID=@OP  where PrihodRID=@PrihodRid;
   		set @ErrReg=@ErrReg+@@error;
    end
  	
    update PrihodReqDet set PrihodRDetNCom=@ncom where PrihodRID=@PrihodRid and PrihodRDetIsSave<>1;   
    set @ErrReg=@ErrReg+@@error;
  	update PrihodReqDet set PrihodRDetIsSave=1 where PrihodRID=@PrihodRid;  
    set @ErrReg=@ErrReg+@@error;
    update orders set ncom=@ncom where a3id=@PrihodRID;
		set @ErrReg=@ErrReg+@@error;
		exec addr_warehouse.wares_distr @ncom;
    declare @comp varchar(50), @err INT;
    set @comp=host_name()
    set @err=0

    --    Глушим нахрен! Почему это Николай не прибил?
    --    if @CurStage=20
    --    begin
    --    	--if exists(selct 1 from dbo.inpdet where not id in (select tekid from retrob.bascheckprice_new(@ncom) where prID>0) )	set @errreg=@errreg + 256
    --      if @errreg=0
    --      begin
    --        insert into retrob.BasInpdet (prID, startid,basecost,finalcost,finalcost1kg)
    --        select distinct z.prID,z.tekid,z.BaseCost,z.PrihodCost,z.cost1kg
    --        from retrob.bascheckprice_new(@ncom) z --RetroB.BasCheckPricePrihod(@PrihodRID) z
    --        where z.prID>0 
    --        
    --        exec retrob.BasReassesment @Ncom, @op, @comp, @kolError=@err output, @serialnom=0
    --        if (@err & 7) <> 0 set @ErrReg=@ErrReg+128
    --      end  
    --    end

  end


if @ErrReg=0 
begin
	commit tran @tranname
	select cast(0 as bit) as [n], '' as [Res]    
end
else
begin
	rollback tran @tranname
  declare @msg varchar(500)
  set @msg=''
  set @msg=iif(@ErrReg & 256 <> 0,'Не подобраны спецификации','')
	select cast(1 as bit) as [n], 'Во время выполнения произошла ошибка'+iif(@err<>0,' - Код ошибки: '+cast(@err as varchar),'')+' '+@msg as [Res]
end