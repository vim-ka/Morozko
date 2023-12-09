CREATE procedure dbo.CheckBuyerContract_Debug @dck integer, @Message varchar(200) OUT,
  @ErrCode int out, @Bonus bit=0 out, @Worker bit=0 out, @reg_ID char(2)='' out
as
declare @ss varchar(200), @Overdue decimal(12,2), @Debt decimal(12,2), @Disab bit, @Actual bit, @Pin int, @Limit decimal(10,2)
begin
  set @errCode=0; 
  set @MESSAGE='';
  select @Pin=pin, @Limit=Limit from Defcontract where Dck=@Dck;
  select @Bonus=isnull(d.bonus,0), @Worker=isnull(d.worker,0), @reg_ID=reg_ID from Def d where d.pin=@pin;
  print '@pin='+cast(@pin as varchar)

  if exists(select * from config where param='skladblock' and VAL='1') begin
    set @Message=(select val  from config where param='MSGONSKLADBLOCK');
    set @errCode=1;
  end;
  else begin
    select @Disab=Disab, @Actual=Actual from DefContract where dck=@dck;
    if @Actual=0 begin
      set @Errcode=@ErrCode+2;
      set @Message='Договор закрыт';
    end;
    else if @Disab=1 begin
      set @ss=(select top 1 Comment from enablog where B_ID=@Pin and Enab=0 order by EID desc);
      set @Errcode=@ErrCode+4;
      set @Message='Договор заблокирован'
      if @ss is not null set @Message=@Message+': '+@ss;
    end;  
    else begin
      if @pin not in (11435,20684) begin
        set @Overdue=(select sum(d.overdue) from DailySaldoDck d
          where d.Deep>0 and d.nd = dateadd(day,-1, dbo.today()) and d.dck = @dck);
        set @Overdue=@Overdue-isnull((select sum(k.plata) from Kassa1 k
          where k.ND=dbo.today() and k.Oper=-2 and k.plata>0 and k.dck = @dck),0);
        if (@Overdue>0) and not exists(select 1 from DefExclude de where de.Pin=@Pin) begin
          set @Errcode=@ErrCode+8;
          set @Message='Продажи рыбы и птицы запрещены';
        end;

        set @Debt=(select sum(d.Debt) from DailySaldoDck d
          where d.nd = dateadd(day,-1, dbo.today()) and d.dck = @dck);
        set @Debt=@Debt+isnull((select sum(sp) from nc where nd=dbo.today() and stip not in (2,3,4) and dck=@Dck),0);
        set @Debt=@Debt-isnull((select sum(k.plata) from Kassa1 k
          where k.ND=dbo.today() and k.Oper=-2 and k.plata>0 and k.dck = @dck),0);
        if @Debt>@Limit begin
          set @ErrCode=@ErrCode+16;
          set @Message='Превышен лимит продаж ('+cast(@Limit as varchar)+' р.)';
        end;
  
      end;
    end;
  end;
end