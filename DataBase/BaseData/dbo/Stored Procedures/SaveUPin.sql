create procedure SaveUPin
as
declare @brINN varchar(12), @PrevINN varchar(12)
declare @pin int, @UPin int
begin
  update def set upin=null;
  
  -- Проставляю UPIN в группах совпадающих brINN:
  declare c1 cursor fast_forward for 
    select brINN, pin from Def 
    where brInn<>'' and isnull(Master,0)=0
    order by brINN,pin;

  open c1;
  fetch next from c1 into @brInn, @Pin;
  set @UPin=@Pin;
  set @PrevINN=@brInn;

  while (@@FETCH_STATUS=0) begin
    update Def set UPin=@UPin where pin=@pin  
    fetch next from c1 into @brInn, @Pin;
    if (@@FETCH_STATUS=0) and (@brInn<>@PrevInn) begin
      set @UPin=@Pin;
      set @PrevInn=@brInn;
    end;
  end;
  close c1;
  deallocate c1;
  
  -- Проставляю UPIN в группах совпадающих gpINN:
  declare c1 cursor fast_forward for 
    select gpINN, pin from Def 
    where gpInn<>'' and isnull(Master,0)=0 and UPIN is null
    order by gpINN,pin;

  open c1;
  fetch next from c1 into @brInn, @Pin;
  set @UPin=@Pin;
  set @PrevINN=@brInn;

  while (@@FETCH_STATUS=0) begin
    update Def set UPin=@UPin where pin=@pin  
    fetch next from c1 into @brInn, @Pin;
    if (@@FETCH_STATUS=0) and (@brInn<>@PrevInn) begin
      set @UPin=@Pin;
      set @PrevInn=@brInn;
    end;
  end;
  close c1;
  deallocate c1;
  
  -- Не уверен, что эта строка нужна, ну пусть пока будет:
  update def set upin=pin where upin is null;
end;