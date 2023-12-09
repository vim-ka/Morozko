CREATE procedure SaveNvEdit @Ncid int, @Nnak int, @Datnom int, @ID int, @Hitag int,
  @Price money, @Cost money, @Nalog5 tinyint, @Kol int, @NewKol int, @SkladNo smallint,
  @NewPrice money=null, @AddOp INT=null
as begin
  if @AddOp=-1 set @AddOp=null;
  insert into NvEdit(Ncid, Nd, Nnak, DatNom,Tm,Id,Hitag,Price,Cost,Nalog5,Kol,NewKol,SkladNo, NewPrice, AddOp)
  values(@Ncid, convert(char(10), getdate(),104), @Nnak, @DatNom, convert(char(8), getdate(),108),
    @Id,@Hitag,@Price,@Cost,@Nalog5,@Kol,@NewKol,@SkladNo, @NewPrice, @AddOp)
end