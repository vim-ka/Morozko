CREATE  procedure SaveTara
  @ND datetime, @Nnak int, @B_ID int, @naktip tinyint,
  @taratip tinyint, @kol int, @price money
as
declare @tarid int;
begin
  set @tarid = (select tarid from TaraMain where ND=@ND and b_id=@b_id);
  if (@tarid is null) begin
    insert into TaraMain(nd,b_id) values(@nd, @b_id);
    set @tarid=@@IDENTITY;
  end;

  if ((@naktip=0)and(@kol>0)) -- продажа рыбы, с которой связаны ведра:
  or ((@naktip=1)and(@kol<0)) -- возврат именно ведер
  or (@naktip=2)              -- списание долга по таре с покупателя
  or (@naktip=3)              -- возврат денег за вёдра
  begin
    if @taratip=1 update TaraMain set sell1=sell1+@kol where tarid=@tarid;
    else if @taratip=2 update TaraMain set sell2=sell2+@kol where tarid=@tarid;
    else if @taratip=3 update TaraMain set sell3=sell3+@kol where tarid=@tarid;
    else if @taratip=4 update TaraMain set sell4=sell4+@kol where tarid=@tarid;
    else if @taratip=5 update TaraMain set sell5=sell5+@kol where tarid=@tarid;
    else if @taratip=6 update TaraMain set sell6=sell6+@kol where tarid=@tarid;
    else if @taratip=7 update TaraMain set sell7=sell7+@kol where tarid=@tarid;
    else if @taratip=8 update TaraMain set sell8=sell8+@kol where tarid=@tarid;

    insert into DebugTaraDet(tarid, naktip,nnak,taratip,kol,price)
    values(@tarid, @naktip,@nnak,@taratip,@kol,@price);
    
  end;

end;