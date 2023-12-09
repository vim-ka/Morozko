CREATE procedure AddInpdet
  @ND datetime, @Ncom int,@Id int, @Hitag int, @Price money, @Cost money, @kol int, @Sert_id int,
  @minp int, @mpu int, @dater varchar(20), @srokh varchar(20), @nalog5 numeric(1,0), @op tinyint,
  @country varchar(15), @sklad tinyint, @kol_b int, @summacost money
as
begin
  if (@kol_b=0) set @kol_b=null; 
  --if (@doc_date<'19500101') set @doc_date=null;   
  --if (@origdate<'19500101') set @origdate=null;   

insert into InpDet (ND, Ncom, Id, Hitag, Price, Cost, kol, Sert_id, minp, mpu, dater,
  srokh, nalog5, op, country, sklad, kol_b, summacost)
values (@ND, @Ncom, @Id, @Hitag, @Price, @Cost, @kol, @Sert_id, @minp, @mpu, @dater,
  @srokh, @nalog5, @op, @country, @sklad, @kol_b, @summacost);
end