create procedure dbo.CkCNdsRecalc @StartDay datetime-- пересчет сумм НДС в табл. CK
as
declare @CkId int, @KassID int, @datnom int, @Plata decimal(12,2), @Snds10 decimal(10,2),@Snds18 decimal(10,2), @i int
begin


  create table #t(rank int, nd datetime, nvid int, nnak int, 
    NnakDate datetime, Hitag int, Name varchar(100), Price decimal(12,2), 
    Qty decimal(12,6), Nds smallint, KassID int, TekID int, Weight decimal(12,6));
  set @i=0

  DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
  SELECT CK.ckid, ck.KassID, K.SourDatnom, CK.Plata
  FROM 
    CK
    inner join Kassa1 k on K.kassid=ck.kassid
  where 
    CK.Plata>=0.07 
    and isnull(CK.Nds10,0)=0 
    and isnull(CK.Nds18,0)=0
    and CK.ND>=@StartDay;

  OPEN cur;  

  FETCH NEXT FROM cur INTO @ckid, @KassID, @Datnom, @Plata

  WHILE @@FETCH_STATUS = 0 BEGIN
    truncate table #t;

    insert into #t Exec CalcNdsSumDatnomNewVer @KASSID;

    select 
      @SNDS10=round(sum(iif(nds=10, qty*price*nds/(100+nds), 0)),2),
      @SNDS18=round(sum(iif(nds=18, qty*price*nds/(100+nds), 0)),2) 
    from #t;
    set @i=@i+1;

    print( cast(@i as varchar)+') ckid='+cast(@ckid as varchar)+', KassID='+cast(@KassID as varchar)
      +', Plata='+cast(@plata as varchar)+', SNDS10='+cast(@SNDS10 as varchar)+', SNDS18='+cast(@SNDS18 as varchar))
    update CK set Nds10=@SNDS10, Nds18=@SNDS18 where ckid=@CkId;

    FETCH NEXT FROM cur INTO @ckid, @KassID, @Datnom, @Plata;
  end;
  close cur;
  deallocate cur;
    
end