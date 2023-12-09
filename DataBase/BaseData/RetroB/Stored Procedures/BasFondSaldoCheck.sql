CREATE PROCEDURE RetroB.BasFondSaldoCheck @fondid int
AS
BEGIN
  declare 
  @cnt int
  set @cnt = 0;
  select @cnt = count(*) from retrob.BasFondSaldo where fondid = @fondid
  
  if @cnt = 0 
  	insert into retrob.BasFondSaldo(fondid, sum_plata) values(@fondid, 0)
  else
  	update retrob.BasFondSaldo set sum_plata = 
	  isnull((select sum(k.plata) from retrob.BasRuleDistr brd
	    inner join retrob.BasRules br on br.RuleID = brd.ruleid
		inner join retrob.BasTarget bt on bt.btID = brd.btid
		inner join dbo.kassa1 k on k.P_ID = bt.p_id
	  where br.FondID = @fondid
		and k.RemarkPlat = 'btid=' + CAST(bt.btID AS varchar)), 0) 
    where retrob.BasFondSaldo.fondid = @fondid

  select sum_plata from retrob.BasFondSaldo where fondid = @fondid
END