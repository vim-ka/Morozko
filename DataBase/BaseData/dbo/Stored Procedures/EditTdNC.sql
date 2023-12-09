CREATE procedure EditTdNC
  @ND datetime, @NNak int, @b_id int, @fam varchar(30), 
  @sp money, @sc money, @extra decimal(8,2), @srok int, 
  @Pko bit, @bank bit, @tovchk bit, 
  @stfnom varchar(6), @stfdate datetime, @tomorrow bit  
as
begin
  if (@StfDate<'19500101') set @StfDate=null; 

  update tdNC set b_id=@b_id, fam=@fam, sp=@sp, sc=@sc, Extra=@extra,
  srok=@srok, pko=@Pko, bank=@bank, tovchk=@tovchk,
  stfnom=@stfnom, stfdate=@stfdate, tomorrow=@tomorrow
  where nd=@nd and nnak=@nnak;
end