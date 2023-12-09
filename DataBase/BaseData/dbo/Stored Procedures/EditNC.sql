CREATE procedure EditNC
  @datnom int, @b_id int, @fam varchar(30), 
  @sp money, @sc money, @extra decimal(8,2), @srok int, 
  @Pko bit, @bankid int, @tovchk bit, 
  @stfnom varchar(17), @stfdate datetime, @tomorrow bit, @DCK int=0  
as
begin
  begin try
  if (@StfDate<'19500101') set @StfDate=null; 
  if @DCK=0
    update NC set b_id=@b_id, fam=@fam, sp=@sp, sc=@sc, Extra=@extra,
    srok=@srok, pko=@Pko, bankid=@bankid, tovchk=@tovchk,
    stfnom=@stfnom, stfdate=@stfdate, tomorrow=@tomorrow
    where datnom=@datnom;
  ELSE
    update NC set b_id=@b_id, fam=@fam, sp=@sp, sc=@sc, Extra=@extra,
    srok=@srok, pko=@Pko, bankid=@bankid, tovchk=@tovchk,
    stfnom=@stfnom, stfdate=@stfdate, tomorrow=@tomorrow, dck=@DCK
    where datnom=@datnom;
  end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
  end catch     
end