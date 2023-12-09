CREATE procedure dbo.SaveBackNvZakaz @OrigDatNom int, @OP smallint, @ErrCode int out
-- Код ошибки: 1 - нечего вернуть в заявку;
--   2 - не удалось создать возвратную накладную;
--   4 - не удалось записать кассовую операцию

as 
declare @CompName varchar(30), @B_ID int, @B_ID2 int, @Fam varchar(35), @NcDCK int, @NCID int, @Nnak int,
  @Extra decimal(6,2), @Srok int, @TovChk tinyint, @ag_ID int, @Our_ID int, @gpOur_ID int,
  @StartDatnom int, @backdatnom int, @ND datetime, @Stip int, @TM char(8), @oldB_id2 INT,
  @TekId int, @Hitag int, @Sklad int, @Price money, @BasePrice money, @Cost money, @OrigPrice money, 
  @OldSP decimal(12,2),@OldSC decimal(12,2), @NewSP decimal(12,2),@NewSC decimal(12,2),
  @Newkol decimal(10,3), @Tip smallint, @Meas smallint, @DelivCancel bit, @UpWeight bit, @flgWeight bit, @Actn bit
begin
  set @ErrCode=0;
  set @NCID=0; -- это для журнала изменений

  if not exists(select * from nvzakaz Z inner join NV on NV.datnom=Z.datnom and NV.TekID=Z.ID where Z.datnom=@OrigDatnom and Z.Done=1 and nv.kol>nv.kol_b)
    set @ErrCode=1; -- нечего вернуть.
  else begin -- есть что вернуть:

    set @CompName=HOST_NAME();
    set @ND = dbo.today();
    set @TM = convert(char(8), getdate(),108);
    set @Nnak = dbo.InNnak(@OrigDatNom);

    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    begin transaction
      select @Ag_ID=ag_id,  @StartDatnom=StartDatnom, @B_ID=b_id,@B_ID2=b_id2, @Fam=Fam, @NcDCK=DCK, 
        @Our_ID=OurID, @gpOur_iD=gpOur_ID, @Stip=Stip, @OldSP=SP, @OldSC=SC,
        @Extra=Extra, @Srok=Srok, @TovChk=nc.Tovchk, @Actn=Actn
      from NC where Datnom=@Origdatnom;
      
      -- Заголовок возвратной накладной:
      set @backdatnom=1+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));
      
      insert into NC (ND,datnom,StartDatnom,B_ID,B_ID2,Fam,Tm,OP,SP,SC,
        Extra,Srok,OurID,Pko,Man_ID, 
        BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
        Remark,Printed,Marsh,BoxQty,WEIGHT,Actn,CK,Tara,
        RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift, Comp, DCK, Stip,gpOur_iD)
      values (@ND,@backdatnom, @StartDatnom, @B_ID, @B_ID2,  @Fam,@TM,@OP,0,0, -- суммы потом пересчитаем
        @Extra,@Srok,@Our_ID, 0, 0, 
        0,@TovChk, 0, @ag_id, null, @nd,0,0,
        '',0,0,-1,-1, 0,0,0,  -- Actn=0; Box и Weight пока неизвестны     
        @OrigDatNom,0,0, 1, 0.0, '', 0, @CompName, @NcDCK, @Stip,@gpOur_iD);
      if @@Error<>0 set @ErrCode = @ErrCode | 2;

      -- Детализация возвратной накладной:
      if @ErrCode=0 BEGIN
        
        declare CurBack cursor fast_forward  
        for select 
          nv.Tekid,nv.Hitag,nv.Price,nv.Cost,nv.Kol-nv.Kol_B as NewKol,
          nv.Sklad,nv.BasePrice,nv.tip,nv.Meas,nv.DelivCancel, s.UpWeight, nm.flgWeight, nv.OrigPrice
        from 
          Nvzakaz z
          inner join NV on nv.datnom=z.datnom and nv.TekID=z.id
          inner join skladlist s on nv.Sklad=s.skladno
          inner join nomen nm on nv.hitag=nm.hitag
        where z.Datnom=@OrigDatnom and z.done=1 and nv.kol>nv.kol_b;

        open CurBack; 
        fetch next from CurBack into @Tekid, @Hitag, @Price, @Cost, @NewKol, @Sklad, @BasePrice, @Tip, @Meas, @DelivCancel, @UpWeight, @flgWeight, @OrigPrice;
        WHILE (@@FETCH_STATUS=0) BEGIN

          if @NCID=0 -- Самый первый раз, подготовка записи в журнал изменений NC_Edit, NV_Edit:
          begin
            Exec SaveNcEdit @Nnak, @OrigDatNom, @B_ID, @Fam, @Op, @OldSP, @OldSC,
                 0, 0, 1, @Extra, @Srok, 0, 0.0, @Our_Id,   @NCID, @NcDCK, @NcDCK; -- суммы потом уточним
            -- Черт ее знает почему, процедура не обновляет @NCID. Придется руками:
            if @NCid=0 set @NCid=(select top 1 ncid from ncedit where Op=@Op order by ncid desc);
            print('@NCID = '+cast(@ncid as varchar));
          end;

          -- Втыкаем строку в новую возвратную накладную:
          insert into NV(DatNom, tekid, hitag, price, cost, kol, kol_b, sklad, baseprice, tip, Meas,DelivCancel, OrigPrice)
          values(@BackDatNom, @tekid, @hitag, @price, @cost, -@newkol, 0, @sklad, @baseprice, @tip, @Meas,@DelivCancel, @OrigPrice)
          -- правим исходную строку в таблице детализации продаж:
          update nv set kol_b=kol_b+@newkol where datnom=@OrigDatNom and tekid=@tekid;

          -- Втыкаем строку в склад, если там нет подходящей:
          if not exists(select * from tdvi where id=@tekid) begin
            SET IDENTITY_INSERT tdvi ON; -- отключаю автоинкремент.
            insert into tdvi(Nd,id,startid,ncom,ncod,datepost,price,start,startthis,
              hitag,sklad,cost,minp,mpu,sert_id,rang,morn,sell,isprav,remov,Bad,
              dater,srokh,country,rezerv,units,locked,Ncountry,Gtd,Vitr,Our_ID,
              WEIGHT,SaveDate,MeasID,OnlyMinP, DCK, ProducerID, CountryID, pin)
    	      select @Nd as ND,id,startid,ncom,ncod,datepost,price,start,0 as StartThis,
              hitag,sklad,cost,minp,mpu,sert_id,rang,0 as morn,0 as sell,0 as isprav,0 as remov,0 as Bad,
              dater,srokh,country,0 as rezerv,units,0 as locked,Ncountry,Gtd,0 as Vitr,Our_ID,
              WEIGHT,@ND as SaveDate,MeasID,0 as OnlyMinP, DCK, ProducerID, CountryID, pin
            from Visual where id=@tekid;
            SET IDENTITY_INSERT tdvi OFF; -- включаю автоинкремент.
          end;
          
          -- правим продажу в складе:
          update tdvi set sell=sell-@newkol where id=@tekid;

          -- пишем в журнал:
          if @NCiD>0 exec SaveNvEdit @Ncid, @Nnak, @Origdatnom, @TekID, @Hitag, @Price, @Cost, 0, @NewKol, 0, @Sklad, @Price, @Op;

          fetch next from CurBack into @Tekid, @Hitag, @Price, @Cost, @NewKol, @Sklad, @BasePrice, @Tip, @Meas, @DelivCancel, @UpWeight, @flgWeight, @OrigPrice;
        end;
        close CurBack;
        DEALLOCATE CurBack;
      end;

      if @ErrCode=0 begin
        exec dbo.RecalcNCSumm @BackDatnom; -- пересчет суммы
        select @NewSP=-SP, @NewSC=-SC from NC where Datnom=@BackDatnom; -- @NewSP>0
        update NCEdit set NewSC=@NewSC, NewSP=@NewSP where NCid=@NCID;

        update NvZakaz set Done=0,ID=0 where Datnom=@OrigDatnom and Done=1; -- сбрасываю Done для всех вообще строк, даже для отмененных кладовщиком
        if (@Actn=0) begin
      	  insert into Kassa1(Nd,TM,
            Oper,Act,SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
            remark, RashFlag,LostFlag,LastFlag,
            Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
            ForPrint, SourDatNom, DCK)
    	  values(
    	    @ND, @TM,
    	      -2,'ВО', dbo.DatNomInDate(@OrigDatNom), dbo.innnak(@OrigDatNom),@NewSP, @Fam, 0, @B_ID,0,0,
            'Возврат. См. накладную '+cast(dbo.inNnak(@backdatnom) as varchar(4))+' от '+convert(char(8), getdate(),4),
            0,1,0,
            @Op,0,@Our_ID,@ND,0,0,
            0, @OrigDatNom, @NcDCK);
          if @@Error<>0 set @ErrCode=@ErrCode | 4;

      	  insert into Kassa1(Nd,TM,
              Oper,Act,SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
              remark, RashFlag,LostFlag,LastFlag,
              Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
              ForPrint, SourDatNom, DCK)
      	  values(
      	      @ND, convert(char(8), getdate(),108),
      	      -2,'ВО', dbo.DatNomInDate(@backdatnom), dbo.innnak(@backdatnom),-@NewSP, @Fam, 0, @B_ID,0,0,
              'Возврат накладной #'+cast(dbo.inNnak(@OrigDatNom) as varchar(4))+' от '+convert(char(8), dbo.DatNomInDate(@OrigDatNom),4),
              0,1,0,
              @Op,0,@Our_ID,@ND,0,0,
              0, @backdatnom, @NcDCK);
          if @@Error<>0 set @ErrCode=@ErrCode | 4;
        end;
      end;

    if @ErrCode=0 commit; else rollback;
  end;  
end