create procedure ReadRemove @ND datetime, @COMP varchar(16)
as begin
  if @ND=convert(char(10), getdate(),104)
	select
	  f.our_id as VeOurId, f.OurName, f.OurADDR, f.OurADDRFIZ, f.ourInn, f.ourbik, f.nds as OurNds,
	  i.ncod, ve.fam, ve.addr, ve.inn, Ve.nds as VeNds,
	  i.sklad, v.hitag,
	  nm.name, v.weight,
	  i.cost, i.kol, i.NewKol, i.kol-i.newkol as Delta, nm.nds
	from
	 tdIZ i inner join tdVi v on v.ID=i.ID and i.printed=0 and i.act='Снят' and i.nd = @ND and i.Comp = @COMP
  	 inner join Nomen nm on nm.hitag=v.hitag 
	 inner join Vendors ve on ve.ncod=i.ncod
	 inner join FirmsConfig f on f.Our_id=ve.our_id
	 order by f.our_id, i.ncod, i.sklad, i.newsklad,nm.name;
  else
	select
	  f.our_id as VeOurId, f.OurName, f.OurADDR, f.OurADDRFIZ, f.ourInn, f.ourbik, f.nds as OurNds,
	  i.ncod, ve.fam, ve.addr, ve.inn, Ve.nds as VeNds,
	  i.sklad, v.hitag,
	  nm.name, v.weight,
	  i.cost, i.kol, i.NewKol, i.kol-i.newkol as Delta, nm.nds
	from
	 Izmen i inner join visual v on v.ID=i.ID and i.printed=0 and i.act='Снят' and i.nd = @ND and i.Comp = @COMP
	 inner join Nomen nm on nm.hitag=v.hitag
	 inner join Vendors ve on ve.ncod=i.ncod
	 inner join FirmsConfig f on f.Our_id=ve.our_id
	 order by f.our_id, i.ncod, i.sklad, i.newsklad,nm.name;
  
END