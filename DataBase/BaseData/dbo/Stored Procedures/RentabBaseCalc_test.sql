CREATE PROCEDURE dbo.RentabBaseCalc_test @day0 datetime, @day1 datetime, @ncod int, @ngrp int, @with_actn bit, 
@calctip int, @isnet bit, @recalc bit, @withul bit
AS
BEGIN
  set transaction isolation level read uncommitted 
  declare 
  @ym_from int, 
  @ym_to int,
  @mn int,
  @dn1 int,
  @dn2 int,
  @cnt int
  
  begin try
  set @dn1 = dbo.InDatNom(0000, @day0)
  set @dn2 = dbo.InDatNom(9999, @day1)
  
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

--  select @cnt = count(*) from dbo.rentabcalc where ym_from = @ym_from and ym_to = @ym_to and ncod = @ncod and (ngrp = @ngrp or @ngrp = -1)  

  if @recalc = 1
  begin
--    delete from dbo.rentabcalc where ym_from = @ym_from and ym_to = @ym_to 
--    and ncod in (select @ncod union 
--				select ncod from RentabUrLicaDet 
--				where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1)) 
--    and (ngrp = @ngrp or @ngrp = -1)  

    create table #rc(ym_from int, ym_to int, calctip int, ncod int, ngrp int, postvol int, obl_id int, 
    	cost numeric(10, 2), price numeric(10, 2), calcvid int, nds numeric(10, 2), postvol2 int)
    
    if @calctip = 1
    begin
      print convert(varchar, getdate())
      insert into #rc(ym_from, ym_to, calctip, ncod, ngrp, postvol, obl_id, cost, price, calcvid, nds, postvol2)
      select @ym_from, @ym_to, @calctip, @ncod, g.mainparent, 
      sum(IIF(v.weight = 0, n.Netto, v.weight) * (isnull(nv.kol, 0) - isnull(nv.Kol_B, 0))) postvol,
      d.obl_id, 
      round(sum(nv.cost * nv.kol * (1 + nc.Extra / 100)) / sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol), 2) cost,
      round(sum(nv.price * nv.kol * (1 + nc.Extra / 100)) / sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol), 2) price,
      1, avg(n.nds),
      sum(IIF(v.weight = 0, n.Netto, v.weight) * isnull(nv.kol, 0)) postvol2 
    from
      dbo.nv nv
      inner join dbo.nomen n on n.hitag = nv.hitag
      inner join dbo.gr g on g.Ngrp = n.ngrp
      inner join dbo.visual v on v.id = nv.TekID
      inner join dbo.nc nc on nc.DatNom = nv.datnom
      inner join dbo.def d on d.pin = nc.B_ID
      inner join dbo.Obl o on o.Obl_ID = d.Obl_ID 
    where
      nv.DatNom >= @dn1 and nv.DatNom <= @dn2
      and v.ncod in (select @ncod union 
					select ncod from RentabUrLicaDet 
					where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
      and (g.MainParent = @ngrp or @ngrp = -1)
      and nc.Actn in (0, @with_actn)    
--      and o.obl_id in (1, 5, 7, 8, 14)
      and nc.RefDatnom = 0
      and nc.Tara = 0 and nc.Frizer = 0      
      and g.Ngrp not in (0, 84, 86, 90)      
      group by g.mainparent, d.obl_id, v.ncod
      having sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol) <> 0    
      print convert(varchar, getdate())      
    end
    
    if @calctip = 2 and @isnet = 0
    begin
      insert into #rc(ym_from, ym_to, calctip, ncod, ngrp, postvol, obl_id, cost, price, calcvid, nds, postvol2)
      select @ym_from, @ym_to, @calctip, @ncod, g.mainparent, 
      sum(IIF(v.weight = 0, n.Netto, v.weight) * (nv.kol - nv.Kol_B)) postvol,
      d.obl_id, 
      round(sum(nv.cost * nv.kol * (1 + nc.Extra / 100)) / sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol), 2) cost,
      round(sum(nv.price * nv.kol * (1 + nc.Extra / 100)) / sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol), 2) price,
      1, avg(n.nds),
      sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol) postvol2      
    from
      dbo.nv nv
      inner join dbo.nomen n on n.hitag = nv.hitag
      inner join dbo.gr g on g.Ngrp = n.ngrp
      inner join dbo.visual v on v.id = nv.TekID
      inner join dbo.nc nc on nc.DatNom = nv.datnom
      inner join dbo.def d on d.pin = nc.B_ID
      inner join dbo.Obl o on o.Obl_ID = d.Obl_ID
    where
      nv.DatNom >= @dn1 and nv.DatNom <= @dn2
      and d.pin in (select @ncod union 
					select ncod from RentabUrLicaDet 
					where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
      and (g.MainParent = @ngrp or @ngrp = -1)
      and nc.Actn in (0, @with_actn)    
--      and o.obl_id in (1, 5, 7, 8, 14)
      and nc.RefDatnom = 0
      and nc.Tara = 0 and nc.Frizer = 0      
      and g.Ngrp not in (0, 84, 86, 90)      
      group by g.mainparent, d.obl_id, d.pin
      having sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol) <> 0    
    end
    
    if @calctip = 2 and @isnet = 1
    begin
      insert into #rc(ym_from, ym_to, calctip, ncod, ngrp, postvol, obl_id, cost, price, calcvid, nds, postvol2)
      select @ym_from, @ym_to, @calctip, @ncod, g.mainparent, 
      sum(IIF(v.weight = 0, n.Netto, v.weight) * (nv.kol - nv.Kol_B)) postvol,
      d.obl_id, 
      round(sum(nv.cost * nv.kol * (1 + nc.Extra / 100)) / sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol), 2) cost,
      round(sum(nv.price * nv.kol * (1 + nc.Extra / 100)) / sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol), 2) price,
      1, avg(n.nds),
      sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol) postvol2
    from
      dbo.nv nv
      inner join dbo.nomen n on n.hitag = nv.hitag
      inner join dbo.gr g on g.Ngrp = n.ngrp
      inner join dbo.visual v on v.id = nv.TekID
      inner join dbo.nc nc on nc.DatNom = nv.datnom
      inner join dbo.def d on d.pin = nc.B_ID
      inner join dbo.Obl o on o.Obl_ID = d.Obl_ID
    where
      nv.DatNom >= @dn1 and nv.DatNom <= @dn2
      and d.pin in (select pin from dbo.def where master in (
      				select @ncod union 
					select ncod from RentabUrLicaDet 
					where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
                    )
      and (g.MainParent = @ngrp or @ngrp = -1)
      and nc.Actn in (0, @with_actn)    
--      and o.obl_id in (1, 5, 7, 8, 14)
      and nc.RefDatnom = 0
      and nc.Tara = 0 and nc.Frizer = 0      
      and g.Ngrp not in (0, 84, 86, 90)      
      group by g.mainparent, d.obl_id
      having sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol) <> 0    
    end

--    insert into dbo.rentabcalc 
select * from #rc where ngrp = 79 and obl_id = 5
  end

  end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
  end catch  
END