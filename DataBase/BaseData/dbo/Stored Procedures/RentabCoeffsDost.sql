CREATE PROCEDURE dbo.RentabCoeffsDost @day0 datetime, @day1 datetime, @ncod int, @ngrp int, @calctip int, @recalc bit, @isnet bit,
@withul bit
AS
BEGIN
--  set transaction isolation level read uncommitted
  set nocount on
  declare 
  @ym_from int, 
  @ym_to int,
  @mn int,
  @dn0 int,
  @dn1 int,
  @cnt int
  
  begin try
  set @dn0 = dbo.InDatNom(0000, @day0)
  set @dn1 = dbo.InDatNom(9999, @day1)  
  
  set @mn = datepart(month, @day0)
  if @mn < 10
    set @ym_from = convert(int, convert(varchar(4), datepart(year, @day0)) + '0' + convert(varchar(2), @mn))
  else
    set @ym_from = convert(int, convert(varchar(4), datepart(year, @day0)) + convert(varchar(2), @mn))  
  set @mn = datepart(month, @day1)    
  if @mn < 10
    set @ym_to = convert(int, convert(varchar(4), datepart(year, @day1)) + '0' + convert(varchar(2), @mn))  
  else
    set @ym_to = convert(int, convert(varchar(4), datepart(year, @day1)) + convert(varchar(2), @mn))        
--  print @ym_from
--  print @ym_to  
  
  if @recalc = 1
  begin
    create table #m(nd datetime, marsh int, plata money, weight decimal(12, 2), obl_id int, b_id int)
    create table #s(nd datetime, marsh int, sp money, obl_id int, b_id int)    

	exec NearLogistic.Marsh2CalcFact @day0, @day1 
    create table #cf(cfact int, mhid int)
	insert into #cf(cfact, mhid)
    select sm, mhid from dbo.Marsh2CalcFact
    create index tempcf on #cf(mhid)
--    select NearLogistic.Marsh1CalcFact(mhid) cfact, mhid from marsh 
--	where nd >= @day0 and nd <= @day1 and marsh not in (0, 99)

    if @calctip = 1
    begin
      insert into #m(nd, marsh, plata, weight, b_id)
      select m.nd, m.Marsh, 
      --isnull(mo.OplataSum, 0) + isnull(mo.PercWorkPay, 0), 
      #cf.cfact,
      isnull(m.Weight, 0) + isnull(m.dopWeight, 0),
      nc.b_id
      from marsh m
      --left join dbo.MarshOplDet mo on mo.NdMarsh = m.nd and mo.Marsh = m.marsh
      inner join #cf on #cf.mhid = m.mhid
      inner join dbo.nc nc on nc.nd = m.nd and nc.marsh = m.marsh
--      where m.ND >= @day0 and m.ND <= @day1
      where nc.datnom >= @dn0 and nc.datnom <= @dn1
      and m.Marsh not in (0, 99)
	  and nc.RefDatnom = 0
      and nc.Tara = 0 and nc.Frizer = 0
	  and isnull(m.Weight, 0) + isnull(m.dopWeight, 0) > 0
      group by m.nd, m.Marsh, 
      --mo.OplataSum, mo.PercWorkPay, 
      m.Weight, m.dopWeight, nc.b_id, #cf.cfact
      create index tempm on #m(b_id)
      create index tempm2 on #m(marsh)      

      insert into #s(nd, marsh, sp, obl_id, nc.b_id)
      select
      nc.nd, nc.Marsh, sum(sp) sp, d.Obl_ID, nc.b_id
      from nc
      inner join def d on d.pin = nc.B_ID
--      where nc.nd >= @day0 and nc.nd <= @day1
      where nc.datnom >= @dn0 and nc.datnom <= @dn1
      and nc.RefDatnom = 0 and nc.marsh not in (0, 99)
      and nc.Tara = 0 and nc.Frizer = 0
      group by nc.nd, nc.Marsh, d.Obl_ID, nc.b_id
      create index temps on #s(b_id)
      create index temps2 on #s(marsh)      

      update #m set #m.obl_id = (select top 1 obl_id from #s where #s.nd = #m.nd and #s.marsh = #m.marsh and #s.b_id = #m.b_id order by #s.sp desc)
    end
    
    if @calctip = 2
    begin
      if @isnet = 0
      begin     
	    insert into #m(nd, marsh, plata, weight, b_id)
        select m.nd, m.Marsh, 
        --isnull(mo.OplataSum, 0) + isnull(mo.PercWorkPay, 0), 
        #cf.cfact,
        isnull(m.Weight, 0) + isnull(m.dopWeight, 0),
        nc.b_id
        from marsh m
        inner join #cf on #cf.mhid = m.mhid
        inner join dbo.nc nc on nc.nd = m.nd and nc.marsh = m.marsh
--        where m.ND >= @day0 and m.ND <= @day1
        where nc.datnom >= @dn0 and nc.datnom <= @dn1
        and m.Marsh not in (0, 99)
        and nc.b_id in (select @ncod union 
        				select ncod from RentabUrLicaDet 
						where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
		and nc.RefDatnom = 0
        and nc.Tara = 0 and nc.Frizer = 0
        and isnull(m.Weight, 0) + isnull(m.dopWeight, 0) > 0
        group by m.nd, m.Marsh, 
        --mo.OplataSum, mo.PercWorkPay, 
        m.Weight, m.dopWeight, nc.b_id, #cf.cfact
	    create index tempm on #m(b_id)
    	create index tempm2 on #m(marsh)      
        

        insert into #s(nd, marsh, sp, obl_id, nc.b_id)
        select
        nc.nd, nc.Marsh, sum(sp) sp, d.Obl_ID, nc.b_id
        from nc
        inner join def d on d.pin = nc.B_ID
--        where nc.nd >= @day0 and nc.nd <= @day1
        where nc.datnom >= @dn0 and nc.datnom <= @dn1
        and nc.sp > 0 and nc.marsh not in (0, 99)
        and nc.Tara = 0 and nc.Frizer = 0
        and nc.b_id in (select @ncod union 
        				select ncod from RentabUrLicaDet 
						where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
        group by nc.nd, nc.Marsh, d.Obl_ID, nc.b_id
	    create index temps on #s(b_id)
    	create index temps2 on #s(marsh)      
        
      end
      
      if @isnet = 1
      begin     
	    insert into #m(nd, marsh, plata, weight, b_id)
        select m.nd, m.Marsh, 
        --isnull(mo.OplataSum, 0) + isnull(mo.PercWorkPay, 0), 
        #cf.cfact,
        isnull(m.Weight, 0) + isnull(m.dopWeight, 0),
        nc.b_id
        from marsh m
        inner join #cf on #cf.mhid = m.mhid
        inner join dbo.nc nc on nc.nd = m.nd and nc.marsh = m.marsh
--        where m.nd >= @day0 and m.nd <= @day1
        where nc.datnom >= @dn0 and nc.datnom <= @dn1
        and m.Marsh not in (0, 99)
        and nc.b_id in (select pin from dbo.def where master in (select @ncod union 
        				select ncod from RentabUrLicaDet 
						where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
                        )
        and nc.RefDatnom = 0
        and nc.Tara = 0 and nc.Frizer = 0
        and isnull(m.Weight, 0) + isnull(m.dopWeight, 0) > 0
        group by m.nd, m.Marsh, 
        --mo.OplataSum, mo.PercWorkPay, 
        m.Weight, m.dopWeight, nc.b_id, #cf.cfact
	    create index tempm on #m(b_id)
    	create index tempm2 on #m(marsh)      
        

        insert into #s(nd, marsh, sp, obl_id, nc.b_id)
        select
        nc.nd, nc.Marsh, sum(sp) sp, d.Obl_ID, nc.b_id
        from nc
        inner join def d on d.pin = nc.B_ID
--        where nc.nd >= @day0 and nc.nd <= @day1
        where nc.datnom >= @dn0 and nc.datnom <= @dn1
        and nc.RefDatnom = 0 and nc.marsh not in (0, 99)
        and nc.Tara = 0 and nc.Frizer = 0
        and nc.b_id in (select pin from dbo.def where master in (
        				select @ncod union 
        				select ncod from RentabUrLicaDet 
						where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
                        )
        group by nc.nd, nc.Marsh, d.Obl_ID, nc.b_id
	    create index temps on #s(b_id)
    	create index temps2 on #s(marsh)      
        
      end      

      update #m set #m.obl_id = (select top 1 obl_id from #s where #s.nd = #m.nd and #s.marsh = #m.marsh and #s.b_id = #m.b_id order by #s.sp desc)
    end    

	delete from rentabcalcdost where ym_from = @ym_from and ym_to = @ym_to 
    and ncod in (select @ncod union 
				select ncod from RentabUrLicaDet 
				where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
    
    insert into rentabcalcdost(ym_from, ym_to, obl_id, koeff, tip, ngrp, ncod)
    select @ym_from, @ym_to, #m.Obl_ID, round(sum(plata) / sum(isnull(weight, 1)), 2) koeff, 1, -1 ngrp, @ncod from #m
    where #m.plata > 0 and #m.plata is not null and #m.weight is not null and #m.weight > 0
--    and #m.obl_id in (1, 5, 7, 8, 14)
    group by #m.obl_id
    
    if @calctip = 1
    begin
      insert into rentabcalcdost(ym_from, ym_to, obl_id, koeff, tip, ngrp, ncod)
      select @ym_from, @ym_to, o.Obl_ID, --round((avg(dgb.ForPay) / 32) / (avg(case when j.FCount = 0 then 0 else j.FWeight / j.FCount  end) * 1000), 2) koeff, 
      round(avg(dgb.ForPay) / avg(j.FWeight * 1000), 2) koeff,      
      2 tip, g.MainParent ngrp, @ncod
      from dbo.obl o, db_FarLogistic.dlGroupBill dgb
      left join db_FarLogistic.dlJorneyInfo ji on ji.MarshID = dgb.MarshID
      left join db_FarLogistic.dlJorney j on j.IDReq = ji.IDReq and j.NumberWorks = dgb.WorkID
      inner join dbo.def d on d.pin = ji.VendorID
      inner join dbo.Visual v on v.ncod = d.ncod
--      inner join dbo.nomenvend nomv on nomv.ncod = d.ncod
      inner join dbo.Nomen n on n.hitag = v.hitag
      inner join dbo.gr g on g.ngrp = n.ngrp
--      inner join dbo.SkladList sl on sl.SkladNo = nv.sklad
      where
      dgb.GivenDate >= @day0 and dgb.GivenDate <= @day1
      and j.IDdlPointAction in (2, 3)
      and j.FCount is not null
      and j.FCount > 0 and j.FCount <= 33
      and ji.VendorID < 200000
      and d.ncod in (select @ncod union 
        			 select ncod from RentabUrLicaDet 
					 where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
      and (g.MainParent = @ngrp or @ngrp = -1)
--      and o.Obl_ID in (1, 5, 7, 8, 14)
      and g.Ngrp not in (0, 84, 86, 90)      
--      and sl.Discard = 0
	  and dgb.WorkID > 0
      group by o.Obl_ID, g.mainparent
    end
    if @calctip = 2
    begin
      insert into rentabcalcdost(ym_from, ym_to, obl_id, koeff, tip, ngrp, ncod)
      select @ym_from, @ym_to, o.obl_ID, --round((avg(dgb.ForPay) / 32) / (avg(case when j.FCount = 0 then 0 else j.FWeight / j.FCount  end) * 1000), 2) koeff, 
      round(avg(dgb.ForPay) / avg(j.FWeight * 1000), 2) koeff,
      2 tip, g.MainParent ngrp, @ncod
      from dbo.obl o, db_FarLogistic.dlGroupBill dgb
      left join db_FarLogistic.dlJorneyInfo ji on ji.MarshID = dgb.MarshID
      left join db_FarLogistic.dlJorney j on j.IDReq = ji.IDReq and j.NumberWorks = dgb.WorkID
      inner join dbo.def d on d.pin = ji.VendorID
--      inner join dbo.Visual v on v.ncod = d.ncod
      inner join dbo.nomenvend nomv on nomv.ncod = d.ncod
      inner join dbo.Nomen n on n.hitag = nomv.hitag
      inner join dbo.gr g on g.ngrp = n.ngrp
--      inner join dbo.SkladList sl on sl.SkladNo = v.sklad
      where
      dgb.GivenDate >= @day0 and dgb.GivenDate <= @day1
      and j.IDdlPointAction in (2, 3)
      and j.FCount is not null
      and j.FCount > 0 and j.FCount <= 33
      and ji.VendorID < 200000
      --and d.ncod = @ncod
--      and (g.MainParent = @ngrp or @ngrp = -1)
--      and o.Obl_ID in (1, 5, 7, 8, 14)
      and g.Ngrp not in (0, 84, 86, 90)
      and dgb.WorkID > 0      
--      and sl.Discard = 0
      group by o.Obl_ID, g.mainparent
      having avg(case when j.FCount = 0 then 0 else j.FWeight / j.FCount  end) <> 0      
    end
    
    drop table #m
	drop table #s
    drop table #cf
  end

  end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
  end catch  
  set nocount off  
END