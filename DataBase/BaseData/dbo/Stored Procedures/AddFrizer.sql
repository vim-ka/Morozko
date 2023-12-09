CREATE procedure AddFrizer
  @NewComman bit, @Tip tinyint, @InvNom varchar(20), @FabNom varchar(15), @Nname varchar(60),
  @Ncod int, @DatePost datetime, @OurId tinyint,
  @Ob float, @Korzin smallint, @Zamok tinyint, @Sticker varchar(3),
  @Remark varchar(20),  @Price money, @Cost money, @FNCom int, @SkladNo smallint,
  @Procreator varchar(20), @NCountry int, @fsID smallint, @mID smallint,@ffid int,@CondID int, @FMod int
as
begin
  
  insert into Frizer (Tip,InvNom,FabNom,Nname,Ncod,DatePost,OurID,Ob,Korzin,
    Zamok,Sticker,Remark,Price,Cost,Ncom,SkladNo,Procreator,NCountry,fsID,mID,b_id, StartPrice, ffid, CondID, FMod) 
  values (@Tip,@InvNom,@FabNom,@Nname,@Ncod,@DatePost,@OurID,@Ob,@Korzin,
    @Zamok,@Sticker,@Remark,@Price,@Cost,@FNcom,@SkladNo,@Procreator,@NCountry,@fsID,@mID,0,@Price,@ffid,@CondID, @FMod) 
  if @NewComman = 1
  begin
    insert into FrizInpDet (Nom,Tip,InvNom,FabNom,Nname,ND,Ob,Korzin,
      Zamok,Remark,Price,Cost,FNcom,SkladNo,Procreator,NCountry,fsID,mID,ffid, CondID, FMod) 
    values (SCOPE_IDENTITY(), @Tip,@InvNom,@FabNom,@Nname,@DatePost,@Ob,@Korzin,
      @Zamok,@Remark,@Price,@Cost,@FNcom,@SkladNo,@Procreator,@NCountry,@fsID,@mID, @ffid, @CondID, @Fmod)
  end     
end