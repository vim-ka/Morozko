CREATE procedure SaveDailyDiscard
  @tekid int, @op int, @datnom int, @qty int
as
declare @today datetime
declare @cnt int
declare @lok bit
declare @hitag int
declare @rest int
begin
  insert into DailyDiscard(tekid,op,datnom,qty) values(@tekid,@op,@datnom,@qty);
  set @today=convert(varchar(10), getdate(), 112);
  set @cnt=(select count(*) from DailyDiscard where Nd=@today and tekid=@tekid );
  if @cnt=100 begin -- блокировка после сотого вычерка
    set @lok=(select locked from tdvi where id=@tekid);
    if @lok=0 begin
      set @hitag=(select Hitag from tdvi where id=@tekid);
      set @rest=(select morn-sell+isprav-REMOV from tdvi where id=@tekid);
      update tdvi set locked=1 where id=@tekid;
      update visual set locked=1 where id=@tekid;

      insert into Log(Nd,TM,OP,Tip,Mess,param1,param2,param3,Comp, Remark)
      values(@today,convert(char(8), getdate(),108),
        @Op,'Блок','100 вычерков за день',
        @hitag,
        @Tekid,
        @rest,
        null,
        null
        );
    end;
  end;
end;