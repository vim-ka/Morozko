CREATE procedure dbo.ClearNotDoneNC
as
declare @Datnom int, @B_ID int, @BrName varchar(100), @Op smallint,
  @SP money, @SC money, @Extra decimal(6,2), @Srok smallint,
  @Our_ID smallint, @Dck int, @Mode int, @NCID int, @Nnak int,
  @tekId int, @Price money,@Cost money,@Sklad smallint,@Kol int,
  @Hitag int, @today datetime
begin
  set @today=dbo.today()

  -- Для начала проставляем флаг DONE в накладных, где он точно должен быть, а нету:
  create table #d(datnom int, b_id int, fam varchar(35),ag_id int, master int, 
    sp decimal(12,2), AddSP decimal(12,2), DepID int, 
    Worker Bit default 0, flgExclude bit default 0, Done bit default 0);
    
  insert into #d(DatNom,b_id,fam,ag_id, sp, master)  
    select NC.DatNom,NC.b_id,NC.fam,NC.ag_id,NC.sp, IIF(Def.Master=0,Def.pin,Def.Master)
    from NC left join Def on Def.pin=nc.b_id
    where nd=@today and done=0;

  update #d set depid=(select depid from Agentlist where ag_id=#d.ag_id)
  update #d set AddSP=(select isnull(sum(zakaz*price),0) from nvzakaz where datnom=#d.Datnom and Done=0);
  update #d set Worker=(select Worker from Def where pin=#d.b_id);
  update #d set flgExclude=1 where Master=1 and exists(select * from DefExclude where ExcludeType=1 and Pin=#d.Master)
  -- update #d set done=1 where sp+addsp>1500 or flgExclude=1 or DepID=3 or DepID=43 or Worker=1;
  update #d set done=1 where sp+addsp>=0 or flgExclude=1 or DepID=3 or DepID=43 or Worker=1;
  update nc set Done=1 where nd=@today and datnom in (select datnom from #d where Done=1);

  drop table #d;

  -- Теперь основной блок:
  begin transaction Main;  
    create table #t (tekid int, zakaz int);

    insert into #t 
      select nv.tekid, sum(nv.kol) as zakaz 
      from 
        nv inner join nc on nc.datnom=nv.datnom
      where nc.nd=@today and nc.done=0
      group by nv.tekid;

    update tdvi set sell=Sell-(select zakaz from #t where #t.tekid=tdVi.id)
    where id in (select tekid from #t);  
      
    -- update nc set sp=0, sc=0 where nd=@today and done=0;
    
    declare C1 cursor fast_forward for 
      select DatNom,B_ID,Fam as BrName, OP,SP,SC, Extra,Srok,OurID,DCK
      from nc where nd=@today and done=0 and stip<>4;
    open c1;
    
    fetch next from C1 into @Datnom,@B_ID,@BrName,@Op,@SP,@SC,@Extra,@Srok,@Our_Id,@DCK;
    WHILE @@FETCH_STATUS = 0 BEGIN    
      -- Аргументы SaveNcEdit, чтобы не ошибиться:  
      --  @Nnak int, @DatNom int,
      --  @B_ID int, @BrName varchar(100), @Op smallint, @SP money, @SC money,
      --  @NewSP money, @NewSc money, @Mode int, @Extra NUMERIC(6,2),
      --  @Srok smallint, @NalogExst bit, @Nalog money, @Our_Id tinyint,
      --  @NCID int out, @DCK int=0, @NewDCK int=0
      set @Nnak = @datnom % 10000;
      set @NCID=0
      exec SaveNcEdit 
        @Nnak, @DatNom,
        @B_ID, @BrName, 0, @SP, @SC,
        0, 0, @Mode, @Extra,
        @Srok, 0, 0.0, @Our_Id,
        @NCID, @DCK, @DCK;
      
      print 'Возвращено значение @NCID = '+cast(@ncid as varchar)
      if @ncid=0 begin
        set @ncid=(select max(ncid) from ncedit where op=0);
        print '  Новое значение @NCID = '+cast(@ncid as varchar)
      end;
      
      declare C2 cursor fast_forward for
        select tekid,hitag,price,cost,Kol,sklad from nv where datnom=@datnom and kol>0;
      open c2;
      fetch next from c2 into @tekid,@hitag,@price,@cost,@Kol,@sklad;
      while @@FETCH_STATUS=0 begin  
        -- Аргументы SaveNvEdit, чтобы не ошибиться:
        -- @Ncid int, @Nnak int, @Datnom int, @ID int, @Hitag int,
        -- @Price money, @Cost money, @Nalog5 tinyint, @Kol int, @NewKol int, @SkladNo tinyint,
        -- @NewPrice money=null, @AddOp INT=null      
        if isnull(@ncid,0)>0
          exec SaveNvEdit @NcId, @nnak,@Datnom,@tekId,@hitag,
             @price,@Cost,0,@kol,0,@sklad,@price,0;
        fetch next from c2 into @tekid,@hitag,@price,@cost,@Kol,@sklad;
      end;      
      close C2;
      deallocate C2;
        
      fetch next from C1 into @Datnom,@B_ID,@BrName,@Op,@SP,@SC,@Extra,@Srok,@Our_Id,@DCK;
    end;
    
    close C1;
    deallocate C1;
    
    update nv set nv.kol=0, nv.Kol_B=0 where datnom in (select datnom from nc where nd=@today and done=0 and stip<>4);
    update nc set SC=0,SP=0 where nd=@today and done=0 and stip<>4;
    
    update nvzakaz set nvzakaz.done=1,
      comp=comp+'@Cancel',tmend=dbo.time(), curWeight=0, dtEnd=@today, Remark='сумма заявки ниже порога'
      where datnom in (select datnom from nc where nd=@today and done=0 and stip<>4) and zakaz>0;
      
      
    DELETE FROM NearLogistic.MarshRequests 
    WHERE reqid in (select datnom from nc where nd=@today and done=0 and stip<>4);

  if @@ERROR=0 Commit; else Rollback;  
end;