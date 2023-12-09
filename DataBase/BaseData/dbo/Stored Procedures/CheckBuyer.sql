CREATE procedure CheckBuyer @Pin integer, @Message varchar(200) OUT,
  @ErrCode int out, @Bonus bit=0 out, @Worker bit=0 out, @reg_ID char(2)='' out
as
declare @ss varchar(200), @Overdue decimal(12,2), @Disab bit, @Actual bit
begin
  set @errCode=0; 
  set @MESSAGE='';

  if exists(select * from config where param='skladblock' and VAL='1') begin
    set @Message=(select val  from config where param='MSGONSKLADBLOCK');
    set @errCode=1;
  end;
  else begin
    select @Disab=Disab, @Actual=Actual from Def where Pin=@Pin;
    if @Actual=0 begin
      set @Errcode=@ErrCode+2;
      set @Message='Покупатель закрыт';
    end;
    else if @Disab=1 begin
      set @ss=(select top 1 Comment from enablog where B_ID=@Pin and Enab=0 order by EID desc);
      set @Errcode=@ErrCode+4;
      set @Message='Покупатель заблокирован'
      if @ss is not null set @Message=@Message+': '+@ss;
    end;  
    else begin
      if @pin not in (11435,20684) begin
        set @Overdue=(select sum(d.overdue) from DailySaldoDck d
          where d.Deep>0 and d.nd = dateadd(day,-1, dbo.today()) and d.b_id = @Pin);
        set @Overdue=@Overdue-isnull((select sum(k.plata) from Kassa1 k
          where k.ND=dbo.today() and k.Oper=-2 and k.plata>0 and k.b_id = @Pin),0);
        if @Overdue>0 begin
          set @Errcode=@ErrCode+8;
          set @Message='Продажи рыбы и птицы запрещены';
        end;
      end;
      select @Bonus=d.bonus, @Worker=d.worker, @reg_ID=reg_ID from Def d where d.pin=@pin;
    end;
  end;
end