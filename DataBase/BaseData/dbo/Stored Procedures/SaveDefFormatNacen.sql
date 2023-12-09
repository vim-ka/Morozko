create procedure SaveDefFormatNacen @ngrp int, @dfid int, @MinNacen decimal(7,2)
as
begin
  if Exists(select * from DefformatNacen where ngrp=@ngrp and dfid=@dfid)
  update DefFormatNacen set MinNacen=@MinNacen where ngrp=@ngrp and dfid=@dfid;
  else insert into DefFormatNacen(ngrp, dfid, MinNacen)
  values (@ngrp, @dfid, @MinNacen);
end;