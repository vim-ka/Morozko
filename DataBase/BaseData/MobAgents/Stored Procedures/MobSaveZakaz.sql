CREATE procedure MobAgents.MobSaveZakaz
    @B_ID int, 
	@DCK int, 
	@CompName varchar(30), 
	@Tip varchar(40), 
	@Hitag int, 
	@Qty float, 
	@Price money, 
    @ClearZakaz bit=0, 
	@OP int=0, 
	@Ag_id int=0, 
	@Remark varchar(255),
    @SavedZakaz float=0 out, 
  	@Force_ag_id int=0,
    @StfNom varchar(17)='', 
	@StfDate datetime=NULL,
    @DocNom varchar(20)='', 
	@DocDate datetime=NULL,
    @flgIgnorInvis bit=0, -- 1, если нужно игнорировать SkladList.AgInvis
    @SkladList varchar(max)=''
as 
declare @OrdStick bit, @Disab bit
declare @Sklad int, @Tek int, @tekid int, @AlienReq int, @Cnt int
declare @Rest int
declare @NDS int, @flgWeight bit
declare @Cost money, @PriceVI money
declare @EffWeight float, @Netto decimal(10,3)
declare @AlienZakaz int
declare @DelivGroup int, @Datnom1 int, @Datnom2 int
declare @Reg_id char(3), @Done bit
declare @TekND datetime
declare @DepID int,  @SV_ID int
declare @Ngrp int,  @Ncod int, @NgrpParent int
declare @Extra float, @MinExtra float, @QtyZakaz int
declare @DisMinExtra bit, @lchr int, @rchr int, @FirmGroup int, @P_ID int
declare @Rests float, @Prognoz float, @Debit float, @RemMess varchar(100), @DepIDExec int

begin
  --set @TekND=(select dateadd(day, datediff(day,0,getdate()),0));
  set @TekND=dbo.today();
  
  /*set @lchr=CHARINDEX('{',@Remark)
  set @rchr=CHARINDEX('}',@Remark)*/
  
  declare @ShelfLife int
 
  select @flgWeight=n.flgWeight, @Netto=n.Netto, @ShelfLife=isnull(n.ShelfLife,30)
  from nomen n where n.hitag=@Hitag
  
  /*if (@lchr>0) and (@rchr>@lchr)  
  begin
    set @DocNom=substring(@Remark,@lchr+1,@rchr-2)
    set @Remark=stuff(@Remark,@lchr,@rchr, '')
  end else set @DocNom=substring(@Remark,1,20)*/
  
  insert into dbo.LogZakazInputParams(B_ID,DCK,CompName,Tip,Hitag,Qty,Price,ClearZakaz,OP,Ag_id,Remark,SavedZakaz,
  									Force_ag_id,StfNom,StfDate,DocNom,DocDate) 
  values(@B_ID,@DCK,@CompName,@Tip,@Hitag,@Qty,@Price,@ClearZakaz,@OP,@Ag_id,@Remark,@SavedZakaz,
   	   @Force_ag_id,@StfNom,@StfDate,@DocNom,@DocDate)
  
  /*Обработка технических кодов клиентов*/
  /*=============================================Разблокировка точек====================================*/
  if @DCK = 99998 
  begin
    
    create table #UinPin (pin int)
    insert into #UinPin select cast(k as int) from dbo.Str2intarray(@Remark)
    
    update def set disab=0, debit=0 where pin in (select pin from #UinPin)
    insert into dbo.EnabLog (CompName, B_ID, Enab, CheckDate, OP, Comment) 
    select 'tdmsql', t.pin, 1, getdate(), @Ag_ID+1000, 'Разблокировка с КПК'
    from #UinPin t 
     
    drop table #UinPin      
  end
  else  
  /*=============================================Конец рабочего дня======================================*/
  if @DCK = 99999 /*Конец рабочего дня у ТП*/
  begin
    if not exists(select * from AgentsInfo where nd=@TekND and Ag_id=@Ag_id and info=1) 
    Insert into AgentsInfo (ag_id,info) values (@ag_id,1)
  end
  else    
  
  /*==============================================Сохранение остатков====================================*/
  if @Tip='shopunitlist' --аудит
  begin
    if @flgWeight = 1 
      set @QtyZakaz = Round(1.0*@Qty/@Netto,0) --1
    else
    begin
      set @QtyZakaz=Round(@Qty,0);
      set @Qty=0
    end    
    
    
    if exists(select * from Rests where dck=@dck and hitag=@hitag and nd>=@TekND and ag_id=@Ag_id)
    begin
      update Rests set qty = @QtyZakaz, Remark=@Remark, weight = @Qty
      where dck = @dck and hitag = @hitag and nd = @TekNd and ag_id = @Ag_id
    end
    else
    begin
      insert into Rests (dck, hitag, qty, ag_id, Remark, Weight) values (@Dck, @Hitag, @QtyZakaz, @Ag_id, @Remark, @Qty)
    end
  end
  else 
  
  /*=======================================Сохранение переводного заказа==================================*/
  if @Tip='predstavitelskiy' --переводной заказ
  begin
    if @flgWeight=1 
    set @QtyZakaz=Round(1.0*@Qty/@Netto,0)
    else
    set @QtyZakaz=Round(@Qty,0);
  
    if exists(select * from AdVOrder where dck=@dck and Hitag=@Hitag and nd=@DocDate and ag_id=@Ag_id)
    begin
      update AdvOrder set qty = @QtyZakaz
      where Dck = @Dck and Hitag=@Hitag and nd=@DocDate and ag_id=@Ag_id
    end
    else
    begin
      insert into AdvOrder (Dck,date,hitag,qty,ag_id,nd) values (@Dck,@TekND,@Hitag,@QtyZakaz,@Ag_id,@DocDate)
    end
  end
  else
  /*=======================================Сохранение заявок на возврат===================================*/
  if lower(@Tip)='retfalse' or lower(@Tip)='rettimeout'  or lower(@Tip)='rettrue' 
  begin
    if @B_ID = 0 set @B_ID = (select pin from DefContract where dck=@DCK)
    
    if @flgWeight = 1 --and @Netto > 0
    set @QtyZakaz = 1    --Round(1.0*@Qty/@Netto,0)
    else
    set @QtyZakaz=Round(@Qty,0);
    
    set @Ngrp = (select n.Ngrp from nomen n where n.hitag=@Hitag);
    set @Ngrp=isnull(dbo.GetGrOnlyParent(@Ngrp),@Ngrp);
    
    
    if (@QtyZakaz = 0 and @Qty<>0) or (@QtyZakaz = 1 and @Qty<0.15 and @Ngrp=85)
    insert into MobAgents.Mess(ag_id,  pin,  dck,  ND,  tm,  Remark,  MessType,  data0) 
    values (@ag_id,  @B_ID,  @dck,  @TekND,  dbo.[time](), iif(@flgWeight=0, cast(@Qty as varchar)+'шт.',cast(@Qty as varchar)+'кг'),  4,  @hitag); 
      
    
    declare @Rk int, @uin int, @sourcedatnom int, @tovprice numeric(10,2), @Delta int, @reftekid int, @master int, @BackPeriod int
    declare @tekKol int, @gpName varchar(100), @AgFIO varchar(100), @Otv int, @meta int
    
    set @uin=(select u.uin from usrPWD u where u.P_ID=(select a.p_id from agentlist a where a.ag_id=@Ag_id))
    set @master=(select master from def where pin=@B_ID)
    
    if @Ngrp = 85 
    begin
      if @ShelfLife<=20 set @BackPeriod=25
      else if @ShelfLife<=25 set @BackPeriod=30
      else if @ShelfLife<=30 set @BackPeriod=35
      else if @ShelfLife<=40 set @BackPeriod=45
      else if @ShelfLife<=45 set @BackPeriod=50
      else if @ShelfLife<=60 set @BackPeriod=60
      else if @ShelfLife<=90 set @BackPeriod=90
      else if @ShelfLife<=120 set @BackPeriod=120
      else set @BackPeriod=180;
      --else if @ShelfLife<=180 set @BackPeriod=180

    end
    else set @BackPeriod=200;
    
    select @Otv = Otv from ReqTypes where ReqTypeID=142
    
    if lower(@Tip)='retfalse' set @meta = 4
    else if lower(@Tip)='rettimeout' set @meta = 5
    else if lower(@Tip)='rettrue' set @meta = 6;
    
    if @Remark like '%Самовывоз%' set @DepIDExec=37 else set @DepIDExec=13;
    
    BEGIN TRANSACTION SaveBack;
    
    if exists (select r.Rk from Requests r join ReqReturn t on r.Rk=t.reqnum
               where r.ND>=@TekND and r.Tip2 = 142 and r.Rs = 1 and t.DCK=@DCK and t.Comment=@Remark and r.meta=@meta)
    begin
      set @Rk=(select r.rk from Requests r join ReqReturn t on r.Rk=t.reqnum
               where r.ND>=@TekND and r.Tip2 = 142 and r.Rs = 1 and t.DCK=@DCK and t.Comment=@Remark and r.meta=@meta)
    end
    else
    begin
      
      set @DepID = (select s.DepID from agentlist s where s.ag_id=@Ag_id)   
      
      if @uin is null
      begin
        if @DepID = 1 set @uin = 1
      end  
      
      set @gpName = (select gpName from Def where pin=@B_ID)
      set @AgFIO=(select p.Fio from person p where p.P_ID=(select a.p_id from agentlist a where a.ag_id=@Ag_id))
      
      insert into  dbo.Requests(ND, DepIDCust, DepIDExec, Op, Content, Remark, NeedND, Plata, RemarkExec,  KsOper,  RemarkFin, PlanND, [Status], RealND, 
               RemarkMain, ReqAvail, Nal,  ReqAv,  FactND,  Period,  RemarkMtr,  Rs,  Rf,  [Sent],  SalaryMonth,  PersonnelDepMessage,  [Type],  
               tm,  rql, Bypass,  Itsright,  [Data],  PlataOver,  ByCall,  Otv2,  Tip2,  Data2,  ResFin2,  Prior2,  Locked,  ResFin2ND,  compname, ag_id, meta) 
      values (getdate(), @DepID, @DepIDExec, @uin, 'Возврат товара с точки #'+cast(@B_ID as varchar)+' '+@gpName+'. Договор #'+cast(@DCK as varchar),'Забрать возврат', @TekND, 0,'',NULL,'',@TekND,1,@TekND,'',0,0,0,NULL,0,'',1,0,0,0,'',0,
               dbo.time(),0,0,0,'',0,0, @Otv,142,'Возврат (Инициатор:'+@AgFIO+')',0,0,0,NULL,@CompName, @Ag_ID, @meta)  
     
      set @Rk=SCOPE_IDENTITY() 
        
      insert into dbo.ReqReturn (reqnum,  pin, ret_nd, comment, dck)--, sourcedatnom) 
      values (@Rk, @B_ID, @TekND, @Remark, @DCK)--,0)
    end;  
      
    --select @ShelfLife = isnull(ShelfLife,0) from Nomen where hitag=@hitag

    declare SelectGood cursor fast_forward local
    for select v.datnom, iif(i.weight<>0,v.price/i.weight,v.price) as price, v.kol - v.kol_b as kol, iif(DateDiff(DAY,@TekND - @ShelfLife,c.nd)<0,-3,1)*DateDiff(DAY,@TekND - @ShelfLife,c.nd) as Delta, v.sklad, i.weight-isnull(j.weight_b,0), v.tekid
    from nv v join visual i on v.tekid=i.id
              join nc c on v.datnom=c.datnom
              left join (select nj.refdatnom, nj.reftekid, sum(nj.weight) as weight_b from nv_join nj group by nj.refdatnom, nj.reftekid) j
              on v.datnom=j.refdatnom and v.tekid=j.reftekid
               
    where c.dck=@dck and v.hitag=@hitag and v.kol-v.kol_b>0 and c.actn=0  
          and c.nd>=DATEADD(DAY,-@BackPeriod, @TekND)

          
   /* возврат  по сети
   union 
    
    select v.datnom, iif(i.weight<>0,v.price/i.weight,v.price) as price, v.kol - v.kol_b as kol, abs(DateDiff(DAY,@TekND - @ShelfLife,c.nd)) as Delta, v.sklad, i.weight-isnull(j.weight_b,0)*0.9, v.tekid
    from nv v join visual i on v.tekid=i.id
              join nc c on v.datnom=c.datnom
              join def d on c.b_id=d.pin
              left join (select nj.refdatnom, nj.reftekid, sum(nj.weight) as weight_b from nv_join nj group by nj.refdatnom, nj.reftekid) j
              on v.datnom=j.refdatnom and v.tekid=j.reftekid
    where d.master=@master and v.hitag=@hitag and v.kol-v.kol_b>0 
          and c.nd>=DATEADD(DAY,-200, @TekND) and c.actn=0       
    */      
    order by Delta,price;    
    
    if @Qty = 0 
    begin
      insert into dbo.ReqReturnDet(reqretid, hitag, kol, fact_weight, ret_reason, sourcedatnom, tovprice, sklad, reftekid)  
      values(@Rk, @Hitag, 0, 0, 1, 0, @price, 0, 0)
    end    
      
    open SelectGood
    fetch next from SelectGood
    into @sourcedatnom, @tovprice, @tekKol, @Delta, @sklad, @EffWeight, @reftekid
    
    set @Done = 0
           
    while (@@FETCH_STATUS = 0) and ((@QtyZakaz > 0 and @flgWeight = 0) or (@Qty > 0 and @flgWeight = 1))
    begin
    
      if @flgWeight = 0
      begin  
        if @QtyZakaz < @tekKol set @tekKol=@QtyZakaz 
        set @QtyZakaz = @QtyZakaz - @tekKol
        set @EffWeight = 0
        
        insert into dbo.ReqReturnDet(reqretid, hitag, kol, fact_weight, ret_reason, sourcedatnom, tovprice, sklad, reftekid)  
        values(@Rk, @Hitag, @tekKol, @EffWeight, 1, @sourcedatnom, @tovprice, @sklad, @reftekid)
        set @Done = 1
      end  
      else
      if @EffWeight > 0
      begin
        if @Qty < @EffWeight set @EffWeight = @Qty 
        set @Qty = @Qty - @EffWeight
        set @tekKol = 1
        set @tovprice = round(@tovprice*@EffWeight,2)
        
        insert into dbo.ReqReturnDet(reqretid, hitag, kol, fact_weight, ret_reason, sourcedatnom, tovprice, sklad, reftekid)  
        values(@Rk, @Hitag, @tekKol, @EffWeight, 1, @sourcedatnom, @tovprice, @sklad, @reftekid)
        
        set @Done = 1
      end  
      
      fetch next from SelectGood
      into @sourcedatnom, @tovprice, @tekKol, @Delta, @sklad, @EffWeight, @reftekid
      
    end
    
    close SelectGood;
    deallocate SelectGood;
    
    if @Done=1 COMMIT TRANSACTION SaveBack;
    else       ROLLBACK TRANSACTION SaveBack;
      
    if (@QtyZakaz > 0 and @flgWeight = 0) or (@Qty > 0 and @flgWeight = 1)
    insert into MobAgents.Mess(ag_id,  pin,  dck,  ND,  tm,  Remark,  MessType,  data0) 
    values (@ag_id,  @B_ID,  @dck,  @TekND,  dbo.[time](), iif(@flgWeight=0, cast(@QtyZakaz as varchar)+'шт.',cast(@Qty as varchar)+'кг'),  3,  @hitag);
    
  end
  else
  /*==============================================Сохранение обычного заказа============================================*/
  if @Tip='provodnoy' --обычный заказ
  begin
    declare @AllSklads bit
    
    if @Hitag>99999 
    begin
      set @sklad=@Hitag-1000*FLOOR(@Hitag/1000);
      set @Hitag=FLOOR(@Hitag/1000);
      if @SkladList='' set @SkladList = cast(@sklad as varchar)
      else set @SkladList=@SkladList+','+cast(@sklad as varchar);
    end
    
    if @SkladList='' set @AllSklads = 1
    else set @AllSklads = 0;
  
    select @B_ID=pin, @Disab=Disab from DefContract where dck=@DCK
    
    declare @PlannedVisit bit, @FreshNessGood int, @PLID int
    set @PlannedVisit = 1 --isnull((select cast(1 as bit) from planvisit2 where ag_id=@ag_id and dck=@dck and dn=datepart(weekday, dbo.today())) ,0)
    set @FreshNessGood = isnull((select cast(TagValue as int) from DefTags dt where dt.TagID = 30 and dt.ID = @B_ID),0)
    
    if @OP < 1000 
      set @PLID=(select PLID from usrPWD where uin=@OP)
    else  
      set @PLID=(select d.PLID from Deps d join Agentlist a on d.DepID=a.DepID where a.ag_id=@ag_id)
    
    
    if @PlannedVisit = 0 and @ag_id in (55,162,139)
    begin
      if not exists(select 1 from MobAgents.Mess where ag_id=@ag_id and dck=@dck and nd=dbo.today()) 
      begin    
        set @RemMess='Внимание! Торговая  точка посещена не по плану. Занесите ее в план посещений. Заявка отклонена.'
        insert into MobAgents.Mess (ag_id, pin, dck, Remark, MessType) 
        values (@Ag_id, @B_ID, @DCK, @RemMess, 5) 
      end  
    end  
    else
    begin
       
    if @flgWeight=1 and @Netto>0
    begin
      set @QtyZakaz=Round(1.0*@Qty/@Netto,0);
      if @QtyZakaz = 0 set @QtyZakaz=1;
    end  
    else
    set @QtyZakaz=Round(@Qty,0);
  
    if @QtyZakaz = 0 
    insert into MobAgents.Mess(ag_id,  pin,  dck,  ND,  tm,  Remark,  MessType,  data0) 
    values (@ag_id,  @B_ID,  @dck,  @TekND,  dbo.[time](), iif(@flgWeight=0, cast(@QtyZakaz as varchar)+'шт.',cast(@Qty as varchar)+'кг'),  4,  @hitag); 
         
    if @ClearZakaz = 1 delete from Zakaz where CompName=@CompName;
    
    select @P_ID=P_ID, @DepID=DepID from agentlist where ag_id=@ag_id
    
    /*select @FirmGroup=FC.FirmGroup from FirmsConfig fc join Person p on fc.Our_id=p.Our_id
     where p.P_ID=@P_ID*/
     
    select @FirmGroup=FC.FirmGroup from FirmsConfig fc join Deps d on fc.Our_id=d.Our_id and d.DepID=@DepID

    
    set @RemMess='Клиент в блоке'
    
    set @Debit = isnull((select sum(d.overdue)-
           (select sum(k.plata) as NN from Kassa1 k where k.ND = @TekND and k.Oper=-2 and k.DCK = @DCK) as NN
    from DailySaldoDck d join DefContract e on d.dck=e.dck 
    where d.Deep > 0 and d.nd = @TekND + e.Srok - 5 and d.dck = @DCK),0)
    
    set @Ngrp = (select n.Ngrp from nomen n where n.hitag=@Hitag);   
    
    if @Hitag in (94502,94503,94504)
    begin
    
      declare @TipMess integer
      
      if @Hitag=94502 set @TipMess=1
      else if @Hitag=94503 set @TipMess=2
      else if @Hitag=94504 set @TipMess=3 
       
      insert into dbo.DefAlert (ND, TM, Dck, Tip, SourceOP, StrMessage) 
      values (@TekND,dbo.GetTime(), @Dck, @TipMess, @OP, @Remark)
    end
    else
    if @Debit>0
    begin
      set @NgrpParent = (select g.MainParent from Gr g where g.Ngrp=@Ngrp);
      if @Ngrp in (7,76) 
      begin
        set @Disab=1
        set @RemMess='Продажа РЫБЫ/ПТИЦЫ должникам запрещена'
      end
    end
    
    if (@Disab = 1) 
    begin 
      set @Cnt=isnull((select count(MessID) from MobAgents.Mess where ag_id=@Ag_id and DCK=@DCK and nd=@TekND),0)
      if @Cnt = 0
      insert into MobAgents.Mess (ag_id, pin, dck, Remark, MessType) 
      values (@Ag_id, @B_ID, @DCK, @RemMess, 0)
    end 
    else
    begin
 
      set @Reg_id = (select d.Reg_ID from Def d where d.pin=@B_ID);   

      select @Sv_id=a.sv_ag_id, @DepID=a.DepID,@OrdStick=isnull(a.OrdStick,0) from agentlist a where a.ag_id=@Ag_ID 
      
      declare CurRest cursor local fast_forward for 
      select 
        v.id, v.sklad, v.ncod, v.price, v.cost, 
        case when (SL.UpWeight=1) and (n.flgWeight=1) 
             then case when n.netto=0 then iif(round((v.morn-v.sell+v.isprav-v.remov-v.bad-v.rezerv)*v.[WEIGHT],0)=0,1,round((v.morn-v.sell+v.isprav-v.remov-v.bad-v.rezerv)*v.[WEIGHT],0))
                                      else iif(round((v.morn-v.sell+v.isprav-v.remov-v.bad-v.rezerv)*v.[WEIGHT]/n.netto,0)=0,1,round((v.morn-v.sell+v.isprav-v.remov-v.bad-v.rezerv)*v.[WEIGHT]/n.netto,0)) end
             else
             round(v.morn-v.sell+v.isprav-v.remov-v.bad-v.rezerv,0)
        end 
        as Rest,
        round(sum(isnull(z.Qty,0)),0) as AlienReq,
        v.[weight],
        n.netto,
        n.nds,
        n.flgWeight
      from tdVi v left join Zakaz z on Z.tekid=v.id
                  inner join SkladList SL on SL.SkladNo=V.SKLAD
                  inner join nomen n on v.hitag=n.hitag
                  inner join SkladGroups g on SL.skg=g.skg
                  left join FirmsConfig f on f.OUR_ID=v.our_id
                  left join DefContract d on v.dck=d.dck
      where 
        v.hitag=@Hitag
        and  v.Locked = 0    -- товар заблокирован на складе
        and sl.Locked = 0    -- заблокированный склад также пропускаем 
        and sl.Discard = 0   -- склад брака пропускаем
        and sl.SafeCust = 0  -- склад ответхранения пропускаем
        and (@flgIgnorInvis=1 or sl.AgInvis = 0 or v.sklad=35)   -- склад невидимый агентами пропускаем, кроме 35
        and sl.Equipment = 0 -- склад оборудования пропускаем
        and (d.ContrTip<>5 or d.dck=44283)    -- товар на ответ. хранении с КПК не продаем, кроме Рестории
        and ((@depid=3 and v.sklad<>37) or (@depid<>3 and v.sklad<>35)) --37 склад не для сетей, 35 - только сети
        and g.PLID=@PLID 
        and f.FirmGroup=@FirmGroup  
        and (@AllSklads=1 or SL.skladNo in (select K from dbo.Str2intarray(@SkladList) ))
        and v.morn-v.sell+v.isprav-v.remov-v.bad-v.rezerv > 0
        --and 100.0*DATEDIFF(day,dbo.today(),v.srokh)/DATEDIFF(day,v.Dater,v.srokh)>=@FreshNessGood   
      group by v.sklad, v.id, v.ncod, v.price, v.cost, v.morn-v.sell+v.isprav-v.remov-v.bad-v.rezerv, v.dater
              ,SL.UpWeight,n.flgWeight,v.[WEIGHT],n.netto, n.nds
      order by v.dater,v.sklad, v.id;
  
      open CurRest;
      fetch next from CurRest into @tekid, @Sklad, @Ncod, @PriceVI, @Cost, @Rest, @AlienReq, @EffWeight, @Netto, @NDS, @flgWeight;
      set @SavedZakaz=0;

      while ((@@FETCH_STATUS=0) and (@QtyZakaz>0))
      begin
        if @AlienReq>0  set @Rest=@Rest-@AlienReq;
        if (@Rest>0)
        begin
         
         --set @DelivGroup = 0
          -- ГРУППА ДОСТАВКИ
         set @DelivGroup = isnull((select g.DelivGr from DelivGroups g 
                                   where (g.Reg_id=@Reg_id or g.Reg_id='')                                   --выбранный регион или все регионы
                                   and   (g.SkladNo=@Sklad or g.SkladNo=0)                           --выбранный склад или любой склад
                                   and   (g.DayOfWeek = DatePart(dw,@TekND) or g.DayOfWeek = 0) --выбранный день или любой день
                                   and   (g.Ngrp in (select k from dbo.Str2intarray(dbo.GetGrParent(@NGRP))) or g.Ngrp=0) --выбранная группа или все группы
                                   and   (g.DepID=@DepID or g.DepID=0)                               --выбранный отдел или все отделы
                                   and   (g.SV_ID=@SV_ID or g.SV_ID=0)),0)                           --выбранный супервайзер или все супервайзеры
        
          -- ЗАПИСЬ ОДНОЙ СТРОКИ В ZAKAZ   
            
          if (@Rest <= @QtyZakaz) set @Tek=@Rest; else set @Tek=@QtyZakaz; -- заказ по одной строке
          set @QtyZakaz=@QtyZakaz-@Tek;
          set @SavedZakaz=@SavedZakaz+@Tek;
          
          if @EffWeight<>0 and @flgWeight<>0
          begin
            set @Price=@PriceVI/@EffWeight;
            set @Cost=@Cost/@EffWeight;
          end  
          else set @EffWeight=@Netto; --isnull((select n.netto from nomen n where n.hitag=@Hitag),0)
                
          if @flgWeight=0 and @Price = 0 set @Price=@PriceVI;
          
          if @Tek > 0 
          begin
            insert into LogZakaz(CompName,Hitag,Tekid,Qty,Sklad,Price,EffWeight,Cost,Nds,DelivGroup, StfNom, StfDate, DocNom, DocDate, DCK, Ag_Id, B_ID, OrdStick) 
            values(@CompName,@Hitag,@Tekid,@Tek,@Sklad,@Price,@EffWeight,@Cost,@Nds,@DelivGroup,  @StfNom, @StfDate, @DocNom, @DocDate, @DCK, @Ag_Id, @B_ID, @OrdStick);

          
            insert into Zakaz(CompName,Hitag,Tekid,Qty,Sklad,Price,EffWeight,Cost,Nds,DelivGroup, StfNom, StfDate, DocNom, DocDate,DCK, Ag_Id, B_ID, OrdStick) 
            values (@CompName,@Hitag,@Tekid,@Tek,@Sklad,Round(@Price,2),@EffWeight,@Cost,@Nds,@DelivGroup, @StfNom, @StfDate, @DocNom, @DocDate, @DCK, @Ag_Id, @B_ID, @OrdStick);
          end
        
        end;
       fetch next from CurRest into @tekid, @Sklad, @Ncod, @PriceVI, @Cost, @Rest, @AlienReq, @EffWeight, @Netto, @NDS, @flgWeight;
      end;

      /*Неудовлетворенный спрос протоколируется*/
      if @QtyZakaz > 0 
      begin
          declare @SkladOpt int, @SkladRozn int, @SkladAccum int, @SkladLock int, @SkladSafeCust int
          
          set @SkladOpt=isnull((select sum(morn-sell+isprav-remov-bad) from tdvi where hitag=@hitag and locked=0 and sklad in (select skladno from skladlist where onlyminp=1 and discard=0 and locked=0 and safecust=0)),0) -
                         ISNULL((select sum(qty) from Zakaz where hitag=@hitag),0)     
          set @SkladRozn=isnull((select sum(morn-sell+isprav-remov-bad) from tdvi where hitag=@hitag and locked=0 and sklad in (select skladno from skladlist where onlyminp=0 
            and discard=0 and locked=0 and safecust=0 and (AgInvis=0 or @flgIgnorInvis=1))),0) -
                         ISNULL((select sum(qty) from Zakaz where hitag=@hitag),0)
          set @SkladAccum=isnull((select sum(morn-sell+isprav-remov-bad) from tdvi where hitag=@hitag and locked=0 and sklad in (select skladno from skladlist where discard=0 and locked=1 and safecust=0)),0) -
                         ISNULL((select sum(qty) from Zakaz where hitag=@hitag),0)
          set @SkladLock=isnull((select sum(morn-sell+isprav-remov-bad) from tdvi where hitag=@hitag and locked=1 and sklad in (select skladno from skladlist where discard=0 and locked=0 and safecust=0)),0) -
                         ISNULL((select sum(qty) from Zakaz where hitag=@hitag),0)                  
          set @SkladSafeCust=isnull((select sum(morn-sell+isprav-remov-bad) from tdvi where hitag=@hitag and locked=0 and sklad in (select skladno from skladlist where safecust=1)),0) -
                         ISNULL((select sum(qty) from Zakaz where hitag=@hitag),0)                                  
         
         insert into  dbo.NotSat(OP,  B_ID, DCK,  Ag_ID,  Ncod,  Hitag,  Sklad,  Qty,  Price,  Cost,  tekid,  ves,  Remark, SkladOpt, SkladRozn, SkladAccum, SkladLock, SkladSafeCust)
         values (1000+@Ag_id,  @B_ID, @DCK,  @Ag_ID,  @Ncod,  @Hitag,  @Sklad,  @QtyZakaz,  @Price,  @Cost,  @tekid,  @EffWeight,  'Нехватка товара MobAgents',@SkladOpt, @SkladRozn, @SkladAccum, @SkladLock, @SkladSafeCust)
      end;
      
      close CurRest;
      deallocate CurRest;  
      select @SavedZakaz
    end
    end
  end --provodnoy
  /*=========================================Предзаказ=======================================================*/
  else 
  if @Tip='neprovodnoy' 
  begin
  
    if @flgWeight=1 
    begin
       if @Netto>0 set @QtyZakaz=Round(1.0*@Qty/@Netto,0) else set @QtyZakaz=1
       set @EffWeight=@Qty
    end   
    else
    begin
      set @QtyZakaz=Round(@Qty,0);
      set @EffWeight =0
    end
  
    insert into 
    dbo.[PreOrder]
    (DCK, Ag_ID, NDOrder,  Hitag,  Qty, [Weight], CorrectQty, CorrectWeight, CommentROP, CommentZakup, RemarkAgent, POStatus) 
    values (@DCK, @Ag_ID, @DocDate,  @Hitag, @QtyZakaz, @EffWeight, 0, 0, '', '', @Remark, 0); 
    
 end
 /*===========================================Переоценка=================================================*/ 
 else 
 if @Tip='reassessment' 
 begin
   if @B_ID = 0 set @B_ID = (select pin from DefContract where dck=@DCK)
    
    if @flgWeight = 1
    set @QtyZakaz = 1
    else
    set @QtyZakaz=Round(@Qty,0);
    
    set @Ngrp = (select n.Ngrp from nomen n where n.hitag=@Hitag);
    set @Ngrp=isnull(dbo.GetGrOnlyParent(@Ngrp),@Ngrp);
    
    
    if (@QtyZakaz = 0 and @Qty<>0) or (@QtyZakaz = 1 and @Qty<0.15 and @Ngrp=85)
    insert into MobAgents.Mess(ag_id,  pin,  dck,  ND,  tm,  Remark,  MessType,  data0) 
    values (@ag_id,  @B_ID,  @dck,  @TekND,  dbo.[time](), iif(@flgWeight=0, cast(@Qty as varchar)+'шт.',cast(@Qty as varchar)+'кг'),  4,  @hitag); 
      
    
    --declare @Rk int, @uin int, @sourcedatnom int, @tovprice numeric(10,2), @Delta int, @reftekid int, @master int
    --declare @ShelfLife int, @tekKol int, @gpName varchar(100), @AgFIO varchar(100), @Otv int, @meta int
    
    set @uin=(select u.uin from usrPWD u where u.P_ID=(select a.p_id from agentlist a where a.ag_id=@Ag_id))
    set @master=(select master from def where pin=@B_ID)
   
    BEGIN TRANSACTION SaveReass;
    
    if exists (select r.Rk from Requests r join ReqReturn t on r.Rk=t.reqnum
               where r.ND>=@TekND and r.Tip2 = 142 and r.Rs = 1 and t.DCK=@DCK and t.Comment=@Remark and r.meta=@meta)
    begin
      set @Rk=(select r.rk from Requests r join ReqReturn t on r.Rk=t.reqnum
               where r.ND>=@TekND and r.Tip2 = 142 and r.Rs = 1 and t.DCK=@DCK and t.Comment=@Remark and r.meta=@meta)
    end
    else
    begin
      
      set @DepID = (select s.DepID from agentlist s where s.ag_id=@Ag_id)   
      
      if @uin is null
      begin
        if @DepID = 1 set @uin = 1
      end  
      
      set @gpName = (select gpName from Def where pin=@B_ID)
      set @AgFIO=(select p.Fio from person p where p.P_ID=(select a.p_id from agentlist a where a.ag_id=@Ag_id))
      
      insert into  dbo.Requests(ND, DepIDCust, DepIDExec, Op, Content, Remark, NeedND, Plata, RemarkExec,  KsOper,  RemarkFin, PlanND, [Status], RealND, 
               RemarkMain, ReqAvail, Nal,  ReqAv,  FactND,  Period,  RemarkMtr,  Rs,  Rf,  [Sent],  SalaryMonth,  PersonnelDepMessage,  [Type],  
               tm,  rql, Bypass,  Itsright,  [Data],  PlataOver,  ByCall,  Otv2,  Tip2,  Data2,  ResFin2,  Prior2,  Locked,  ResFin2ND,  compname, ag_id, meta) 
      values (getdate(), @DepID, @DepIDExec, @uin, 'Возврат товара с точки #'+cast(@B_ID as varchar)+' '+@gpName+'. Договор #'+cast(@DCK as varchar),'Забрать возврат', @TekND, 0,'',NULL,'',@TekND,1,@TekND,'',0,0,0,NULL,0,'',1,0,0,0,'',0,
               dbo.time(),0,0,0,'',0,0, @Otv,142,'Возврат (Инициатор:'+@AgFIO+')',0,0,0,NULL,@CompName, @Ag_ID, @meta)  
     
      set @Rk=SCOPE_IDENTITY() 
        
      insert into dbo.ReqReturn (reqnum,  pin, ret_nd, comment, dck)--, sourcedatnom) 
      values (@Rk, @B_ID, @TekND, @Remark, @DCK)--,0)
    end;  
      
    select @ShelfLife = isnull(ShelfLife,0) from Nomen where hitag=@hitag

    declare SelectGood cursor fast_forward local
    for select v.datnom, iif(i.weight<>0,v.price/i.weight,v.price) as price, v.kol - v.kol_b as kol, iif(DateDiff(DAY,@TekND - @ShelfLife,c.nd)<0,-3,1)*DateDiff(DAY,@TekND - @ShelfLife,c.nd) as Delta, v.sklad, i.weight-isnull(j.weight_b,0), v.tekid
    from nv v join visual i on v.tekid=i.id
              join nc c on v.datnom=c.datnom
              left join (select nj.refdatnom, nj.reftekid, sum(nj.weight) as weight_b from nv_join nj group by nj.refdatnom, nj.reftekid) j
              on v.datnom=j.refdatnom and v.tekid=j.reftekid
               
    where c.dck=@dck and v.hitag=@hitag and v.kol-v.kol_b>0 
          and c.nd>=DATEADD(DAY,-200, @TekND) and c.actn=0 
          
    order by Delta,price;    
    
    if @Qty = 0 
    begin
      insert into dbo.ReqReturnDet(reqretid, hitag, kol, fact_weight, ret_reason, sourcedatnom, tovprice, sklad, reftekid)  
      values(@Rk, @Hitag, 0, 0, 1, 0, @price, 0, 0)
    end    
      
    open SelectGood
    fetch next from SelectGood
    into @sourcedatnom, @tovprice, @tekKol, @Delta, @sklad, @EffWeight, @reftekid
    
    set @Done = 0
           
    while (@@FETCH_STATUS = 0) and ((@QtyZakaz > 0 and @flgWeight = 0) or (@Qty > 0 and @flgWeight = 1))
    begin
    
      if @flgWeight = 0
      begin  
        if @QtyZakaz < @tekKol set @tekKol=@QtyZakaz 
        set @QtyZakaz = @QtyZakaz - @tekKol
        set @EffWeight = 0
        
        insert into dbo.ReqReturnDet(reqretid, hitag, kol, fact_weight, ret_reason, sourcedatnom, tovprice, sklad, reftekid)  
        values(@Rk, @Hitag, @tekKol, @EffWeight, 1, @sourcedatnom, @tovprice, @sklad, @reftekid)
        set @Done = 1
      end  
      else
      if @EffWeight > 0
      begin
        if @Qty < @EffWeight set @EffWeight = @Qty 
        set @Qty = @Qty - @EffWeight
        set @tekKol = 1
        set @tovprice = round(@tovprice*@EffWeight,2)
        
        insert into dbo.ReqReturnDet(reqretid, hitag, kol, fact_weight, ret_reason, sourcedatnom, tovprice, sklad, reftekid)  
        values(@Rk, @Hitag, @tekKol, @EffWeight, 1, @sourcedatnom, @tovprice, @sklad, @reftekid)
        
        set @Done = 1
      end  
      
      fetch next from SelectGood
      into @sourcedatnom, @tovprice, @tekKol, @Delta, @sklad, @EffWeight, @reftekid
      
    end
    
    close SelectGood;
    deallocate SelectGood;
    
    if @Done=1 COMMIT TRANSACTION SaveReass;
    else       ROLLBACK TRANSACTION SaveReass;
      
    /*if (@QtyZakaz > 0 and @flgWeight = 0) or (@Qty > 0 and @flgWeight = 1)
    insert into MobAgents.Mess(ag_id,  pin,  dck,  ND,  tm,  Remark,  MessType,  data0) 
    values (@ag_id,  @B_ID,  @dck,  @TekND,  dbo.[time](), iif(@flgWeight=0, cast(@QtyZakaz as varchar)+'шт.',cast(@Qty as varchar)+'кг'),  3,  @hitag); 
    */
 end
 /*=======================================================================================================*/ 
 
 

end;