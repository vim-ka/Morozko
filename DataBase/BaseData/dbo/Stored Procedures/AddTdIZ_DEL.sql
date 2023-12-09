

CREATE procedure AddTdIZ_DEL @nd datetime, @tm char(8), @Act char(4), @ID int,
  @NewId int, @Kol decimal(12, 3), @NewKol decimal(12, 3), @Price money,
  @NewPrice money, @Cost money, @NewCost money, @Ncod int, @Ncom int,
  @Op int, @Sklad tinyint, @NewSklad tinyint, @Remark varchar(40),
  @Printed bit,  @Comp varchar(16), @SerialNom int=0 out, @dck int=0, @irID int=0, @DivFlag bit=null,
  @Weight decimal(12,3)=0, @NewWeight decimal(12,3)=0, @ServiceFlag bit=0
as
declare @startid int
declare @sert_id int
declare @datepost datetime
declare @start int
declare @startthis int
declare @hitag int, @NewHitag int
declare @nalog5 int
declare @minp int
declare @mpu INT
declare @rang char(1)
declare @morn int 
declare @sell int 
declare @dater datetime 
declare @srokh datetime
declare @country varchar(15)
declare @units varchar(3)
declare @locked bit
declare @ncountry int 
declare @gtd int 
declare @our_id int 
declare @baseprice money


begin
  begin TRANSACTION

  set @hitag=(select Hitag from TDVI where ID=@ID);
  if @Act in ('Снят','Скла','ИзмЦ','Испр','Div-','Div+')
  set @NewHitag=@Hitag; else set @NewHitag=null;

  
  if isnull(@SerialNom,0)=0
    set @SerialNom=(select max(E.SerialNom)+1 from (select top 1000 SerialNom from izmen order by izmid DESC) as E);
  
  insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,
    ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, hitag, irID, DivFlag, Weight,NewWeight, ServiceFlag)
  values(@nd,@tm,@act,@id,@newid,@kol,@newkol,@price,@newprice,@cost,@newcost,
    @ncod,@ncom,@op,@sklad,@newsklad,@remark,@printed,@comp,@SerialNom,@dck, @hitag, @irId, @DivFlag, @Weight,@NewWeight, @ServiceFlag);
  
  insert into Izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost, 
    ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, hitag,newHitag, irId, DivFlag, Weight,NewWeight, ServiceFlag)
  values(@nd,@tm,@act,@id,@newid,@kol,@newkol,@price,@newprice,@cost,@newcost,
    @ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@SerialNom,@dck,@hitag, @newhitag, @irId, @DivFlag, @Weight,@NewWeight, @ServiceFlag);
  
  if (@Act='Брак')  begin
    update Visual set Bad=Bad+@NewKol-@Kol where id=@id;
    update tdVi set Bad=Bad+@NewKol-@Kol where id=@id;
  end;
  
  if (@Ncom<0) and (not Exists(select * from comman where ncom=@Ncom))
  insert into Comman(ncom,ncod,comman.[DATE],comman.[time],summaprice,summacost,
    izmen,isprav,comman.[REMOVE],ostat,corr,plata,srok,our_id) 
  values(@ncom,@ncod, '20050101','08:00:00',0,0,0,0,0,0,0,0,100,7);

  if (@Act='ИзмЦ') and (@Cost<>@NewCost)
  update Comman set Izmen=Izmen+@NewCost*@NewKol-@Cost*@Kol where Ncom=@Ncom;

  if (@Act='ИзмЦ')  begin
    update Visual set Price=@NewPrice, Cost=@NewCost where id=@id;
    update tdVi   set Price=@NewPrice, Cost=@NewCost where id=@id;
    --update Nomen  set Price=@NewPrice, Cost=@NewCost where hitag=@Hitag;
		
		update nomen set price=(select max(round(i.price/iif(i.weight=0,1,i.weight),2)) from inpdet i where i.hitag=nomen.hitag
													and i.ncom=(select max(n.ncom) from inpdet n where n.hitag=nomen.hitag))
		where Nomen.hitag=@hitag
		
		update nomen set cost=(select max(round(i.cost/iif(i.weight=0,1,i.weight),2)) from inpdet i where i.hitag=nomen.hitag
													and i.ncom=(select max(n.ncom) from inpdet n where n.hitag=nomen.hitag))
		where Nomen.hitag=@hitag
  end;
  
  if (@Act='Испр')  begin
    update Visual set Isprav=Isprav+@NewKol-@kol where id=@id;
    update tdVi set Isprav=Isprav+@NewKol-@kol where id=@id;
  end;
  
  if (@Act='Снят') begin
    update Comman set Remove=Remove+@NewCost*@NewKol-@Cost*@Kol where Ncom=@Ncom;
    update Visual set Remov=Remov+@Kol-@Newkol where id=@id;
    update tdVi set Remov=Remov+@Kol-@Newkol where id=@id;
  end;
 
  if (@Act='Скла') and (@NewId=@id) begin
    update Visual set Sklad=@NewSklad where id=@id;
    update tdVi set Sklad=@NewSklad where id=@id;
  end;
  
  if (@Act='Скла') and (@NewId<>@id) begin
    declare Viscur cursor FAST_FORWARD for select startid,datepost,start,startthis,
    hitag,nalog5,minp,mpu,sert_id,rang,morn,sell,dater,srokh,country,units,locked,
    ncountry,gtd,our_id,WEIGHT,baseprice 
    from Visual where ID=@ID;
    
    OPEN Viscur;
    FETCH NEXT FROM Viscur into @startid,@datepost,@start,@startthis,
    @hitag,@nalog5,@minp,@mpu,@sert_id,@rang,@morn,@sell,@dater,@srokh,@country,@units,@locked,
    @ncountry,@gtd,@our_id,@WEIGHT,@baseprice;
    if (@dater=0) set @Dater=null;
    if (@srokh=0) set @Srokh=null;
    
    insert into Visual(id,startid,ncom,ncod,datepost,price,start,startthis,
      hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
      remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
      gtd, vitr, our_id, weight, baseprice,dck)
    values(@newid,@startid,@ncom,@ncod,@datepost,@price,@start,@newkol,
      @hitag, @newsklad, @newcost, @nalog5, @minp, @mpu, @sert_id, @rang, @newkol, 0,0,
      0,0, @dater, @srokh, @country, 0, @units, @locked, @ncountry,
      @gtd, 0, @our_id, @weight, @baseprice,@dck);
      
    insert into tdVi(nd,id,startid,ncom,ncod,datepost,price,start,startthis,
      hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
      remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
      gtd, vitr, our_id, weight,dck)
    values(@nd, @newid,@startid,@ncom,@ncod,@datepost,@price,@start,@newkol,
      @hitag, @newsklad, @newcost, @nalog5, @minp, @mpu, @sert_id, @rang, @newkol, 0,0,
      0,0, @dater, @srokh, @country, 0, @units, @locked, @ncountry,
      @gtd, 0, @our_id, @weight,@dck); 
    
	CLOSE Viscur;
	DEALLOCATE Viscur;

    update Visual set StartThis=StartThis-@Kol, Morn=Morn-@Kol where id=@id;
    update tdVi set StartThis=StartThis-@Kol, Morn=Morn-@Kol where id=@id;
  end;
  commit;  
end