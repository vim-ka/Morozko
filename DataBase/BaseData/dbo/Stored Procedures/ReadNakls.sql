CREATE procedure ReadNakls @NakList varchar(1000)
as 
begin
  select * into #nc001 from nc_ where datnom=1;
  
--  EXEC('SELECT * into #nc001 FROM NC WHERE Datnom in ' + @NakList  );
  
  select n.our_id, n.tovchk,
    n.fam,def.brInn, def.brKpp, n.extra,
    nv.TekID, nv.Hitag, nm.name, nm.fname, nv.price, nv.cost, nv.sklad,
    sl.skg as SkladGroup, vi.minp, vi.mpu, vi.nds,
    vi.country, vi.datepost, vi.dater, vi.srokh, vi.sert_id, nv.kol, nv.kol_b,
    nm.ngrp, def.LicNo, def.licwho, def.brAddr, Def.gpAddr, 
    nc.StfDate, nc.StfNom, sr.orgName, sr.nSert, sr.nBlank,
    sr.begDate, sr.ednDate, sr.nVat, sr.dateVet,
    nc.printed, def.gpName, def.OKPO, def.okpo2
  from #nc001 n left join Def on Def.pin=n.B_ID
  inner join NV_ nv on nv.datnom=n.datnom
  inner join Nomen nm on nm.hitag=nv.hitag
  inner join SkladList sl on sl.skladno=nv.sklad
  inner join TDVi_ vi on vi.tekid=nv.tekid
  left join Sertif sr on sr.sert_id=vi.sert_id
  where Def.tip=1
end;