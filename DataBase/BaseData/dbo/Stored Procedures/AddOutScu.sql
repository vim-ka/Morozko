create procedure AddOutScu
  @ND datetime,
  @b_id int,
  @hitag int
as
declare @Cnt int
begin
  set @Cnt=(select count(*) as Cnt from OutScu where Nd=@Nd and B_ID=@B_ID and Hitag=@hitag)
  if @cnt=0
    insert into OutScu(nd,b_id,hitag) values(@nd,@b_id,@hitag);
end