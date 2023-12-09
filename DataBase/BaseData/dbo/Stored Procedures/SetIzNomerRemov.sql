CREATE procedure SetIzNomerRemov @nd datetime, @Comp varchar(16)
as 
declare @Nomer int, @IzmId int
-- текущий и предыдущий склад, текущий и предыдущий поставщик:
declare @tSklad int, @pSklad int, @tNcod int, @pNcod int

begin
  begin TRANSACTION

  set @Nomer=(select isnull(max(nomer),0) from izmen where nd=@nd);

  declare Izcur cursor FAST_FORWARD for select Izmid, Sklad, Ncod
  from izmen 
  where nd=@Nd and Act ='Снят' and Comp=@Comp and isnull(Nomer,0)=0 
  order by Sklad, Ncod, Izmid;
  
  set @pSklad=-1; set @pNcod=-1;
  open Izcur;
  fetch next from Izcur into @IzmId, @tSklad, @tNcod;
  WHILE (@@FETCH_STATUS=0)  BEGIN
    if isnull(@tSklad,0)<>isnull(@pSklad,0) 
    or isnull(@tNcod,0)<>isnull(@pNcod,0) set @Nomer=@Nomer+1;
    
    update Izmen set Nomer=@Nomer where IzmId=@IzmId;
    
    set @pSklad=@tSklad;
    set @pNcod=@tNcod;  
    
    fetch next from Izcur into @IzmId, @tSklad, @tNcod;
  end;
  close Izcur;
  deallocate Izcur;

  commit
end