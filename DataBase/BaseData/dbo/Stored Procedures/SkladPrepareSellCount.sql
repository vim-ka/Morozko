CREATE PROCEDURE dbo.SkladPrepareSellCount
@Comp varchar(30),
@Hitag int,
@Cnt int,
@SkladList varchar(200),
@datnom int, 
@Op int, 
@kolError int out,
@spk int=0,
@nzid INT=0
AS
BEGIN
  declare @erReg int
  set @erReg=0
  declare @tranname varchar(30)
  set @tranname='SkladPrepareSellCount'
  begin tran @tranname
  DECLARE @zakaz int
  IF @nzid=0
  BEGIN
    set @nzid=
      (SELECT top 1 nzid FROM nvZakaz z WHERE z.datnom=@DATNOM AND z.Hitag=@HITAG AND z.Done=0)
  END 
  SELECT @zakaz=z.zakaz 
  FROM nvZakaz z 
  WHERE z.nzid=@nzid

  declare @id int, @Kol int, @Rest int
  declare @sklad int
  declare @price money
  declare @cost money
  declare @tekWeight decimal(10,2)
  declare @FirmGroup int
  
  select @FirmGroup=fc.firmgroup
  from dbo.nc c
  join dbo.firmsconfig fc on fc.our_id=c.ourid
  where c.datnom=@datnom
  
  IF @Cnt>0 AND @zakaz>0
  BEGIN
  select @tekWeight=sum(case when n.flgWeight=1 
  													 then v.weight*(v.morn-v.sell+v.isprav-v.remov-v.rezerv) 
                             else (v.morn-v.sell+v.isprav-v.remov-v.rezerv) end) 
  from tdvi v
  left join nomen n on n.hitag=v.hitag
  join FirmsConfig f on v.Our_id=f.Our_id	
  where v.sklad in (select k from dbo.Str2intarray(@SkladList))
        and v.HITAG=@Hitag
  			and f.FirmGroup=@FirmGroup

  select  @cost= z.Cost,
  				@price= z.Price 
  from nvZakaz z
  where datnom=@datnom
  			and hitag=@Hitag
        AND DONE=0

  IF NOT exists(select 1
                from tdvi t
                where t.hitag=@Hitag
  			              and t.sklad in (select k from dbo.Str2intarray(@SkladList))
                      and t.locked=0
                      and t.lockid=0
                      and morn-sell+isprav-REMOV-bad>0
                      AND t.id>0) SET @erReg=@erReg+64

  declare CR cursor fast_forward for
  select id,sklad,morn-sell+isprav-REMOV-bad as Rest
  from tdvi t
  join FirmsConfig f on t.Our_id=f.Our_id 
  where t.hitag=@Hitag
  			and t.sklad in (select k from dbo.Str2intarray(@SkladList))
        and t.locked=0
        and t.lockid=0
        and morn-sell+isprav-REMOV-bad>0
        AND t.id>0
        and f.FirmGroup=@FirmGroup
  order by t.srokh
  
  open CR
  fetch next from CR into @ID, @Sklad,@Rest
  while (@@FETCH_STATUS=0) and (@Cnt>0) begin
    if @rest>=@cnt set @Kol=@cnt else set @Kol=@rest;
    
    if exists(select 1 from nv where datnom=@datnom and TekID=@ID)
      update nv set kol=kol+@Cnt where datnom=@datnom and TekID=@ID
    else
    begin
      insert into nv (DatNom, TekID, Hitag, Price, Cost,  Kol, Sklad, BasePrice, OrigPrice)
      values (@datnom, @id,  @Hitag,@price, @cost, @Kol, @sklad, @price,  @price);
      IF @@error<>0 SET @erReg=@erReg+32
    END;
      
    update tdvi set sell=sell+@kol where id=@id
    set @cnt=@cnt-@kol;
    IF @erReg=0 and (@Cnt>0)
      fetch next from CR into @ID, @Sklad,@Rest
    ELSE 
      BREAK;
  end;

  close CR
  deallocate CR
  
  if @ErReg=0 begin
    update nvzakaz 
    set done=1,
        tmEnd=CONVERT(varchar(8),getdate(),108),
        dtEnd=CONVERT(varchar(10),getdate(),104),
        curWeight=@Cnt,
        tekWeight=@tekWeight,
        id=@id,
        comp=comp+'#'+@Comp,
        op=@op,
        spk=@spk
        where datnom=@datnom 
                  and hitag=@Hitag;
      if @@error<>0 set @erReg=@erReg+8;
  end;
  END
  ELSE
    SET @erReg=16
  
  IF @zakaz<0
  BEGIN
    UPDATE nvZakaz SET done=1,
                       tmEnd=CONVERT(varchar(8),getdate(),108),
                       dtEnd=CONVERT(varchar(10),getdate(),104),
                       curWeight=@zakaz,
                       comp=comp+'#'+@Comp,
                       op=@op,
                       spk=@spk
    WHERE nzid=@nzid
  END 
  
  set @kolError=@erReg
  IF @zakaz>0
  if @erReg=0
  	commit tran @tranname
  else
  	rollback tran @tranname
END