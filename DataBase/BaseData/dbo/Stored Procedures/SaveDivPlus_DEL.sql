

CREATE procedure SaveDivPlus_DEL 
  @NewHitag int, @Ncom int, @Ncod int, @Datepost datetime,
  @Price money, @Qty decimal(12,3), @Sklad int, @Cost money,
  @MinP int, @Mpu int, @Sert_ID int, @rang char(1),
  @DateR datetime, @Srokh datetime, @Country varchar(15),
  @Units varchar(3), @Locked bit, @Ncountry int,
  @Gtd varchar(23), @our_ID smallint, @NewWeight decimal(12,3),
  @Op int, @remark varchar(40), @printed bit, @comp varchar(16),
  @newID int out, @SerialNom int=0, @Dck int=0, @OldID int=0, @DivFlag bit=null, 
  @Hitag int=0, @Weight decimal(12,3)=0 
as
declare @ND datetime

begin
  set @ND=convert(char(10),getdate(),104)
  if @DateR<'20000101' set @Dater=null;
  if @Srokh<'20000101' set @Srokh=null;
  
  begin transaction

  set @NewId=1+(select max(ID) from tdVi);

  insert into tdVi(nd,id,startid,ncom,ncod,datepost,price,start,startthis,
      hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
      remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
      gtd, vitr, our_id, weight, dck)
  values(@nd, @newid,@newid,@ncom,@ncod,@datepost,@price,@qty,@qty,
      @newhitag, @sklad, @cost, 0, @minp, @mpu, @sert_id, @rang, @qty, 0,0,
      0,0, @dater, @srokh, @country, 0, @units, @locked, @ncountry,
      @gtd, 0, @our_id, @newweight, @dck); 
   
    insert into tdIZ(act,id,newid,kol,newkol,price,newprice,cost,newcost,ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom, dck, DivFlag, Hitag, NewHitag, Weight, NewWeight)
      values('div+',@oldid,@newid,0,@qty,@price,@price,@cost,@cost,@ncod,@ncom,@op,@sklad,@sklad,@remark,@printed,@comp,@SerialNom, @dck, @DivFlag, @Hitag, @NewHitag, @Weight, @NewWeight);
    

    insert into izmen(act,id,newid,kol,newkol,price,newprice,cost,newcost,ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom, dck, DivFlag, Hitag, NewHitag, Weight, NewWeight)
      values('div+',@oldid,@newid,0,@Qty,@price,@price,@cost,@cost,@ncod,@ncom,@op,@sklad,@sklad,@remark,@printed,@comp,@SerialNom, @dck, @DivFlag, @Hitag, @NewHitag, @Weight, @NewWeight);

  commit;
  select @NewId;
end