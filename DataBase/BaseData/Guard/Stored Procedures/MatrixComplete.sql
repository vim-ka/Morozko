CREATE procedure Guard.MatrixComplete @day0 datetime, @day1 datetime,
  @DepId int, @Sv_ID int, @Ag_id int, @MLID int, @BuyersList varchar(3000)=''
-- Если список покупателей не задавать, то процедура выдернет всех покупателей, 
-- относящихся к заданному отделу, супервайзеру, агенту и номеру матрицы
as
declare @Day01 datetime, @CMD varchar(8000), @pin int, @nd datetime, @ss1 varchar(10), @ss2 varchar(10)
BEGIN

  -- Заполняем пропущенные коды покупателей в сверках:
  update rests set pin=dc.pin
  from rests inner join defcontract dc on dc.dck=rests.DCK
  where rests.pin is NULL;

  -- Список покупателей задан?
  create table #br(b_id int);
  if isnull(@BuyersList,'')=''  -- Если нет, придется заполнить самому
    insert into #br 
    select distinct pin from planvisit2 where mlid=@mlid and ag_id=@ag_id
  else
    insert into #br select k from dbo.Str2intarray(@BuyersList);

  -- Какие именно товары попали в матрицу номер @MLID?
  create table #t(hitag int); -- 
  insert into #t SELECT DISTINCT HITAG FROM guard.MatrixLDet WHERE MLID=@MLID;

  -- В какие дни вообще были сверки по заданному списку покупателей?
  create table #d(NeedDay datetime);
  insert into #d select distinct needday from rests r inner join #br on r.pin=#br.B_ID 
  where r.Needday between @day0 and @day1
  order BY NEEDDAY;

  create table #m(hitag int, pin int, ND datetime, Rest int default 0); -- Пока продажи игнорируем! Sell int default 0, SellKG decimal(10,3) default 0, SellSP decimal(10,2) default 0);
  insert into #m(pin, hitag, ND)
  select distinct #br.b_id, #t.hitag, #d.NeedDay
  from #br, #t, #d;  
  
  -- Результаты сверок по покупателям, с разбивкой по дням:
  create table #sv (pin int, ND datetime, Hitag int, Qty int);
  insert into #sv
    select r.pin, r.needday, r.hitag, sum(r.qty) as Qty
    from Rests R
    inner join #br on #br.b_id=r.pin
    inner join #t on #t.hitag=r.hitag
    where r.needday between @day0 and @day1
    group by r.pin, r.needday, r.hitag;

  update #m set Rest=#sv.qty
  FROM
    #m 
    inner join #sv on #sv.Hitag=#m.hitag and #sv.pin=#m.pin and #sv.Nd=#m.ND;

  set @CMD='';

  declare c1 cursor FAST_FORWARD for 
    select #br.b_id,#d.NeedDay 
    from 
      #br,#d 
    order by #br.b_id, #d.NeedDay

  open c1;
  fetch next FROM c1 into @pin,@ND;
  
  while @@fetch_status=0 begin
    if exists(select * from PlanVisit2 pv where pv.ag_id=@Ag_id and pv.pin=@pin and DATEPART(weekday,@ND)=pv.dn) 
    begin
      set @ss1=CONVERT(varchar(10), @nd,112);
      set @ss2=convert(varchar,@pin);
      if @cmd='' SET @CMD=@CMD+'sum(iif(nd='''+@ss1+''' and pin='+@ss2+',rest,0)) as q'+@ss2+'_'+@ss1+char(13)+char(10)
      else set @cmd=@cmd+','+'sum(iif(nd='''+@ss1+''' and pin='+@ss2+',rest,0)) as q'+@ss2+'_'+@ss1+char(13)+char(10)
    end;
    fetch next FROM c1 into @pin,@ND;
  end;
  
  close c1;
  DEALLOCATE c1;
set @cmd='select #m.hitag, nm.name, '+@cmd+'from #m inner join nomen nm on nm.hitag=#m.hitag group by #m.hitag, nm.name order by nm.name'
print(@cmd);
exec(@cmd);



/*
  create table #m(pin int, hitag int, NeedDay datetime, Sell int default 0, SellKG decimal(10,3) default 0, SellSP decimal(10,2) default 0, Rest int default 0);
  insert into #m(pin, hitag)
  select distinct #br.b_id, #t.hitag
  from #br, #t;  

  -- Считаем все продажи по заданным точкам за период:
  create table #s(pin int, hitag int, Sell int default 0, SellKG decimal(10,3) default 0, SellSP decimal(10,2) default 0);

  if @Day1>=dbo.today()
    set @day01=dateadd(DAY,-1,dbo.today())
  else set @Day01=@day1;


  -- продажи прошлых дней:
  insert into #s 
    select nc.B_ID, nv.hitag, sum(nv.kol-nv.kol_b) as Sell,
      sum((nv.kol-nv.kol_b)*iif(vi.weight=0, nm.netto, vi.weight)) as SellKG,
      sum((nv.kol-nv.kol_b)*nv.price*(1.0+nc.extra/100)) as SellSP
    FROM
      NC 
      inner join #br on #br.b_id=nc.B_ID
      inner join nv on nv.datnom=nc.datnom
      inner join visual vi on vi.id=nv.tekid
      inner join Nomen nm on nm.hitag=nv.hitag
      inner join #t on #t.hitag=nv.Hitag
    where nc.nd between @day0 and @day01
    group BY nc.B_ID, nv.hitag;
  -- продажи сегодня:
  if @day1>=dbo.today()
    insert into #s 
    select nc.B_ID, nv.hitag, sum(nv.kol-nv.kol_b) as Sell,
      sum((nv.kol-nv.kol_b)*iif(vi.weight=0, nm.netto, vi.weight)) as SellKG,
      sum((nv.kol-nv.kol_b)*nv.price*(1.0+nc.extra/100)) as SellSP
    FROM
      NC 
      inner join #br on #br.b_id=nc.B_ID
      inner join nv on nv.datnom=nc.datnom
      inner join tdvi vi on vi.id=nv.tekid
      inner join Nomen nm on nm.hitag=nv.hitag
      inner join #t on #t.hitag=nv.Hitag
    where nc.nd=dbo.today()
    group BY nc.B_ID, nv.hitag;

  update #m set Sell=e.sell, SellKG=e.SellKG, SellSP=e.SellSP
  from #m inner join (select pin,hitag,sum(sell) sell, sum(SellSP) SellSP, sum(SellKG) SellKG from #s group by pin,hitag) E
    on E.pin=#m.pin and E.Hitag=#m.Hitag;
*/

--  update #m set Rest=(select round(sum(r.qty),0) from rests r where r.pin=#m.pin and r.hitag=#m.hitag and r.NeedDay between @day0 and @day1);

  /*
  select #m.*, r.nee def.gpname, nm.name 
  from 
    #m 
    inner join nomen nm on nm.hitag=#m.hitag
    inner join def on def.pin=#m.pin
  order by #m.pin, nm.name;
*/
END