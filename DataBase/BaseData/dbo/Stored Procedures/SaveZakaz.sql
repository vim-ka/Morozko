CREATE procedure dbo.SaveZakaz
  @CompName varchar(30), @Hitag INT, @TekID int, @Qty decimal(12,3), 
  @Sklad int=0, @SavedZakaz decimal(12,3)=0 out, @Price money=0, 
  @EffWeight float=0, @Nds int=0,@DelivGroup int=0, @ClearZakaz bit=0,
  @DCK int=0, @StfNom varchar(17)='', @StfDate datetime=NULL, 
  @DocNom varchar(20)='', @DocDate datetime=NULL,
  @flgRezerv bit=0, @upWeight bit=0, @ForcedIntegerSell bit=0, @RefDatnom int=0,
  @Extra decimal(7,2)=0.0,
  @Unid SMALLINT=0,  -- текущая единица измерения/ 0-шт,1-кг,2-л,3-бут.
  @K decimal(15,7)=1 -- коэффициент пересчета из основной ед.изм. в текущую.

  --    Нужны пояснения. Предположим, нативная единица измерения - штука (unid=0),
  --  а пользователь пожелал хранить продажу в килограммах (unid=1).
  --    Пусть это для определенности товар с кодом 29649, для него есть подходящая запись в табл. UnitConv,
  --  где Unid1=0, Unid2=1, K=5. 
  --  Т.е. 1 штука товара - это 5 кг этого же товара.
  --    Количество товара для оператора умножается на 5, а цена делится на 5.
  --    Итак, в табл. Zakaz должны быть переданы такие параметры: Unid=1 (исходный Unid=0 можно не передавать,
  --  он хранится в TDVI), K=5, количество передается в килограмах, а цена продажи и прихода относятся к 1 кг веса,
  --  т.е. в 5 раз меньше, чем за штуку.


as 
declare @Ostat decimal(12,3)
declare @Cost money
declare @AlienZakaz decimal(12,3)
declare @RegID varchar(5), @NGRP int, @DepID int, @SV_ID int, @Child varchar(2000)
declare @Master int, @RoundDec smallint
begin
 
  select @SV_ID=a.sv_ag_id, @DepID=a.DepID, @RegID=e.Reg_ID, @Master=e.Master, @RoundDec=isnull(d.PricePrecision,2)
  from 
    DefContract d 
    INNER join Def e on d.pin=e.pin
    INNER join agentlist a on d.ag_id=a.ag_id
  where d.dck=@DCK

print '@RoundDec='+cast(@RoundDec as varchar)  
  
  -- Для сети "Лукойл" цены продажи держим с 4 знаками после точки:
  --if @Master=27124 set @RoundDec=4 else set @RoundDec=2;

  select @Ngrp=n.Ngrp from nomen n where n.hitag=@Hitag
  
  if @Qty<0  set @DelivGroup = 0  
  -- ГРУППА ДОСТАВКИ
  
  else set @DelivGroup = isnull((select g.DelivGr from DelivGroups g 
    where 
    (g.Reg_id=@Regid or g.Reg_id='')                                   --выбранный регион или все регионы
    and   (g.SkladNo=@Sklad or g.SkladNo=0)                           --выбранный склад или любой склад
    and   (g.DayOfWeek = DatePart(dw,dbo.today()) or g.DayOfWeek = 0) --выбранный день или любой день
    and   (g.Ngrp in (select k from dbo.Str2intarray(dbo.GetGrParent(@NGRP))) or g.Ngrp=0) --выбранная группа или все группы
    and   (g.DepID=@DepID or g.DepID=0)                               --выбранный отдел или все отделы
    and   (g.SV_ID=@SV_ID or g.SV_ID=0)),0)                           --выбранный супервайзер или все супервайзеры
  
   
  -- select @Cost=t.Cost/@K from tdVi t where t.id=@tekid; -- цену прихода пересчитываем по отношению к производной единице, например, кг.
  -- Нет! ОБЕ цены держим для базовых единиц!
  SET @Cost=(SELECT cost FROM tdvi WHERE id=@tekid);

  
  print('@QTY='+cast(@qty as varchar))

  if @ClearZakaz = 1 
  	delete from Zakaz where CompName=@CompName
  else
	  delete from Zakaz where CompName=@CompName and @TekID<>-1 and Tekid=@TekId and DCK=@DCK;
  
  if (@flgRezerv=0)
  begin    
    -- Остаток измеряем в текущих (возможно, производных) единицах:
    set @Ostat=@K*cast(isnull((select morn-sell+isprav-remov-bad-rezerv from tdVi where id=@tekid and Sklad=@Sklad and Hitag=@Hitag and Locked=0),0) as float);
    set @AlienZakaz=@K*cast(isnull((select sum(Qty/K) from Zakaz where tekid=@tekid),0) as float);
    set @Ostat=round(@Ostat-@AlienZakaz,3); 
    
    if (@Ostat<=0) set @SavedZakaz=0;
    else if (@Ostat<=@Qty) set @SavedZakaz=@Ostat;
    else set @SavedZakaz=@Qty;

  end;
  else set @SavedZakaz=@Qty;
print '@SavedZakaz='+cast(@savedZakaz as varchar)  
print '@Price='+cast(@Price as varchar)  
print '@RoundDec='+cast(@RoundDec as varchar)  

  if @SavedZakaz>0 
    insert into Zakaz(CompName,Hitag,Tekid,Qty,Sklad,
      Price,
      EffWeight,Cost,Nds,DelivGroup, MainExtra, DCK, StfNom, 
      StfDate, DocNom, DocDate,ForcedIntegerSell, RefDatnom, UnID, k) 
    values(@CompName,@Hitag,@Tekid,@SavedZakaz,@Sklad,
      ROUND(@Price,@RoundDec), -- Для сети "Лукойл" округление цены до 4 знаков.
      @EffWeight,@Cost,@Nds,@DelivGroup, @Extra, @DCK, @StfNom, 
      @StfDate, @DocNom, @DocDate, @ForcedIntegerSell, @RefDatnom, @Unid, @K)
      
      
   insert into LogZakaz(CompName,Hitag,Tekid,Qty,Sklad,
      Price,
      EffWeight,Cost,Nds,DelivGroup, MainExtra, DCK, StfNom, 
      StfDate, DocNom, DocDate,ForcedIntegerSell, RefDatnom) 
    values(@CompName,@Hitag,@Tekid,@SavedZakaz,@Sklad,
      ROUND(@Price,@RoundDec), -- Для сети "Лукойл" округление цены до 4 знаков.
      @EffWeight,@Cost,@Nds,@DelivGroup, @Extra, @DCK, @StfNom, 
      @StfDate, @DocNom, @DocDate, @ForcedIntegerSell, @RefDatnom)
  
  update Zakaz set Stfnom=@Stfnom, StfDate=@stfdate, DocNom=@DocNom, DocDate=@DocDate where CompName=@CompName and Dck=@Dck;  
  --select @SavedZakaz;
end;