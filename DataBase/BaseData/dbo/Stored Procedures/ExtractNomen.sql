create procedure ExtractNomen
as
begin

  create table #E (hitag int not null primary key, ncod int);
  insert into #E select hitag, max(ncod) as ncod from Visual group by Hitag;
  
  select distinct
    gr.MainParent, G.GrpName,nm.hitag, nm.name, #E.Ncod,  Ve.Fam, NM.kzarp
  from  
    Nomen NM inner join GR on GR.Ngrp=NM.Ngrp
    inner join GR G on G.Ngrp=GR.MainParent
    inner join Visual Vi on Vi.hitag=nm.hitag
    inner join #E on #E.Hitag=NM.Hitag
    inner join Vendors Ve on Ve.Ncod=#E.Ncod
  order by gr.MainParent, nm.Name
  
end;