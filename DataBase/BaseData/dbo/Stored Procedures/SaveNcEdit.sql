CREATE procedure SaveNcEdit @Nnak int, @DatNom int,
 @B_ID int, @BrName varchar(100), @Op smallint, @SP money, @SC money,
 @NewSP money, @NewSc money, @Mode int, @Extra NUMERIC(6,2),
 @Srok smallint, @NalogExst bit, @Nalog money, @Our_Id tinyint,
 @NCID int out, @DCK int=0, @NewDCK int=0
as begin
  insert into NcEdit(ND, TM, Nnak, DatNom, B_ID, BrName, Op, SP, SC, NewSP, NewSC, 
    Mode, Extra, Srok, NalogExst, Nalog, Our_ID, DCK, NewDCK)
  values(convert(char(10), getdate(),104), convert(char(8), getdate(),108),
    @Nnak, @DatNom, @B_ID, @BrName, @Op, @SP, @SC, @NewSP, @NewSC, 
    @Mode, @Extra, @Srok, @NalogExst, @Nalog, @Our_ID, @DCK, @NewDCK);
  set @NCID=SCOPE_IDENTITY();
  /*  select @NCID as NewNCID;*/
end