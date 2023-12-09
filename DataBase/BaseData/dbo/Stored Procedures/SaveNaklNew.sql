CREATE procedure SaveNaklNew
  @CompName varchar(30), @B_ID int, @Fam varchar(30),
  @Our_ID smallint=null, @Ag_ID smallint=null, @OP smallint,  @Srok int=null, 
  @Pko bit,  @Man_ID int, @tovchk bit=null,  @remark varchar(50),  @Actn bit, 
  @Ck bit, @Tomorrow bit, @RefDatNom int=0, @Frizer bit=0, @DatNom int=0 out, 
  @DayShift tinyint=0,  @RemarkOp varchar(50)='',  @OrderDate  datetime=null, 
  @OrderDocNumber varchar(35)='', @DCK int=0, @B_ID2 int=0, @NeedDover bit=0, 
  @Stip tinyint=0, @Tara bit=0, @flgRezerv bit=0
as 
 declare @DelivGroup INT,  @Box int, @TekId int, @RefTekId int, @NewTekId int, @Nds int
 declare @Extra decimal(7,2), @RetExtra decimal(7,2)
 declare @ND datetime, @SourDate datetime, @TM char(8), @Stfdate datetime, @DocDate datetime
 declare @StfNom varchar(17), @DocNom varchar(10), @SourNnak int
 declare @Qty decimal(10,3), @BoxQty decimal(9,2), @Weight decimal(9,2), @SP decimal(10,2), @SC decimal(10,2), @price decimal(14,4)
 declare @TaraAct char(2)
 declare @Nnak int
 declare @KolError int
 declare @Marsh int, @Sklad int
 declare @Sk50present bit, @EffWeight float, @Cost money
 declare @RemarkKassa varchar(50), @RemarkKassa2 varchar(20)
 
 begin
  if @RefDatNom>0 select @stip=c.stip, @dck=c.dck, @RetExtra=c.extra from nc c where c.datnom=@RefDatNom;
  if @dck>0 
    select @b_id=dc.pin, @ag_id=dc.ag_id, @our_id=dc.Our_id, @srok=dc.srok 
    from defcontract dc where dc.DCK=@dck;-- and dc.ContrTip=2;

  if @b_id>0 set @tovchk=(select tovchk from def where pin=@b_id);
  
  -- if isnull(@B_ID,0)=0 set @B_ID=(select pin from DefContract where DCK=@DCK)  
  -- if isnull(@ag_id,0)=0 set @Ag_ID=(select ag_id from Defcontract where dck=@dck);

  if (@Remarkop='') or (@Remarkop like '%}%') set @Remarkop=right(@remark, len(@remark)-CHARINDEX('}', @remark));
  
  set @KolError = 0 
  if @RefDatNom is null or @Refdatnom=0 set @TaraAct='ТП'; else set @TaraAct='ТВ';
  if @Tomorrow=0 set @DayShift=0; else if @Tomorrow=1 and @DayShift=0 set @DayShift=1;
  
  if EXISTS(select worker from Def where pin=@B_ID and worker=1) set @Marsh=99; else set @Marsh=0;
  
   
  -- Заказ содержится в табл. ZAKAZ, естественно. 
  
  set @ND=dbo.today();
  set @TM=convert(char(8), getdate(),108);
  if EXISTS(select * from Zakaz where CompName=@CompName) begin
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    
      declare CurDeliv2 cursor fast_forward  
      for select distinct DelivGroup,MainExtra,StfDate, Stfnom, DocNom, DocDate from Zakaz where Compname=@CompName order by DelivGroup;
      
      open CurDeliv2; 
      fetch next from CurDeliv2 into @DelivGroup,@Extra,@StfDate,@StfNom, @DocNom, @DocDate;
      
      WHILE (@@FETCH_STATUS=0)  BEGIN
        fetch next from CurDeliv2 into @DelivGroup,@Extra,@StfDate,@StfNom, @DocNom, @DocDate;
        select @StfNom;
        --insert into Log_temp(mess,DatNom) VALUES('DelivGroup=',@DelivGroup);	
        -- Проход по списку накладных:   
        set @BoxQty=(SELECT(sum(z.Qty/VI.minp/vi.mpu)) BoxQty 
            from Zakaz z inner join tdVi vi on vi.id=z.tekid 
            where z.CompName=@CompName and z.DelivGroup=@DelivGroup 
            and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom);
        set @Weight=(SELECT(sum(Qty*effWeight)) from Zakaz 
             where CompName=@CompName and DelivGroup=@DelivGroup 
             and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom);
        set @SP=(1.0+isnull(@Extra,0)/100.0)*(select sum(Price*Qty) from Zakaz 
            where CompName=@CompName and DelivGroup=@DelivGroup
            and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom);
        set @SC=(select sum(z.Cost*z.Qty) from Zakaz z where z.CompName=@CompName and z.DelivGroup=@DelivGroup
            and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom);
        set @datnom=1+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));
--        insert into Log_temp(mess,DatNom) VALUES('   Виктор,',@DatNom);	
--        insert into Log_temp(mess,DatNom) VALUES('   Виктор, StfNom=',@stfnom);	
      end;
    /*


        select @StfNom;
        --insert into Log_temp(mess,DatNom) VALUES('DelivGroup=',@DelivGroup);	
        -- Проход по списку накладных:   
                   
        set @BoxQty=(SELECT(sum(z.Qty/VI.minp/vi.mpu)) BoxQty 
            from Zakaz z inner join tdVi vi on vi.id=z.tekid 
            where z.CompName=@CompName and z.DelivGroup=@DelivGroup 
            and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom);
        set @Weight=(SELECT(sum(Qty*effWeight)) from Zakaz 
             where CompName=@CompName and DelivGroup=@DelivGroup 
             and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom);
        set @SP=(1.0+isnull(@Extra,0)/100.0)*(select sum(Price*Qty) from Zakaz 
            where CompName=@CompName and DelivGroup=@DelivGroup
            and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom);
        set @SC=(select sum(z.Cost*z.Qty) from Zakaz z where z.CompName=@CompName and z.DelivGroup=@DelivGroup
            and isnull(mainextra,0)=isnull(@extra,0) and stfnom=@stfnom);
        set @datnom=1+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));

        insert into Log_temp(mess,DatNom) VALUES('   Виктор, New Datnom=',@DatNom);	
        insert into Log_temp(mess,DatNom) VALUES('   Виктор, StfNom=',@stfnom);	

        if @@Error<>0 set @KolError=@KolError + 1;
        -- Переход к следующей накладной в списке:
      fetch next from CurDeliv2 into @DelivGroup,@Extra,@StfDate,@StfNom, @DocNom, @DocDate;
    end;
    */
    
    close CurDeliv2;
    deallocate CurDeliv2;      
    
    --  delete from Zakaz where Compname=@CompName;     
    select @Datnom;
  end;
end;