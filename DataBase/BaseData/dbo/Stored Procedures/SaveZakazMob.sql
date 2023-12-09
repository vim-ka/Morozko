CREATE procedure SaveZakazMob
  @B_ID int, @CompName varchar(30), @Hitag int, @TekID int, @Qty float, 
  @Sklad int=0, @SavedZakaz float=0 out, @EffWeight float=0, @Nds int=0, @ClearZakaz bit=0, @OP int=0,
  @Force_ag_id int=0, @DCK int=0, @StfNom varchar(10)='', @StfDate datetime=NULL, @DocNom varchar(10)='', @DocDate datetime=NULL
as 
declare @OrdStick bit
declare @Ostat int
declare @Price money
declare @Cost money
declare @NewPrice money
declare @AlienZakaz int
declare @DelivGroup int, @Datnom1 int, @Datnom2 int
declare @Reg_id char(3)
declare @TekND datetime
begin
  if @Force_ag_id=0 set @OrdStick=0; else set @OrdStick=1;
  
  if @B_ID = 0 set @B_ID=(select pin from DefContract where DCK=@DCK and ContrTip=2)
  
  declare @DepID int,  @SV_ID int, @Ag_ID int
  declare @Ngrp int,  @Ncod int
  declare @Extra float, @MinExtra float
  declare @DisMinExtra bit
  declare @Rests float, @Prognoz float
 
  set @Ngrp = (select n.Ngrp from nomen n where n.hitag=@Hitag);   
  set @Ncod = (select t.Ncod from tdVi t where t.ID=@TekID);   
  if not exists (select b.* from BlackVendList b where b.b_id=@B_ID and b.Ncod=@Ncod and b.Disab=1) --проверка на блокировку поставщика
  begin 
      
    if @ClearZakaz = 1 delete from Zakaz where CompName=@CompName;
    set @qty=cast(@qty as int);
    --delete from Zakaz where CompName=@CompName and Tekid=@TekId;
    set @Ostat=cast(isnull((select morn-sell+isprav-remov-bad-rezerv from tdVi where id=@tekid and Sklad=@Sklad and Hitag=@Hitag and Locked=0),0) as int);
    set @AlienZakaz=cast(isnull((select sum(Qty) from Zakaz where tekid=@tekid),0) as int);
    set @Ostat=round(@Ostat-@AlienZakaz,0); 
   
    if (@Ostat>0) begin
      set @Cost = (select Cost from tdVi where id=@tekid); 
      set @Price = (select Price from tdVi where id=@tekid); 

      set @Ag_id = (select d.Ag_id from DefContract d where d.DCK=@DCK);

      set @Reg_id = (select d.Reg_ID from Def d where d.pin=@B_ID);   
      set @Sv_id = (select a.sv_ag_id from agentlist a where a.ag_id=@Ag_ID);   
      set @DepID = (select s.DepID from agentlist s where s.ag_id=@Ag_id);     
      --**********НАЦЕНКИ*************
      set @MinExtra = (select n.MinEXTRA from nomen n where hitag=@hitag); 
      set @DisMinExtra = (select d.DisMinExtra from Def d where d.pin=@B_ID);   
      
      set @Extra = ISNULL((select Extra from MtMainExtra
                           where (ag_id=@Ag_id or sv_id=@Sv_id or DepID=@DepID) and 
                          (Hitag=@Hitag or Ngrp=@Ngrp or Ncod=@Ncod)),0)       
      if @Extra <> 0 
      begin
        set @Price = (1+@Extra/100)*@Cost;
      end
      else
      begin
        set @Extra = isnull((select m.Extra from MtExtra m where m.B_ID=@B_ID and m.Hitag=@Hitag and m.Actual=1 and GETDATE()>=BegDate and GETDATE()<=EndDate),0);
        if @Extra <> 0 set @Price = (1+@Extra/100)*@Price;   
      end; 
      if (@DisMinExtra <> 1) and (@Price < ((1+@MinExtra/100)*@Cost)) and (@MinExtra<>0) 
        set @Price = ((1+@MinExtra/100)*@Cost)   
      --***************************** 
      --********ГРУППА ДОСТАВКИ****** 
      set @DelivGroup = isnull((select g.DelivGr from DelivGroups g where g.Reg_id=@Reg_id and g.SkladNo=@Sklad and g.DayOfWeek = DatePart(dw,GETDATE())),0)
      --*****************************
      
      --********АВТОЗАКАЗ************ 
      if (@DepID = 555) /*or
         (@DepID = 1 and @Hitag in (15797,15906,13497,15134,15146,21113,11524,14862) and Exists (select nom from frizer where b_id=@B_ID and ffid=2))*/
      
      /*Exists (select a.* from agentlist a
      where a.DepID=3 and a.ag_id not in (9,36,68,90,91,97,102) and a.ag_id=@Ag_id)*/
      begin
        set @TekND = CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))      
        
        set @Datnom1 = dbo.InDatnom(0, @TekND-21)
        set @Datnom2 = dbo.InDatnom(9999, @TekND)
        
        set @Prognoz=isnull((select sum(nv.kol) from nv join nc on nv.datnom=nc.datnom
                             where nc.Datnom between @Datnom1 and @Datnom2 and nc.b_id=@B_ID 
                                   and nv.Hitag=@Hitag),0)*3/21 - isnull((select qty from Rests where pin=@B_ID and ND>=@TekND),0)
                        
        if @Qty < 1.2*@Prognoz
        begin
          insert into AutoOrder (ND,b_id,hitag,Qty,QtyAdd,Prognoz) 
                 values (GETDATE(), @B_ID, @Hitag, @Qty, Round(1.2*@Prognoz,0)-@Qty, Round(1.2*@Prognoz,0));
          set @Qty = Round(1.2*@Prognoz,0);   
        end 
      end;
      --*****************************
      if @Ostat <= @Qty
      begin
        set @SavedZakaz=@Ostat
        if @Ostat < @Qty
        begin
          declare @SkladOpt int, @SkladRozn int, @SkladAccum int, @SkladLock int     
          set @SkladOpt=isnull((select sum(morn-sell+isprav-remov-bad) from tdvi where hitag=@hitag and locked=0 and sklad in (select skladno from skladlist where onlyminp=1 and discard=0 and locked=0)),0) -
                       ISNULL((select sum(qty) from Zakaz where hitag=@hitag),0)     
          set @SkladRozn=isnull((select sum(morn-sell+isprav-remov-bad) from tdvi where hitag=@hitag and locked=0 and sklad in (select skladno from skladlist where onlyminp=0 and discard=0 and locked=0)),0) -
                       ISNULL((select sum(qty) from Zakaz where hitag=@hitag),0)
          set @SkladAccum=isnull((select sum(morn-sell+isprav-remov-bad) from tdvi where hitag=@hitag and locked=0 and sklad in (select skladno from skladlist where discard=0 and locked=1)),0) -
                       ISNULL((select sum(qty) from Zakaz where hitag=@hitag),0)
          set @SkladLock=isnull((select sum(morn-sell+isprav-remov-bad) from tdvi where hitag=@hitag and locked=1 and sklad in (select skladno from skladlist where discard=0 and locked=0)),0) -
                       ISNULL((select sum(qty) from Zakaz where hitag=@hitag),0)                   
          insert into NotSat (ND, TM, OP, B_ID, AG_ID, NCOD, HITAG, SKLAD, QTY, PRICE, COST, tekid, ves, SkladOpt, SkladRozn, SkladAccum, SkladLock)
                      values (CONVERT([varchar],getdate(),(104)), CONVERT([varchar],getdate(),(8)), @Op, @B_id, @Ag_id, @Ncod, @Hitag, 
                              @Sklad, @Qty - @Ostat, @Price, @Cost, @Tekid, 0, @SkladOpt, @SkladRozn, @SkladAccum, @SkladLock)
        end;                    
  
      end;
      else set @SavedZakaz=@Qty;

      if @Force_ag_id>0 set @ag_id=@Force_ag_id;
      if @SavedZakaz > 0 insert into Zakaz(CompName,Hitag,Tekid,Qty,Sklad,Price,EffWeight,Cost,Nds,DelivGroup, Ag_Id, B_ID, OrdStick, DCK, StfNom, StfDate, DocNom, DocDate) 
      values (@CompName,@Hitag,@Tekid,@SavedZakaz,@Sklad,@Price,@EffWeight,@Cost,@Nds,@DelivGroup, @Ag_Id, @B_ID, @OrdStick, @DCK, @StfNom, @StfDate, @DocNom, @DocDate)

    end; else set @SavedZakaz=0;
  end; else set @SavedZakaz=0;  
  select @SavedZakaz;
end;