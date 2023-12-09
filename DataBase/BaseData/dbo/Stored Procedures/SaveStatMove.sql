-- Изменение статуса товара - программа A4
CREATE procedure dbo.SaveStatMove @ID int, @Qty int, @Op int, 
  @Remark varchar(40), @Printed bit,  @Comp varchar(16),
  @NewId int out, @NewWSID tinyint, @SerialNom int=0 out
as
declare @ND datetime
declare @TM char(8)
declare @Rest DEC(12,3), @BadRest DEC(12,3), @ncod int, @ncom int, @startid int, @sert_id int
declare @start DEC(12,3),@startthis DEC(12,3), @hitag int, @nalog5 int, @minp int, @mpu INT
declare @morn DEC(12,3), @sell DEC(12,3), @isprav DEC(12,3), @remov DEC(12,3), @bad DEC(12,3)
declare @TomorrowSell dec(12,3)
declare @locked bit
declare @datepost datetime, @dater datetime, @srokh datetime
declare @rang char(1),@country varchar(15),@units varchar(3)
declare @ncountry int, @gtd varchar(23), @our_id int, @sklad int 
declare @WEIGHT decimal(12,3)
declare @cost money, @price money
declare @FirstNakl int
declare @DCK int
declare @OldWsID tinyint

begin
  set @ND=convert(char(10),getdate(),104)
  set @TM=convert(char(8), getdate(),108)
  set @FirstNakl=dbo.InDatNom(1,@ND)
  
  begin transaction  
  
    if @SerialNom=0 set @SerialNom=(select max(E.SerialNom)+1 from (select top 300 SerialNom from izmen order by izmid DESC) as E);

    -- какой текущий остаток? весь и в т.ч. брак. И какой сейчас склад:
    declare Viscur cursor FAST_FORWARD for select startid,datepost,start,startthis,
      hitag,nalog5,minp,mpu,sert_id,rang,morn,sell,isprav,remov,bad,dater,srokh,country,units,locked,
      ncountry,gtd,our_id,WEIGHT,sklad, price, cost, ncod, ncom, dck, wsid
      from TDVI where ID=@ID;
    OPEN Viscur;
    FETCH NEXT FROM Viscur into @startid,@datepost,@start,@startthis,
      @hitag,@nalog5,@minp,@mpu,@sert_id,@rang,@morn,@sell,@isprav,@remov,@bad,@dater,@srokh,@country,@units,@locked,
      @ncountry,@gtd,@our_id,@WEIGHT,@sklad, @price, @cost, @ncod, @ncom, @DCK, @oldwsid;
    if (@dater=0) set @Dater=null;
    if (@srokh=0) set @Srokh=null;
    CLOSE Viscur;
    DEALLOCATE Viscur;

    -- Не отложен ли товар на завтра? Если отложен, его придется вычесть из текущих продаж
	set @TomorrowSell = isnull((select SUM(nv.kol) 
      from NV 
      inner join NC on NC.datnom=NV.datnom 
      where nv.DatNom>=@FirstNakl
      and nv.tekid=@ID
      and nc.Tomorrow=1),0)

    set @Rest=@morn-@sell+@isprav-@remov+@TomorrowSell -- это расчетный остаток 
      -- на момент сейчас, включая отложенный на завтра.

    
    -- Если нужно изменить состояние всего остатка целиком - то в табл. TDVI только wsid поменяется:
    if abs(@rest-@Qty)<0.001 begin
      update TDVI set wsid=@NewWsID where ID=@ID;    

      insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,ncod,ncom,op,sklad,newsklad,remark,printed,comp, SerialNom,dck, wsId, NewWsId)
        values(@nd,@tm,'Стат',@id,@id,@rest,@rest,@price,@price,@cost,@cost,@ncod,@ncom,@op,@sklad,@sklad,@remark,@printed,@comp,@SerialNom, @DCK, @OldwsId, @NewWsId);
      insert into izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, wsId, NewWsId)
        values(@nd,@tm,'стат',@id,@id,@rest,@rest,@price,@price,@cost,@cost,@ncod,@ncom,@op,@sklad,@sklad,@remark,@printed,@comp,@SerialNom, @DCK, @OldwsId, @NewWsId);
      set @NewId=@Id;
    end;
    else begin  -- Теперь - если появилась новая строка в tdVI:
      -- Старый вариант, до 10.10.16:
      /*
      set @NewId=1+(select max(ID) from tdVi);
      insert into tdVi(nd,id,startid,ncom,ncod,datepost,price,start,startthis,
        hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
        remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
        gtd, vitr, our_id, weight, DCK, wsid)
      values(@nd, @newid,@startid,@ncom,@ncod,@datepost,@price,@start,@Qty,
        @hitag, @sklad, @cost, @nalog5, @minp, @mpu, @sert_id, @rang, @Qty, 0,0,
        0,0, @dater, @srokh, @country, 0, @units, @locked, @ncountry,
        @gtd, 0, @our_id, @weight, @DCK, @newWsid); 
      */
      -- Новый вариант, 10.10.16:
      insert into tdVi(nd,startid,ncom,ncod,datepost,price,start,startthis,
        hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
        remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
        gtd, vitr, our_id, weight, DCK, wsid)
      values(@nd, @startid,@ncom,@ncod,@datepost,@price,@start,@Qty,
        @hitag, @sklad, @cost, @nalog5, @minp, @mpu, @sert_id, @rang, @Qty, 0,0,
        0,0, @dater, @srokh, @country, 0, @units, @locked, @ncountry,
        @gtd, 0, @our_id, @weight, @DCK, @newWsid); 
      set @newid=SCOPE_IDENTITY();
     
      insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, wsId, NewWsId)
        values(@nd,@tm,'Стат',@id,@newid,@Qty,@Qty,@price,@price,@cost,@cost,@ncod,@ncom,@op,@sklad,@sklad,@remark,@printed,@comp,@SerialNom,@dck, @oldwsId, @NewWsId);
      

      insert into izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, wsId, NewWsId)
        values(@nd,@tm,'Стат',@id,@newid,@Qty,@Qty,@price,@price,@cost,@cost,@ncod,@ncom,@op,@sklad,@sklad,@remark,@printed,@comp,@SerialNom,@dck, @oldwsId, @NewWsId);

      update TDVI set morn=Morn-@Qty, StartThis=StartThis-@Qty where ID=@ID;
    end;
  commit;
  select @NewId;
end