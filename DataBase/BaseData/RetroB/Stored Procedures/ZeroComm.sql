CREATE procedure RetroB.ZeroComm @ncom INT -- например, 149236
As
declare @LastDay datetime, @DeltaCost decimal(14,4),  @SumDeltaCost decimal(14,4),  
  @cnt int,@nd datetime, @TM varchar(8), @remark varchar(40), @Comp varchar(16), @Hrono datetime,
  @Prevnd datetime, @PrevTM varchar(8), @Prevremark varchar(40), @PrevComp varchar(16), @PrevHrono datetime,
  @IzmID int, @KsID0 int, @TekOp int, @KassOp int, @Ksid2 int, @Oper2 int, @p_id2 int, @Plata2 decimal(10,2),
  @TotalPlata2 decimal(10,2)
begin

  DECLARE c1 CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
    SELECT cast(FORMAT(ND,'d','de-de')+' '+TM as datetime) as Hrono, remark, COMP, NewKol*NewCost-Kol*Cost as DeltaCost, IzmID
    FROM IZMEN
    WHERE NCOM=@NCOM AND ACT='ИзмЦ' and REMARK LIKE 'REAS%'
    order by nd,tm
  open c1
  fetch next from c1 into @Hrono, @remark, @comp, @DeltaCost, @IzmID
  while @@FETCH_STATUS=0 BEGIN
    print('Начало новой серии')
    set @cnt=0
    set @SumDeltaCost=0
    set @PrevHrono=@Hrono
    set @PrevRemark=@Remark
    set @PrevComp=@comp
    update izmen set newcost=cost where izmid=@izmid

    while (@@FETCH_STATUS=0)and(DateDiff(ss,@PrevHrono,@hrono)<30)and(@Comp=@PrevComp)and(@Remark=@PrevRemark) 
    BEGIN
      set @cnt=@cnt+1
      print(cast(@cnt as varchar)+')  '+FORMAT(@Hrono,'d','de-de')+' '+FORMAT(@Hrono, N'hh\.mm\.ss')+'   Remark=' + @remark +',  comp='+ cast(@comp as varchar))
      set @PrevHrono=@Hrono
      set @SumDeltaCost=@SumDeltaCost+@DeltaCost
      fetch next from c1 into @Hrono, @remark, @comp, @DeltaCost, @IzmID
      -- Не забыть разблокировать в финальной версии: update izmen set newcost=cost where izmid=@izmid
    end

    print('Серия переоценок закончилась, сумма='+cast(@SumDeltaCost as varchar)+', ищем кассовые операции за '+FORMAT(@PrevHrono,'d','de-de'))
    set @LastDay=cast(FORMAT(@PrevHrono,'d','de-de')+' 00:00:00' as datetime)

    -- set @Ksid0=isnull((select min(kassid) from dbo.kassa1 where nd=@LastDay and nnak=@NCOM and remark like 'reas%' and oper=-1 ),0)
    --         --  and DateDiff(ss, @hrono, cast(FORMAT(ND,'d','de-de')+' '+TM as DateTime))<30

    select top 1 @Ksid0=kassid, @KassOp=OP, @Plata2=Plata
    from dbo.kassa1 
    where 
      nd=@LastDay and nnak=@NCOM and remark like 'reas%' and oper=-1
      and DateDiff(ss, @hrono, cast(FORMAT(ND,'d','de-de')+' '+TM as DateTime))<5
    order by kassid;



    if @ksid0>0 begin
      print('Первая строка в серии кассовых операций kassid=' + cast(@ksid0 as varchar))
      set @TotalPlata2=0.00
      print('Приступаем к поиску соответствующих операций с фондами среди записей в Kassa1 от '+cast(@ksid0 as varchar)+' до '+cast(@ksid0+30 as varchar))
      print('Будет обнулена выплата по строке Kassid='+cast(@ksid0 as varchar)+' в размере '+cast(@Plata2 as varchar))
      -- Не забыть раскомментировать: 
      update dbo.Kassa1 set Plata=0 where Kassid=@ksid0
      declare C2 cursor fast_forward for
        select kassid, oper, p_id, Plata
        from dbo.kassa1 
        where 
          kassid between @ksid0+1 and @ksid0+20
          and oper in (-1,10)
          and remark='reassessment'
          and op=@KassOP
        order by kassid;

      open C2;
      fetch next from C2 into @ksid2, @oper2, @p_id2, @Plata2;
      while @@fetch_status=0 and @oper2=10 and @p_id2<>0 BEGIN
        print('Будет обнулена выплата по строке Kassid='+cast(@ksid2 as varchar)+' в размере '+cast(@Plata2 as varchar))
        set @TotalPlata2=@TotalPlata2+@Plata2
        -- Не забыть раскомментировать: 
        update dbo.Kassa1 set Plata=0 where Kassid=@ksid2
        fetch next from C2 into @ksid2, @oper2, @p_id2, @Plata2;
      end;
      close C2;
      deallocate C2;
      print('Всего обнулено выплат фондов на сумму '+cast(@TotalPlata2 as varchar))
    end
    else print('Странно, не удалось найти кассовых операций, соответствующих данной серии переоценок.')

    print('')
  end
  close c1
  deallocate c1
end