CREATE procedure dbo.SaveZakaz_Debug
  @CompName varchar(30), @Hitag INT, @TekID int, @Qty float, 
  @Sklad int=0, @SavedZakaz float=0 out, @Price money=0, 
  @EffWeight float=0, @Nds int=0,@DelivGroup int=0, @ClearZakaz bit=0,
  @DCK int=0, @StfNom varchar(17)='', @StfDate datetime=NULL, 
  @DocNom varchar(20)='', @DocDate datetime=NULL,
  @flgRezerv bit=0, @upWeight bit=0, @ForcedIntegerSell bit=0, @RefDatnom int=0
as 
declare @Ostat int
declare @Cost money
declare @AlienZakaz int
declare @RegID varchar(5), @NGRP int, @DepID int, @SV_ID int, @Child varchar(2000)
begin

  select @SV_ID=a.sv_ag_id, @DepID=a.DepID, @RegID=e.Reg_ID
  from DefContract d join agentlist a on d.ag_id=a.ag_id
                     join Def e on d.pin=e.pin
  where d.dck=@DCK
  
  select @Ngrp=n.Ngrp from nomen n where n.hitag=@Hitag
  
  if @Qty<0  set @DelivGroup = 0  
  -- ГРУППА ДОСТАВКИ
  
  else set @DelivGroup = isnull((select g.DelivGr from DelivGroups g 
                            where (g.Reg_id=@Regid or g.Reg_id='')                                   --выбранный регион или все регионы
                                   and   (g.SkladNo=@Sklad or g.SkladNo=0)                           --выбранный склад или любой склад
                                   and   (g.DayOfWeek = DatePart(dw,dbo.today()) or g.DayOfWeek = 0) --выбранный день или любой день
                                   and   (g.Ngrp in (select k from dbo.Str2intarray(dbo.GetGrParent(@NGRP))) or g.Ngrp=0) --выбранная группа или все группы
                                   and   (g.DepID=@DepID or g.DepID=0)                               --выбранный отдел или все отделы
                                   and   (g.SV_ID=@SV_ID or g.SV_ID=0)),0)                           --выбранный супервайзер или все супервайзеры
  
   
  select @Cost=iif(n.flgWeight=1 and t.[WEIGHT]<>0, t.Cost/t.weight, t.Cost)
  from tdVi t join nomen n on t.hitag=n.hitag
  where t.id=@tekid; 
  
  print('@QTY='+cast(@qty as varchar))
  set @qty=round(@qty,0); -- здесь было set @qty=cast(@qty as int)
  if @ClearZakaz = 1 
  	delete from Zakaz where CompName=@CompName
  else
	delete from Zakaz where CompName=@CompName and @TekID<>-1 and Tekid=@TekId and DCK=@DCK;
  
  if (@flgRezerv=0)
  begin    
    set @Ostat=cast(isnull((select morn-sell+isprav-remov-bad-rezerv from tdVi where id=@tekid and Sklad=@Sklad and Hitag=@Hitag and Locked=0),0) as int);
    set @AlienZakaz=cast(isnull((select sum(Qty) from Zakaz where tekid=@tekid),0) as int);
    set @Ostat=round(@Ostat-@AlienZakaz,0); 
    
    if (@Ostat<0) and (@UpWeight=0) set @SavedZakaz=0
    else if (@Ostat<=@Qty) and (@UpWeight=0) set @SavedZakaz=@Ostat;
    else set @SavedZakaz=@Qty;

  end;
  else set @SavedZakaz=@Qty;
  
  if @SavedZakaz>0 
    insert into Zakaz(CompName,Hitag,Tekid,Qty,Sklad,Price,EffWeight,Cost,Nds,DelivGroup, DCK, StfNom, StfDate, DocNom, DocDate,ForcedIntegerSell, RefDatnom) 
    values(@CompName,@Hitag,@Tekid,@SavedZakaz,@Sklad,@Price,@EffWeight,@Cost,@Nds,@DelivGroup, @DCK, @StfNom, @StfDate, @DocNom, @DocDate, @ForcedIntegerSell, @RefDatnom)
  
  update Zakaz set Stfnom=@Stfnom, StfDate=@stfdate, DocNom=@DocNom, DocDate=@DocDate where CompName=@CompName and Dck=@Dck;  
  --select @SavedZakaz;
end;