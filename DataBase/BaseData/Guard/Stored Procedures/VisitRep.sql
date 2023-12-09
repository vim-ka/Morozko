create procedure Guard.VisitRep @vrMode smallint, -- 0-отдел, 1-супервайзер, 2-агент
  @Code int, -- кол отдела, или супервайзера, или агента
  @day0 datetime, @day1 datetime -- период
as
declare @b_Id int, @Dow int, @SelCount int, @ag_id int, @sv_id int, @PayCount int;
BEGIN
  create table #t(DepID int, Sv_ID int, Ag_ID int, B_ID int,
    S1 smallint default 0, R1 smallint default 0, -- продажи и выплаты за понедельник
    S2 smallint default 0, R2 smallint default 0, -- продажи и выплаты за вт
    S3 smallint default 0, R3 smallint default 0, -- продажи и выплаты за ср
    S4 smallint default 0, R4 smallint default 0, -- продажи и выплаты за чт
    S5 smallint default 0, R5 smallint default 0, -- продажи и выплаты за пт
    S6 smallint default 0, R6 smallint default 0, -- продажи и выплаты за сб
    S7 smallint default 0, R7 smallint default 0) -- продажи и выплаты за вс

  /***********************************************************************************
   *     Отчет по выбранному агенту                                                  *
   ***********************************************************************************/
  if @vrMode=2 BEGIN -- для одного агента, сначала продажи:
    declare C1 cursor fast_forward read_only local for
    select 
       nc.b_id, 
       Datepart(dw, nc.nd) as Dow, count(distinct nc.nd) as SelCount
     from 
       nc
     where
       nc.nd between @day0 and @day1
       and nc.ag_id=@code
       and nc.Actn=0
       and nc.SP>0
    group by nc.b_id, Datepart(dw, nc.nd)
    order by nc.b_id;

    Open C1;
    FETCH next from C1 into @b_Id, @Dow, @SelCount
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
      if not exists(select * from #t where b_id=@b_id) insert into #t(ag_id,b_id) values(@code,@b_id);

      if @dow=1 update #t set s1=s1+@SelCount where b_id=@b_id;
      else if @dow=2 update #t set s2=s2+@SelCount where b_id=@b_id;
      else if @dow=3 update #t set s3=s3+@SelCount where b_id=@b_id;
      else if @dow=4 update #t set s4=s4+@SelCount where b_id=@b_id;
      else if @dow=5 update #t set s5=s5+@SelCount where b_id=@b_id;
      else if @dow=6 update #t set s6=s6+@SelCount where b_id=@b_id;
      else if @dow=7 update #t set s7=s7+@SelCount where b_id=@b_id;

      FETCH next from C1 into @b_Id, @Dow, @SelCount;
    end;
    close C1;
    deallocate C1;

    -- теперь по этому же агенту выплаты от покупателей за период:
    declare C2 cursor fast_forward read_only local for
    select 
      k.b_id, DATEPART(WEEKDAY,k.nd) as Dow, count(distinct k.nd) as PayCount
    from 
      kassa1 k
    where 
      k.nd between @day0 and @day1
      and k.oper=-2 and k.act='ВЫ' and k.plata>0
      and k.remark like 'ч/з агента '+cast(@code as varchar)+' %'
    group by k.b_id, DATEPART(WEEKDAY,k.nd);

    Open C2;
    FETCH next from C2 into @b_Id, @Dow, @PayCount
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
      if not exists(select * from #t where b_id=@b_id) insert into #t(ag_id,b_id) values(@code,@b_id);

      if @dow=1 update #t set r1=r1+@Paycount where b_id=@b_id;
      else if @dow=2 update #t set r2=r2+@Paycount where b_id=@b_id;
      else if @dow=3 update #t set r3=r3+@Paycount where b_id=@b_id;
      else if @dow=4 update #t set r4=r4+@Paycount where b_id=@b_id;
      else if @dow=5 update #t set r5=r5+@Paycount where b_id=@b_id;
      else if @dow=6 update #t set r6=r6+@Paycount where b_id=@b_id;
      else if @dow=7 update #t set r7=r7+@Paycount where b_id=@b_id;

      FETCH next from C2 into @b_Id, @Dow, @PayCount
    end;
    close C2;
    deallocate C2;

  end;  


  /***********************************************************************************
   *     Отчет по выбранному отделу                                                  *
   ***********************************************************************************/
  else if @vrMode=0 BEGIN -- для одного отдела
    declare C1 cursor fast_forward read_only local for
    select 
       a.sv_ag_id, nc.ag_id, Datepart(dw, nc.nd) as Dow, nc.b_id, 
       count(distinct nc.nd) as SelCount
     from 
       nc
       inner join agentlist A on A.ag_id=nc.ag_id
     where
       nc.nd between @day0 and @day1
       and a.depId=@code
       and nc.Actn=0
       and nc.SP>0
    group by nc.ag_id, a.sv_ag_id, Datepart(dw, nc.nd), nc.b_id
    order by a.sv_ag_id, nc.ag_id;

    Open C1;
    FETCH next from C1 into @sv_id, @ag_id,  @Dow, @b_id, @SelCount
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
      if not exists(select * from #t where sv_id=@sv_id and ag_id=@ag_id) insert into #t(DepId,sv_id,ag_id) values(@Code,@sv_id,@ag_id);

      if @dow=1 update #t set s1=s1+@SelCount where sv_id=@sv_id and ag_id=@ag_id;
      else if @dow=2 update #t set s2=s2+@SelCount where sv_id=@sv_id and ag_id=@ag_id;
      else if @dow=3 update #t set s3=s3+@SelCount where sv_id=@sv_id and ag_id=@ag_id;
      else if @dow=4 update #t set s4=s4+@SelCount where sv_id=@sv_id and ag_id=@ag_id;
      else if @dow=5 update #t set s5=s5+@SelCount where sv_id=@sv_id and ag_id=@ag_id;
      else if @dow=6 update #t set s6=s6+@SelCount where sv_id=@sv_id and ag_id=@ag_id;
      else if @dow=7 update #t set s7=s7+@SelCount where sv_id=@sv_id and ag_id=@ag_id;

      FETCH next from C1 into @sv_id, @ag_id,  @Dow, @b_id, @SelCount
    END;
    close C1;
    deallocate C1;

    -- Теперь то же, но по выплатам покупателей:
    declare C2 cursor fast_forward read_only local for
    select 
      a.sv_ag_id,  DATEPART(WEEKDAY,k.nd) as Dow, guard.stoi(substring(k.remark,12,10)) as AG_ID, k.b_id,
      count(distinct k.nd) as PayCount
    from 
      kassa1 k
      inner join AgentList A on A.ag_id=guard.stoi(substring(k.remark,12,10))
    where 
      k.nd between @day0 and @day1
      and k.oper=-2 and k.act='ВЫ' and k.plata>0
      and k.remark like 'ч/з агента %'
      and A.depid=@code
      and k.Plata>0
    group by a.sv_ag_id,  DATEPART(WEEKDAY,k.nd), guard.stoi(substring(k.remark,12,10)), k.b_id

    Open C2;
    FETCH next from C2 into @sv_id, @Dow, @ag_id, @b_id, @PayCount
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
      if not exists(select * from #t where sv_id=@sv_id and ag_id=@ag_id) insert into #t(DepId,sv_id,ag_id) values(@Code,@sv_id,@ag_id);

      if @dow=1 update #t set r1=r1+@PayCount where sv_id=@sv_id and ag_id=@ag_id;
      else if @dow=2 update #t set r2=r2+@PayCount where sv_id=@sv_id and ag_id=@ag_id;
      else if @dow=3 update #t set r3=r3+@PayCount where sv_id=@sv_id and ag_id=@ag_id;
      else if @dow=4 update #t set r4=r4+@PayCount where sv_id=@sv_id and ag_id=@ag_id;
      else if @dow=5 update #t set r5=r5+@PayCount where sv_id=@sv_id and ag_id=@ag_id;
      else if @dow=6 update #t set r6=r6+@PayCount where sv_id=@sv_id and ag_id=@ag_id;
      else if @dow=7 update #t set r7=r7+@PayCount where sv_id=@sv_id and ag_id=@ag_id;

      FETCH next from C2 into @sv_id, @Dow, @ag_id, @b_id, @PayCount
    END;
    close C2;
    deallocate C2;




  end;





  select #t.*, Pa.Fio as AgFam, def.gpname, PS.Fio as SuperFam
  from 
    #t 
    left join def on def.pin=#t.b_id
    left join AgentList A on A.ag_id=#t.Ag_ID
    left join Person PA on PA.P_ID=A.P_ID
    left join AgentList SV on SV.ag_id=#t.sv_ID
    left join Person PS on PS.P_ID=SV.P_ID
  order by 
    #t.sv_id, #t.Ag_ID, #t.B_ID
end;