create procedure BackNvZakazToday @datnom INT, @OP INT
AS
declare @ncid int;
begin
  begin TRANSACTION;
  create table #t(nvid int, nzid int, tekid int, Kol int);

  insert into #t
  select nv.nvid, z.nzid, nv.tekid, nv.kol 
  from nv
    inner join nvzakaz z on z.id=nv.tekid and z.datnom=nv.datnom
  WHERE
    nv.datnom=@datnom;

  update tdVi
  set Sell=Sell-#t.kol
  from tdvi inner join #t on #t.tekid=tdvi.id;

  update NV set Kol=0
  from nv inner join #t on #t.nvid=nv.nvid;

  update NvZakaz
  set Done=0, id=0, Spk=0, op=0, Remark=''
  from NvZakaz inner join #t on #t.nzid=nvzakaz.nzid;

--  insert into NcEdit(Nnak,Datnom,B_ID,BrName,Op,SP,SC,Extra,Srok,Our_ID,dck,newdck,newExtra)
--  SELECT
--      @Datnom % 10000 as Nnak, @Datnom, nc.B_ID, nc.Fam, @op, nc.sp, nc.sc, nc.extra, nc.srok, nc.OurID, nc.DCK, nc.dck, nc.Extra
--    from nc where datnom=@datnom;
--  set @NcID=SCOPE_IDENTITY();

  EXEC RecalcNCSumm @datnom;
--  update NcEdit set NewSC=nc.sc, newsp=nc.sp from nc where datnom=@datnom;

  COMMIT;

end;