create procedure ReadOrCreateSalarySvis
  @yy int, @mm int, @svid int
as begin
  if not exists(select * from SalarySvis where yy=@yy and mm=@mm and svid=@svid)
  insert into SalarySvis(yy,mm,svid) values(@yy,@mm,@svid);
  
  select KPremDeb, PremTT,PremAG,KPremAg,Oklad,[Add] 
  from SalarySvis
  where yy=@yy and mm=@mm and svid=@svid;
end;