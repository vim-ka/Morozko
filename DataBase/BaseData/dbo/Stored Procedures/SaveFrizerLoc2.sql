CREATE procedure SaveFrizerLoc2 
  @ND datetime, @p0 int, @p1 int, @Nom int
as
begin
  if (@p0=0) -- расход от нас клиенту
    insert into FrizerLoc2(b_id,Nom,day0,day1) values (@p1,@Nom,@ND,'20991231' )
  else -- нет, не от нас, от кого-то из клиентов
  if (@p1=0) begin -- возврат тары от клиента к нам:
    if exists(select * from FrizerLoc2 where Nom=@Nom and b_id=@p0 and day1='20991231') 
    update FrizerLoc2 set Day1=@ND-1 where Nom=@Nom and b_id=@p0 and day1='20991231'
    else insert into FrizerLoc2(b_id,Nom,day0,day1) values (@p0,@Nom,'20000101',@ND-1)
  end else begin -- перемещение от кого-то из клиентов к другому клиенту
   -- Добавляю сразу эту позицию другому клиенту:
   insert into FrizerLoc2(b_id,Nom,day0,day1) values (@p1,@Nom,@ND,'20991231');
   -- А была у предыдущего клиента эта позиция?
    if exists(select * from FrizerLoc2 where Nom=@Nom and b_id=@p0 and day1='20991231') 
    update FrizerLoc2 set Day1=@ND-1 where Nom=@Nom and b_id=@p0 and day1='20991231'
    else insert into FrizerLoc2(b_id,Nom,day0,day1) values (@p0,@Nom,'20000101',@ND-1)
  end;
END