CREATE procedure SaveTaraDet @ForceSave bit, @nd datetime, @tm varchar(8), @b_id int,
  @nnak int,
  @sellDate datetime, @datNom int, @act varchar(2), @taratip tinyint,
  @kol int, @price money, @op smallint, @naktip tinyint, @tarid int,
  @remark varchar(60)
as 
declare
@tdid int
begin
  if (@ForceSave=1) 
  insert into TaraDet(nd,tm,b_id,nnak,sellDate,datNom,act,taraTip,kol,price,op,nakTip,tarId,remark)
  values(@nd,@tm,@b_id,@nnak,@sellDate,@datNom,@act,@taraTip,@kol,@price,@op,@nakTip,@tarId,@remark);
  
  else begin
    set @tdid=(select min(tdid)  from TaraDet where datNom=@datNom and taratip=@taratip and act=@act);
  
    if (@tdid>0) update TaraDet set Kol=@Kol, Price=@price, Remark=@Remark where tdid=@tdid;
    else insert into TaraDet(nd,tm,b_id,nnak,sellDate,datNom,act,taraTip,kol,price,op,nakTip,tarId,remark)
    values(@nd,@tm,@b_id,@nnak,@sellDate,@datNom,@act,@taraTip,@kol,@price,@op,@nakTip,@tarId,@remark);
  end;
  
end;