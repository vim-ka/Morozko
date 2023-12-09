create procedure ReadOneDayNC @nd datetime
as
declare @n0 int, @n1 int, @Datnom int, @b_id int
declare @today datetime
declare @fam varchar(100)

begin
  set @n0=dbo.indatnom(1, @nd)
  set @n1=dbo.indatnom(9999, @nd)
  set @today=dateadd(dd, datediff(dd, 0, getdate())+0, 0)
  
  -- Сначала список перемещеннх накладных:
  create table #p(datnom int, b_id int, fam varchar(100), tm varchar(8), Op int, Sp decimal(12,2), Sc decimal(12,2),
    Extra decimal(6,2), Srok int, Fact decimal(6,2), OurID int, Pko bit, Man_id int,
    BankID smallint, Tovchk bit, Frizer bit, Ag_ID int, StfNom varchar(6), StfDate datetime,
    QtyFriz int, Remark varchar(50), Printed tinyint, Marsh int, BoxQty decimal(8,2), Weight decimal(8,2),
    Actn bit, CK tinyint, Tara tinyint, RefDatnom int, MarshDay tinyint, Sk50prn tinyint,
    SpIce money, ScIce money, Izmen money, Back money, SpPF money, ScPF money, SpOther Money,
    ScOther money, Done bit, Tomorrow bit, Remarkop varchar(50), Ready Bit,
    Dayshist tinyint, PrintedNak tinyint, Sk50present bit, Changed bit );

  if @nd<@today begin
    insert into #p
      select cast(log.param1 as int) as Datnom, 0 as b_id, 'ПЕРЕМЕЩЕНА' as Fam, '' as Tm, 0 as Op, 0 as Sp, 0 as Sc,
        0 as Extra, 0 as Srok, 0 as Fact, 0 as OurID, 0 as Pko, 0 as Man_ID,
        0 as BankID, 0 as Tovchk, 0 as Frizer, 0 as Ag_ID, '' as StfNom, null as StfDate, 
        0 QtyFriz, Param2+'-->'+Param3 as Remark, 0 Printed, 0 Marsh, 0 BoxQty, 0 Weight, 
        0 Actn, 0 CK, 0 Tara, null as RefDatNom, 0 MarshDay, 0 Sk50prn, 
        0 SpIce, 0 ScIce, 0 as Izmen, 0 Back, 0 SpPF, 0 ScPF, 0 SpOther, 
        0 ScOther, cast(0 as bit) Done, cast(1 as bit) Tomorrow, '' RemarkOp, cast(1 as bit) Ready,
        1 DayShift,  0 PrintedNak, cast(0 as bit) Sk50present,
        null Changed
      from Log
      where tip='datsh' and cast(log.param1 as int) between @n0 and @n1
      and cast(log.param1 as int) not in (select datnom from nc where datnom between @n0 and @n1)
      order by datnom;
    declare C1 cursor fast_forward for select distinct datnom from #p;
    open C1;
    fetch next from C1 into @Datnom;
    WHILE (@@FETCH_STATUS=0)  BEGIN    
      set @b_id=0
      set @fam=0  
      select @b_id=b_id, @Fam=fam from (
        select b_id, fam from nc where datnom=(
        select top 1 cast(log.param4 as integer) from log where param1='1208200008' 
        and cast(log.param1 as int) not in (select datnom from nc where datnom between 1208200001 and 1208209999)
        order by lid desc)) E;
      update #p set b_id=@b_id, fam='(ПЕРЕМЕЩЕНИЕ) '+LEFT(@fam,100-14) where datnom=@datnom
      fetch next from C1 into @Datnom;
    end;
    close C1;
    deallocate C1;      
  end; -- if @nd<@today
  
  
  select nc.Datnom, nc.b_id, nc.Fam, nc.Tm, nc.Op, nc.Sp, nc.Sc,
    nc.Extra, nc.Srok, nc.Fact, nc.OurID, nc.Pko, nc.Man_ID,
    nc.BankID, nc.Tovchk, nc.Frizer, nc.Ag_ID, nc.StfNom, nc.StfDate, 
    nc.QtyFriz, nc.Remark, nc.Printed, nc.Marsh, nc.BoxQty, nc.Weight, 
    nc.Actn, nc.CK, nc.Tara, nc.RefDatNom, nc.MarshDay, nc.Sk50prn, 
    nc.SpIce, nc.ScIce, nc.Izmen, nc.Back, nc.SpPF, nc.ScPF, nc.SpOther, 
    nc.ScOther, nc.Done, nc.Tomorrow, nc.RemarkOp, nc.Ready,
    nc.DayShift,  nc.PrintedNak, nc.Sk50present,
    e.datnom as Changed
  from nc left join 
  (select distinct datnom from ncedit where Datnom between @n0 and @n1) e 
    on e.datnom=nc.datnom
  where nc.datnom between @n0 and @n1

  union

  select * from #p
  order by datnom
end