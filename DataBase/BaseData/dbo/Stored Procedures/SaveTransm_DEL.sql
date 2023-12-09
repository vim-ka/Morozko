

-- Переделка (полная или частичная) товара в какой-то другой товар.
CREATE procedure SaveTransm_DEL
  @Id int, @Kol decimal(12, 3), @NewKol decimal(12, 3), 
  @NewPrice money,  @NewCost money, @NewHitag int, 
  @Op int, @NewSklad tinyint, @MinP int, @Mpu int, @Sert_ID int,
  @Remark varchar(40), @Comp varchar(16), @Weight decimal(12,3),
  @DCK int, @NewId int out, @NewNcod int=0
as
declare @Ncod int, @Ncom int, @Price money, @Cost money, @Sklad tinyint
declare @Hitag int, @serialNom int

begin
  begin TRANSACTION

  set @SerialNom=(select max(E.SerialNom)+1 from (select top 1000 SerialNom from izmen order by izmid DESC) as E);

  select 
    @Hitag=Hitag, @Ncod=ncod, @Ncom=Ncom, @Price=Price, 
    @Cost=Cost, @Sklad=Sklad,  @Dck=dck
  from TDVI where id=@ID

  set @NewId=(select max(id) from tdVi)+1

  insert into tdIZ(act,id,newid,kol,newkol,price,newprice,cost,newcost, SerialNom,
    ncod,ncom,op,sklad,newsklad,remark,printed,comp,dck, hitag, newhitag)
  values('Tran',@id,@newid,@kol,@newkol,@price,@newprice,@cost,@newcost, @SerialNom,
    @ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@dck, @hitag, @newhitag);
  
  insert into Izmen(act,id,newid,kol,newkol,price,newprice,cost,newcost,SerialNom,
    ncod,ncom,op,sklad,newsklad,remark,printed,comp,dck, hitag, newhitag)
  values('Tran',@id,@newid,@kol,@newkol,@price,@newprice,@cost,@newcost,@SerialNom,
    @ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@dck, @hitag, @newhitag);
  
  insert into tdVi(nd,id,startid,ncom,ncod,datepost,price,start,startthis,
    hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
    remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
    gtd, vitr, our_id, weight,dck)
  select
    CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0)) as ND,
    @newid, v.startid, @Ncom, @NewNcod, datepost, @NewPrice, 0,0,
    @NewHitag, @NewSklad, @NewCost, 0, @MinP, @Mpu, @Sert_Id, '5', 0,0,@NewKol,
    0,0,v.dater, v.srokh, v.country, 0, v.units, v.locked, v.ncountry,
    v.gtd,0,v.our_id, @Weight, @Dck
  from tdvi v
  where v.ID=@ID;
  
  update tdvi set Isprav=isnull(Isprav,0)-@Kol where id=@id;

  commit;  
end