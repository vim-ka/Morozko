CREATE procedure SetIzNomer @nd datetime, @Act char(4), @Comp varchar(16)
as 
declare @Nomer int, @IzmId int
declare @tSklad int, @pSklad int, @tNewSklad int, @pNewSklad int
begin
  begin TRANSACTION

  set @Nomer=(select isnull(max(nomer),0) from izmen where nd=@nd);

  declare Izcur cursor FAST_FORWARD for select Izmid, Sklad, NewSklad
  from izmen 
  where nd=@Nd and Act like @Act and Comp=@Comp and isnull(Nomer,0)=0 
  order by Act, Sklad,NewSklad,Izmid;
  
  set @pSklad=-1;
  open Izcur;
  fetch next from Izcur into @IzmId, @tSklad, @tNewSklad;
  WHILE (@@FETCH_STATUS=0)  BEGIN
    if isnull(@tSklad,0)<>isnull(@pSklad,0) 
    or isnull(@tNewSklad,0)<>isnull(@pNewSklad,0) set @Nomer=@Nomer+1;
    
    update Izmen set Nomer=@Nomer where IzmId=@IzmId;
    
    set @pSklad=@tSklad;
    set @pNewsklad=@tNewSklad;  
    
    fetch next from Izcur into @IzmId, @tSklad, @tNewSklad;
  end;
  close Izcur;
  deallocate Izcur;

  commit
end