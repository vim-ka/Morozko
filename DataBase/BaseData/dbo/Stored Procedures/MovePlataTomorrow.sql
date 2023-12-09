CREATE procedure MovePlataTomorrow
  @SourDatnom int, @DestDatnom int
as
declare @ND datetime -- сегодня
declare @TM char(8) -- тек.время
declare @k_act varchar(4)
declare @k_sourdate datetime
declare @k_nnak int
declare @k_plata money
declare @k_fam varchar(40)
declare @k_b_id int
declare @k_op int
declare @k_bank_id INT
declare @k_our_id int
declare @k_bankday datetime
declare @k_actn tinyint
declare @k_b_idplat int
declare @k_dck int
begin
  set @ND=convert(char(10), getdate(),104);
  set @TM=convert(char(8), getdate(),108);
  declare @CountErr int
  set @CountErr = 0
  BEGIN TRANSACTION KassTomorrow;
  
  
  -- не было ли по этой исходной (перемещаемой) накладной каких-либо выплат?
  declare PayCurs cursor fast_forward for select Act,sourdate, nnak, plata, fam,
    b_id, op, bank_id,our_id,bankday,actn, b_idplat, dck
    from Kassa1 where oper=-2 and nd=@nd-1 and sourdatnom=@SourDatnom;
  open PayCurs;
   
  fetch next from PayCurs into @k_act, @k_sourdate,@k_nnak,@k_plata,@k_fam,
      @k_b_id, @k_op, @k_bank_id,@k_our_id,@k_bankday,@k_actn, @k_b_idplat, @k_dck;

  while @@FETCH_STATUS=0 BEGIN
    -- print 'k_Act='+@k_act+';    k_SourDate='+convert(char(10),@k_sourdate,104)+';  k_plata='+CONVERT(varchar(20),@k_plata);
    
      -- аннулирую выплату по исходной накладной путем вставки отриц. суммы:
      insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,B_ID,Remark,
        RashFlag,LostFlag,LastFlag,OP,Bank_ID,Our_ID,BankDay,Actn,
        ForPrint,SourDatnom,B_IDPLAT, dck)
      values  (@nd,@TM,-2,@K_Act,@k_SourDate,@k_Nnak,-@k_Plata,@k_Fam,@k_B_ID,'переброс накл. на завтра (снятие)',
        0,0,0,0,@k_Bank_ID,@k_Our_ID,@k_BankDay,@k_Actn,
        0,@SourDatnom, @k_B_IDPLAT, @k_dck);
      if @@ERROR<>0 set @CountErr = @CountErr + 1  
	  -- вношу выплату по новой накладной:	
      insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,B_ID,Remark,
        RashFlag,LostFlag,LastFlag,OP,Bank_ID,Our_ID,BankDay,Actn,
        ForPrint,SourDatnom,B_IDPLAT, dck)
      values  (@nd,@TM,-2,@K_Act,dbo.DatNomInDate(@DestDatNom),dbo.InNnak(@DestDatNom),@k_Plata,@k_Fam,@k_B_ID,'переброс накл. на завтра (начисл.)',
        0,0,0,0,@k_Bank_ID,@k_Our_ID,@k_BankDay+1,@k_Actn,
        0,@DestDatnom, @k_B_IDPLAT, @k_dck);
      if @@ERROR<>0 set @CountErr = @CountErr + 1 
      fetch next from PayCurs into @k_act, @k_sourdate,@k_nnak,@k_plata,@k_fam,
        @k_b_id, @k_op, @k_bank_id,@k_our_id,@k_bankday,@k_actn, @k_b_idplat, @k_dck;
  end;
  close PayCurs;
  deallocate PayCurs;
  
  if @CountErr<>0 ROLLBACK ELSE COMMIT;
end;