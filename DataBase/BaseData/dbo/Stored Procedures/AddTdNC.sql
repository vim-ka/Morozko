CREATE procedure AddTdNC
  @ND datetime, @NNak int, @b_id int, @fam varchar(30), 
  @tm char(8), @op int, @sp money, @sc money, @extra decimal(8,2), @srok int, 
  @Our_ID tinyint, @Pko bit, @man_id int, @bank bit, @tovchk bit, @frizer bit, @met bit,
  @ag_id int, @stfnom varchar(6), @stfdate datetime, @tomorrow bit, @qtyfriz int,
  @att bit, @ready bit, @remark varchar(50), @printed bit, @marsh int, @marshnom int,
  @boxqty decimal(8,2), @Weight float, @actn bit, @ck bit, @tara bit, @comp varchar(16),
  @refDate datetime, @refNnak int, @MarshDay int, @Sk50prn bit, @Done bit
as
declare @refdatnom int
begin
  if (@StfDate<'19500101') set @StfDate=null; 
  if (@RefDate<'19500101') set @RefDate=null;   
  --if (@origdate<'19500101') set @origdate=null;   
/*
insert into tdNc (ND, NNak, b_id, fam, tm, op, sp, sc, extra, srok, 
  Our_ID, Pko, man_id, bank, tovchk, frizer, met, ag_id, stfnom, stfdate, tomorrow, qtyfriz,
  att, ready, remark, printed, marsh, marshnom, boxqty, Weight, actn, ck, tara, comp,
  refDate, refNnak, MarshDay, Sk50prn, Done)
values (@ND, @NNak, @b_id, @fam, @tm, @op, @sp, @sc, @extra, @srok, 
  @Our_ID, @Pko, @man_id, @bank, @tovchk, @frizer, @met, @ag_id, @stfnom, @stfdate, @tomorrow, @qtyfriz,
  @att, @ready, @remark, @printed, @marsh, @marshnom, @boxqty, @Weight, @actn, @ck, @tara, @comp,
  @refDate, @refNnak, @MarshDay, @Sk50prn, @Done);
  */
  if (@refdate is null) or (@refNnak is null) set @RefDatnom=0;
  else set @RefDatNom=dbo.InDatNom(@refNnak, @refDate);
  
insert into NC (DatNom,Nd,B_ID,Fam,TM,OP,SP,SC,Extra,Srok,Fact,OurID,PKO,man_id,bankId,Tovchk,Frizer,Ag_id,StfNom,StfDate,Qtyfriz,
                Remark,RemarkOp,Printed,Marsh,boxqty,weight,actn,ck,tara,RefDatnom,MarshDay,Sk50prn,Done,tomorrow)
values (dbo.InDatNom(@NNak,@ND),@Nd,@B_ID,@fam,@TM,@OP,@SP,@SC,@Extra,@Srok,0,@Our_ID,@PKO,@man_id,0,@Tovchk,@Frizer,@Ag_id,@StfNom,@StfDate,@Qtyfriz,
        @Remark,right(@remark, LEN(@remark)-CHARINDEX('}', @remark)),
        @Printed,@Marsh,@boxqty,@weight,@actn,@ck,@tara,@RefDatNom,@MarshDay,@Sk50prn,@Done,@tomorrow)
end