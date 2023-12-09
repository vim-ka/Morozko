create procedure SaveDefFormat2Nacen @ngrp int, @dfid int, @MinNacen decimal(7,2)
as
begin
  if Exists(select * from Defformat2Nacen where ngrp=@ngrp and dfid=@dfid)
  update DefFormat2Nacen set MinNacen=@MinNacen where ngrp=@ngrp and dfid=@dfid;
  else insert into DefFormat2Nacen(ngrp, dfid, MinNacen)
  values (@ngrp, @dfid, @MinNacen);
end;