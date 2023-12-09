CREATE procedure SetIzNomerAll @nd datetime
as 
declare @Nomer int, @IzmId int
declare @tSklad int, @pSklad int, @tNewSklad int, @pNewSklad int
declare @tComp varchar(16), @pComp varchar(16)
declare @tAct char(4), @pAct char(4)
begin
  begin TRANSACTION

  set @Nomer=(select isnull(max(nomer),0) from izmen where nd=@nd);

  declare Izcur cursor FAST_FORWARD for select Comp, ACT, Sklad, NewSklad, Izmid
  from izmen 
  where nd=@Nd and isnull(Nomer,0)=0 and Act='Скла'
  order by comp, Act, Sklad,NewSklad,Izmid;
  
  set @pSklad=-1;  set @pNewSklad=-1;  set @pComp='';  set @pAct='';
  open Izcur;
  fetch next from Izcur into @tComp,@tAct,@tSklad,@tNewSklad,@IzmId;
  WHILE (@@FETCH_STATUS=0)  BEGIN
    if isnull(@tSklad,0)<>isnull(@pSklad,0) 
    or isnull(@tNewSklad,0)<>isnull(@pNewSklad,0)
    or (@tComp<>@pComp) or (@tAct<>@pAct)
      set @Nomer=@Nomer+1;
    
    update Izmen set Nomer=@Nomer where IzmId=@IzmId;
    
    set @pSklad=@tSklad;
    set @pNewsklad=@tNewSklad;  
    set @pComp=@tComp;  set @pAct=@tAct;
    
    fetch next from Izcur into @tComp,@tAct,@tSklad,@tNewSklad,@IzmId;
  end;
  close Izcur;
  deallocate Izcur;

  commit
end