CREATE PROCEDURE dbo.ReCalcTaraKol
AS
BEGIN
create table #Tmp(kol int,tip int,DatNom int,B_id int)
insert into #Tmp
select sum(kol),td.taratip,DatNom,td.B_id
from TaraDet td
/*join
(select B_id,taratip from TaraDet
group by B_id,taratip
having Sum(kol)>=0)A on A.B_id=td.B_id and A.taratip=td.Taratip*/
group by td.taratip,DatNom,td.B_id
having Sum(Kol)<0
order by DatNom

select *
from #Tmp

DECLARE @Kol int,@tip int,@DNom int,@B_id int
DECLARE @Kol2 int,@DNom2 int,@TmpKol int
DECLARE @CURSOR CURSOR


SET @CURSOR =CURSOR SCROLL
FOR SELECT kol,tip,DatNom,B_id
    FROM #tmp
    ORDER BY B_Id
OPEN @CURSOR

FETCH NEXT FROM @CURSOR INTO @Kol,@tip,@DNom,@B_id
WHILE @@FETCH_STATUS=0
BEGIN
    set @TmpKol=@kol;
    ---------ВНУТРЕННИЙ КУРСОР-----------
    DECLARE @CUR CURSOR
    SET @CUR =CURSOR SCROLL
    FOR select sum(kol),DatNom
        from TaraDet td
        where B_id=@B_id and taratip=@tip
        group by taratip,DatNom,td.B_id
        having Sum(Kol)>0
        order by DatNom
    OPEN @CUR

    FETCH NEXT FROM @CUR INTO @Kol2,@DNom2
    WHILE @@FETCH_STATUS=0 and abs(@Kol)>0
    BEGIN
      if abs(@Kol)>@kol2
      begin
      --  закрываем тару на @kol2
          insert into TaraDet (ND,B_ID,Nnak,SellDate,DatNom,ACT,taratip,Kol,Price,OP,
                           Remark)
          select CONVERT(varchar,getdate(),4),@B_id,dbo.InNnak(@DNom2),dbo.DatNomInDate(@DNom2),
               @DNom2,'ТВ',@tip,-@Kol2,Taraprice,0,'персчет тары'
          from TaraCode
          where TaraTip=@tip
        set @Kol=@Kol+@kol2
      end
      else
        if abs(@Kol)<=@Kol2
        begin
      -- закрываем тару на @kol
          insert into TaraDet (ND,B_ID,Nnak,SellDate,DatNom,ACT,taratip,Kol,Price,OP,
                           Remark)
          select CONVERT(varchar,getdate(),4),@B_id, dbo.InNnak(@DNom2),dbo.DatNomInDate(@DNom2),
                @DNom2,'ТВ',@tip,@Kol,Taraprice,0,'персчет тары'
          from TaraCode
          where TaraTip=@tip
        set @Kol=0
        end;
      FETCH NEXT FROM @CUR INTO @Kol2,@DNom2   
    END

    CLOSE @CUR 
    ----------КОНЕЦ ВНУТР. КУРСОРА-------
   
        -- убираем перевозврат тары
        
      insert into TaraDet (ND,B_ID,Nnak,SellDate,DatNom,ACT,taratip,Kol,Price,OP,
                           Remark)
      select CONVERT(varchar,getdate(),4),@B_id, dbo.InNnak(@DNom),dbo.DatNomInDate(@DNom),
           @DNom,'ТП',@tip,-(@TmpKol-@kol),Taraprice,0,'перевозврат тары'
      from TaraCode
      where TaraTip=@tip 
    FETCH NEXT FROM @CURSOR INTO @Kol,@tip,@DNom,@B_id
END

CLOSE @CURSOR

END