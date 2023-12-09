CREATE procedure dbo.SaveBackZakaz
  @CompName varchar(30), @Hitag INT, @TekID int, @Qty float, 
  @Sklad int=0, @SavedZakaz float=0 out, @Price money=0, @EffWeight float=0, 
  @Nds int=0, @Cost money=0, @MainExtra decimal(7,2)=0,
  @NvID int=0, @RefTekId int=0, @StfNom varchar(17)='', @StfDate datetime=NULL, @DocNom varchar(20)='', @DocDate datetime=NULL,
  @RefDatnom bigint=0, @DCK int=0,
  @Unid SMALLINT=0,  -- текущая единица измерения
  @K decimal(15,7)=1 -- коэффициент пересчета из основной ед.изм. в текущую.as 
as
declare @Ostat DECIMAL(10,3), @AlienZakaz DECIMAL(10,3)
begin
  --if @TekId <> -1 delete from Zakaz where CompName=@CompName and Tekid=@TekId;
  
  set @SavedZakaz=@Qty;
  select @Cost=Cost, @Price=Price from nv where datnom=@Refdatnom and tekid=@RefTekID;
 
  insert into LogZakaz(CompName,Hitag,Tekid,Qty,Sklad,Price,Cost,Nds,DelivGroup, MainExtra, NvID, RefTekId,StfNom, StfDate, DocNom, DocDate, RefDatnom, DCK) 
             values(@CompName,@Hitag,@Tekid,@SavedZakaz,@Sklad,@Price,@Cost,@Nds,0, @MainExtra, @NvID, @RefTekId, @StfNom, @StfDate, @DocNom, @DocDate, @RefDatnom, @DCK);

  insert into Zakaz(CompName,Hitag,Tekid,Qty,Sklad,Price,Cost,Nds,DelivGroup, MainExtra, NvID, RefTekId,
    StfNom, StfDate, DocNom, DocDate, RefDatnom, DCK, Unid, K) 
  values(@CompName,@Hitag,@Tekid,@SavedZakaz,@Sklad,@Price,@Cost,@Nds,0, @MainExtra, @NvID, @RefTekId, 
    @StfNom, @StfDate, @DocNom, @DocDate, @RefDatnom, @DCK, @Unid, @K);
   
  --select @SavedZakaz;
end;