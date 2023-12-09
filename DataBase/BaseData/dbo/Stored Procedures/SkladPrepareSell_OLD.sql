

CREATE procedure SkladPrepareSell_OLD
  @Action tinyint=0, -- 0 - набор
  @Comp varchar(30),
  @Hitag int,
  @Ves decimal(10,3),
  @SkladList varchar(200),
  @datnom int, 
  @Op int, 
  @kolError int out  
  
as
  declare @ID int, @Junk int, @NewID int, @LastIzmId int, @LastID int, @OrigId int, @OrigWeight decimal(10,3),
    @Price decimal(10,2), @Cost decimal(13,5), @NewPrice decimal(10,2), @NewCost decimal(13,5), 
    @Sklad int, @NewSklad int, @ss varchar(100), @tekWeight decimal(10,3),
    @ProcError int, @UnionWeight decimal(10,3), @Qty int, @OrigQty int, @FirmGroup int
begin
begin try
if @Ves>0 begin
  truncate table SkladPrepLog;
  delete from ParamSklad where Comp=@Comp;
  begin transaction

  set @kolError=0
  set @ProcError=0
  
  set @FirmGroup=(select f.FirmGroup from nc c join FirmsConfig f on c.ourid=f.our_id where c.datnom=@datnom)
  
  select @tekWeight=sum(v.weight*(v.morn-v.sell+v.isprav-v.remov-v.rezerv)) 
  from tdvi v
  where v.sklad in (select k from dbo.Str2intarray(@SkladList))
        and v.HITAG=@Hitag
	
  if EXISTS(
 	 select *
	  from tdvi v join FirmsConfig f on v.Our_id=f.Our_id	
	  where v.hitag=@Hitag and v.Weight>0
	  and v.sklad in (select k from dbo.Str2intarray(@SkladList))
      and v.weight*(v.morn-v.sell+v.isprav-v.remov)=@Ves and v.locked=0 and (v.morn-v.sell+v.isprav-v.remov)>0
      and f.FirmGroup=@FirmGroup
      )
  begin  
    select top 1
      @ID=id,
      @OrigId=v.id, @Sklad=v.sklad, @OrigWeight=v.Weight*(v.morn-v.sell+v.isprav-v.remov),
      @Price=v.Price, @Cost=v.Cost, @UnionWeight=v.Weight, @OrigQty=(v.morn-v.sell+v.isprav-v.remov)
    from tdvi v join FirmsConfig f on v.Our_id=f.Our_id
    where v.hitag=@Hitag and v.Weight>0
    and v.sklad in (select k from dbo.Str2intarray(@SkladList))
    and v.weight*(v.morn-v.sell+v.isprav-v.remov)=@Ves and v.locked=0 and (v.morn-v.sell+v.isprav-v.remov)>0
    and f.FirmGroup=@FirmGroup
    order by v.srokh
    
    
  end
  else
  begin
    select top 1
      @ID=id,
      @OrigId=v.id, @Sklad=v.sklad, @OrigWeight=v.Weight*(v.morn-v.sell+v.isprav-v.remov),
      @Price=v.Price, @Cost=v.Cost, @UnionWeight=v.Weight, @OrigQty=(v.morn-v.sell+v.isprav-v.remov)
    from tdvi v join FirmsConfig f on v.Our_id=f.Our_id
    where v.hitag=@Hitag and v.Weight>0
    and v.sklad in (select k from dbo.Str2intarray(@SkladList))
    and v.weight*(v.morn-v.sell+v.isprav-v.remov)>@Ves and v.locked=0 and (v.morn-v.sell+v.isprav-v.remov)>0
    and f.FirmGroup=@FirmGroup
    order by v.weight desc, v.srokh
  end
  
  if @id is null set @KolError=1;
  
  set @Qty=(case when 1.0*@Ves/@UnionWeight>1
                 then ceiling(1.0*@Ves/@UnionWeight) 
                 else 1 end)
                
    
  if @Ves <> @OrigWeight --если вообще что-то нужно пилить
  begin
       
      if @KolError=0 and @ves>0 begin
        -- какую строку распилить:
        INSERT INTO ParamSklad(Comp,  Act,  Id,  Hitag,  Sklad,  [Weight],  Price,  Cost,  Nomer,  Qty) 
        VALUES (@Comp,  'Div-',  @OrigId,  @Hitag,  @Sklad,  @OrigWeight,  @Price,  @Cost, 0,  @Qty);
        if @@error<>0 set @KolError=@KolError+2;
        -- новая строка с остатком:
        
        --if @OrigWeight>=@Ves 
        if @UnionWeight*@Qty<>@Ves
        begin
          INSERT INTO ParamSklad(Comp,  Act,  Id,  Hitag,  Sklad,  [Weight],  Price,  Cost,  Nomer,  Qty) 
          VALUES (@Comp,  'Div-',  null,  @Hitag,  @Sklad,  @UnionWeight*@Qty-@Ves,  
            @Price/@UnionWeight*(@UnionWeight*@Qty-@Ves), @Cost/@UnionWeight*(@UnionWeight*@Qty-@Ves), 1,  1);
           if @@error<>0 set @KolError=@KolError+4; 
        end 
         else if @OrigQty=1
        begin 
          INSERT INTO ParamSklad(Comp,  Act,  Id,  Hitag,  Sklad,  [Weight],  Price,  Cost,  Nomer,  Qty) 
          VALUES (@Comp,  'Div-',  null,  @Hitag,  @Sklad,  @OrigWeight-@Ves,  
            @Price/@OrigWeight*(@OrigWeight-@Ves),  @Cost/@OrigWeight*(@OrigWeight-@Ves), 1,  1);
          if @@error<>0 set @KolError=@KolError+4;   
        end 
       
        -- Вторая новая строка, это будет продано:
        INSERT INTO ParamSklad(Comp,  Act,  Id,  Hitag,  Sklad,  [Weight],  Price,  Cost,  Nomer,  Qty) 
        VALUES (@Comp,  'Div-',  null,  @Hitag,  @Sklad,  @Ves,  
          @Price*@Ves/@UnionWeight,  @Cost*@Ves/@UnionWeight, 2,  @Qty);
        if @@error<>0 set @KolError=@KolError+8;
      end;

      set @Junk=0; set @NewID=0;
      if @KolError=0 
      begin
        
       exec ProcessSklad 'Div-', null, @Hitag, null, 
          null, null, 0, @Op, @Comp,
          null, 0, 1,  0, 0,0,
          'продажа на вес', @Newid,  0,
          @ProcError, null, @Junk,null;
          
         if isnull(@ProcError,0)<>0 
         set @KolError=@KolError+16;
       end 
     	
      if @KolError=0
      begin
        set @LastIzmID=(select top 1 IzmID from izmen where act='div+' and comp=@COMP and hitag=@hitag and abs(@Ves-izmen.NewWeight)<=0.001 and ND=dbo.today() order by izmID desc)
       
        if 	@@Error<>0 or isnull(@LastIzmID,0)=0 set @KolError=@KolError+32;
      end;
       
      if @KolError=0
      begin
        select @LastId=NEWID, @NewCost=NewCost, @NewPrice=NewPrice, @NewSklad=NewSklad from Izmen where izmid=@LastIzmId;
        if @@Error<>0 set @KolError=@KolError+64;
      end
  end
  else
  begin
    set @LastID=@OrigId
    set @NewCost=@Cost
    set @NewPrice=@Price
    set @NewSklad=@Sklad
  end
  
	if isnull(@LastID,0)=0 set @KolError=@KolError+2048;
    
  if @KolError=0 begin
    set @ss='update tdvi, id='+cast(@LastID as varchar)
    update tdvi set sell=sell+@Qty where id=@LastID
    if @@Error<>0 set @KolError=@KolError+128;
  end
	
  if @KolError=0 begin
/*    set @NewPrice=(select top 1 price from nvzakaz where hitag=@hitag and datnom=@datnom);
    set @newPrice=@NewPrice*@ves;
  */ 
      insert into nv(DatNom,tekid,hitag,sklad,price,cost,kol,tip)
      VALUES(@datnom, @LastID, @Hitag, @NewSklad, @NewPrice, @NewCost, @Qty, 0)
	if @@Error<>0 set @KolError=@KolError+256;
    
  end
	
  /*
  if @KolError=0 begin    
    update NC  
      set SP=(select sum(kol*price) from nv where datnom=@datnom),
      SC=(select sum(kol*cost) from nv where datnom=@datnom) 
      where datnom=@datnom 
    if @@Error<>0 set @KolError=@KolError+512;    
  end
  */
	
  if @KolError=0 
  begin    
	update nvzakaz 
      set done=1,
					tmEnd=CONVERT(varchar(8),getdate(),108),
					dtEnd=CONVERT(varchar(10),getdate(),104),
					curWeight=@Ves,
					tekWeight=@tekWeight,
					id=@LastID,
                    comp=comp+'#'+@Comp
      where datnom=@datnom and hitag=@Hitag;
    if @@Error<>0 set @KolError=@KolError+1024;	
  end
	
	if @KolError=0 
	begin
		if exists(select * from nc where datnom=@datnom and  not marsh in (0,99))
		begin
			declare @m int
			declare @n datetime 
			
			select @m=Marsh, @n=nd
			from nc 
			where datnom=@datnom
			
			update Marsh set Weight=Weight+@Ves, BruttoWeight=BruttoWeight+@Ves
			where marsh=@m and nd=@n
		end
	end
--  insert into ProcErrors(errnum, errmess, procname, errline) select @KolError, 'Ошибка в результате исполнения','SkladPrepareSklad',0
  if @KolError=0 Commit else Rollback;
end;
end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
  end catch 
end