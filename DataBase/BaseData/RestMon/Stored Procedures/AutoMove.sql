CREATE procedure RestMon.AutoMove
as

declare @t_id int, @hitag int, @id int, @SourSklad int, @SourRest int,
    @DestSklad int, @ForMove int, @GetPart int, @prev_t_id int,
    @Moved int, @N int, @MoveNow int, @Comp varchar(30), @NewID int,
    @SerialNom int, @kolError int, @ErrCode int

begin
  set @Comp=HOST_NAME();
  set @ErrCode=0;
  set @kolError=0;
  set @SerialNom=0;

 -- BEGIN TRANSACTION AutoMoveTran;
  -- Задание на перемещение:
  create table #j(t_id int not null identity(1,1) primary key,
    tip smallint, hitag int, 
    SourSklad int, SourRest int, SourRestW decimal(10,3), -- что есть на складе-источнике
    DestSklad int, AlreadyRest int, AlreadyRestW decimal(10,3), -- что есть на складе-получателе
    MinDestRest int, GetPart int  -- требуемый мин. остаток на складе-получателе и размер перемещаемой порции 
    )

  -- Требуемые перемещения по срабатыванию нижнего порога остатка, если список кодов товаров задан:
  insert into #j(tip, hitag, SourSklad, SourRest, SourRestW, 
    DestSklad, MinDestRest, GetPart,AlreadyRest, AlreadyRestW)
  select
    j.tip, j.hitag, j.SourSklad, 
    sum(iif(v.locked=1,0, v.morn-v.sell+v.isprav-v.remov)) as SourRest,
    sum(iif(v.locked=1,0,1)*(v.morn-v.sell+v.isprav-v.remov)*iif(v.weight>0,v.weight,nm.netto)) as SourRestW,
    j.sklad, j.minRest, isnull(j.GetPart,0) GetPart, 0, 0
  from
    restmon.rm_Job j
    left join tdvi v on v.hitag=j.hitag and v.sklad=j.soursklad and v.locked=0
    inner join nomen nm on nm.hitag=j.hitag
  where 
    j.tip=1 and isnull(j.ncod,0)=0 and isnull(j.hitag,0)<>0
    and v.locked=0
  group by 
    j.tip, j.hitag, j.SourSklad, j.sklad, j.minRest, isnull(j.GetPart,0);
  
  update #J set AlreadyRest=E.Rest, AlreadyRestW=E.RestW
  from #j inner join (
    select v.hitag, v.sklad,
    sum(v.morn-v.sell+v.isprav-v.remov) as Rest,
    sum((v.morn-v.sell+v.isprav-v.remov)*iif(v.weight>0,v.weight,nm.netto)) as RestW
    from tdvi v inner join nomen nm on nm.hitag=v.hitag 
    where v.locked=0
    group by v.hitag,v.sklad
  ) E on E.Hitag=#j.hitag and E.sklad=#j.DestSklad

  -- Требуемые перемещения по истечению заданной части срока годности:
  insert into #j(tip,hitag, SourSklad, SourRest, SourRestW, 
    DestSklad, MinDestRest, GetPart,AlreadyRest, AlreadyRestW)
  select
    j.tip, v.hitag, j.SourSklad, 
    sum(iif(v.locked=1,0, v.morn-v.sell+v.isprav-v.remov)) as SourRest,
    sum(iif(v.locked=1,0,1)*(v.morn-v.sell+v.isprav-v.remov)*iif(v.weight>0,v.weight,nm.netto)) as SourRestW,
    j.sklad, 0, 0, 0, 0
  from
    restmon.rm_Job j
    inner join tdvi v on 
      v.sklad=j.soursklad and (isnull(j.hitag,0)=0 or v.hitag=j.hitag)
      and (isnull(j.ncod,0)=0 or isnull(j.ncod,0)=v.ncod)
    inner join nomen nm on nm.hitag=v.hitag
  where 
    j.tip=3 
    and v.locked=0
    and v.dater is not null and v.srokh is not null 
    and 1.0*DATEDIFF(day, v.dater, dbo.today()) / DATEDIFF(day, v.dater, v.srokh) >=j.MinRest*0.01
  group by 
    j.tip, v.hitag, j.SourSklad, j.sklad, j.minRest, isnull(j.GetPart,0);

  delete from #j where SourRest<0 or SourSklad=DestSklad;

--  select #j.t_id, t.tipname, #j.*, nm.name,nm.flgWeight
--  from 
--    #j 
--    inner join nomen nm on nm.hitag=#j.hitag 
--    inner join restmon.rm_tips t on t.tip=#j.tip
--  order by #j.t_id;
  

  -- Перемещение заданного количества:
--  select #j.t_id, #j.hitag, v.id, 
--    #j.SourSklad, v.morn-v.sell+v.isprav-v.remov as SourRest,
--    #j.DestSklad, #j.AlreadyRest-#j.MinDestRest as ForMove, #j.GetPart
--    from 
--      #j 
--      inner join tdvi v on v.sklad=#j.SourSklad and v.hitag=#j.hitag
--    where 
--      #j.tip=1 
--      and v.morn-v.sell+v.isprav-v.remov>0 
--      and v.LOCKED=0
--      and #j.AlreadyRest-#j.MinDestRest>0
--    order by #j.t_id


  /**********************************************************************
  **        Перемещение по событию "Нехватка до мин.остатка":          **
  **********************************************************************/
  /*
  DECLARE c1 CURSOR FAST_FORWARD FOR
  select top 1
    #j.t_id, #j.hitag, v.id, 
    #j.SourSklad, v.morn-v.sell+v.isprav-v.remov as SourRest,
    #j.DestSklad, #j.AlreadyRest-#j.MinDestRest as ForMove, #j.GetPart
    from 
      #j 
      inner join tdvi v on v.sklad=#j.SourSklad and v.hitag=#j.hitag
    where 
      #j.tip=1 
      and v.morn-v.sell+v.isprav-v.remov>0 
      and v.LOCKED=0
      and #j.AlreadyRest-#j.MinDestRest>0
      -- and #j.t_id>=21
    order by #j.t_id;

  set @SerialNom=0
  open c1;
  fetch next from c1 into @t_id, @hitag, @id, @SourSklad, @SourRest, @DestSklad, @ForMove, @GetPart
  while @@fetch_status = 0 begin
    set @prev_t_id = @t_id
    set @Moved=0
    set @N=@forMove
    print('T_ID = '+cast(@T_ID as varchar)+', требуется переместить '+cast(@N as varchar))
    while @@fetch_status = 0 and @prev_t_id = @t_id begin
      if @forMove<=@GetPart set @MoveNow = @GetPart else set @MoveNow=@forMove-(@forMove % @getpart);
      if @MoveNow>@SourRest set @MoveNow=@SourRest;
      if @N<=0 set @MoveNow=0;
      if @MoveNow>0 begin
        print(' - Из текущей строки @ID='+cast(@id as varchar)+', остаток='+cast(@SourRest as varchar)+' перемещаем '+cast(@MoveNow as varchar)+' шт.')
        set @NewID=0 
        set @kolError=0

        exec dbo.ProcessSklad -- кучу параметров можно передавать как 0, они вычислятся внутри.
          'Скла', @ID, 0, @DestSklad,       --  @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint
          0.0, 0.0, @MoveNow, 0, @Comp,     -- @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, @Op int, @Comp varchar(30)
          0, 0, 0,                          -- @irId int, @ServiceFlag bit=0, @DivFlag bit=0
          0, 0,-- @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran"
          0,                                --  @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
          'Автоперемещение из RestMonitor', @Newid, -- @remark varchar(40), @Newid int=0 out
          @SerialNom,                       -- Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
          @kolError, 0, 0,                  -- @kolError int out, @Dck INT=0, @Junk int=0
          0 -- @NewWEIGHT decimal(12, 3)=0  -- это входной параметр для операций "Tran" и "ИспВ"

        if @kolError<>0 set @ErrCode=1;


        set @Moved=@Moved+@MoveNow;
        set @N=@N-@MoveNow;
      end;
      else
        print(' - Из текущей строки @ID='+cast(@id as varchar)+', остаток='+cast(@SourRest as varchar)+' уже ничего не перемещаем.')
      fetch next from c1 into @t_id, @hitag, @id, @SourSklad, @SourRest, @DestSklad, @ForMove, @GetPart
    end;
  end;
  close c1;
  deallocate c1;
*/
  --  TODO:
  --  блокировка по событию "Нехватка до мин.остатка":





  
  /**********************************************************************************
  **     Перемещение по событию "Обнаружен остаток на контролируемом складе"       **
  **********************************************************************************/

  select top 3
    #j.t_id, #j.hitag, v.id, #j.SourSklad, #j.DestSklad,
    v.morn-v.sell+v.isprav-v.remov as SourRest
  from 
    #j 
    inner join tdvi v on v.sklad=#j.SourSklad and v.hitag=#j.hitag
  where 
    #j.tip=3
    and v.morn-v.sell+v.isprav-v.remov>0
    and v.locked=0
  order by #j.t_id, #j.hitag

  DECLARE c3 CURSOR FAST_FORWARD FOR
  select top 1
    #j.t_id, #j.hitag, v.id, #j.SourSklad, #j.DestSklad,
    v.morn-v.sell+v.isprav-v.remov as SourRest
  from 
    #j 
    inner join tdvi v on v.sklad=#j.SourSklad and v.hitag=#j.hitag
  where 
    #j.tip=3
    and v.morn-v.sell+v.isprav-v.remov>0
    and v.locked=0
  order by #j.t_id, #j.hitag
  
  open c3;
  fetch next from c3 into @t_id, @hitag, @ID, @SourSklad, @DestSklad, @SourRest;
  while @@fetch_status=0 begin
    print('Перемещение '+cast(@SourSklad as varchar)+' ==> '+cast(@DestSklad as varchar)
      +',  Hitag='+cast(@Hitag as varchar)
      +',  ID='+cast(@ID as varchar)
      +'  '+cast(@SourRest as varchar)+' шт.')

    set @kolError=0;
    set @Newid=0;/*
    exec dbo.ProcessSklad -- кучу параметров можно передавать как 0, они вычислятся внутри.
      'Скла', @ID, 0, @DestSklad,       --  @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint
      0.0, 0.0, @SourRest, 0, @Comp,    --  @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, @Op int, @Comp varchar(30)
      0, 0, 0,                          --  @irId int, @ServiceFlag bit=0, @DivFlag bit=0
      0, 0,                             --  @TransmDec int=0, @TransmAdd int=0, эти два параметра - только для операции "Tran"
      0,                                --  @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
      'Автоперемещение из RestMonitor', --  @remark varchar(40)
      @Newid,                           --  @Newid int=0 out
      @SerialNom,                       --  Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
      @kolError, 0, 0,                  --  @kolError int out, @Dck INT=0, @Junk int=0
      0 -- @NewWEIGHT decimal(12, 3)=0  --  это входной параметр для операций "Tran" и "ИспВ"
     */ 
      
    EXEC [dbo].[ProcessSklad]  
          'Скла', @ID, 0, @DestSklad, 0.0, 
          0.0, @SourRest, 0, @Comp, 0, 0,
          0, 0, 0, 0,
          'Автоперемещение из RestMonitor', @Newid,
          @SerialNom, @kolError, 0, 0, 0;  

    print('После выполнения ProcessSklad новая строка NewId='+cast(@NewId as varchar)+' '+cast(@KolError as varchar))

    if @kolError<>0 set @ErrCode=4;
    fetch next from c3 into @t_id, @hitag, @ID, @SourSklad, @DestSklad, @SourRest;
  end;
  close c3;
  deallocate c3;

  print('ErrCode='+cast(@ErrCode as varchar))
  --if @ErrCode=0 COMMIT TRANSACTION AutoMoveTran else ROLLBACK TRANSACTION AutoMoveTran;
end;