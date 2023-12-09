CREATE PROCEDURE dbo.CopyBuyerInfo @master int, @dckmaster int, @data int
AS
BEGIN
  
if @data = 1 --кол-во накладных ТОРГ-12 - устарело

UPDATE Def
set NaklCopy=(select NaklCopy from Def where pin=@master)
where pin in (select pin from Def where master = @master and pin<>master)

else if @data = 2 --наименование

UPDATE Def
set brName=(select brName from Def where pin=@master)
where pin in (select pin from Def where master = @master and pin<>master)

else if @data = 3 --адрес юридический

UPDATE Def
set brAddr=(select brAddr from Def where pin=@master),
    brIndex=(select brIndex from Def where pin=@master)
where pin in (select pin from Def where master = @master and pin<>master)

else if @data = 4 --банковские реквизиты

UPDATE Def
set brCs=(select brCs from Def where pin=@master),
    brRs=(select brRs from Def where pin=@master),
    brBank=(select brBank from Def where pin=@master),
    brBIK=(select brBIK from Def where pin=@master),
    gpCs=(select gpCs from Def where pin=@master),
    gpRs=(select gpRs from Def where pin=@master),
    gpBank=(select gpBank from Def where pin=@master),
    gpBIK=(select gpBIK from Def where pin=@master)
where pin in (select pin from Def where master = @master and pin<>master)

else if @data = 5 --КПП
begin
  UPDATE Def
  set brKpp=(select brKpp from Def where pin=@master)
  where pin in (select pin from Def where master = @master and pin<>master)
  
  UPDATE Def
  set brInn=(select brInn from Def where pin=@master)
  where pin in (select pin from Def where master = @master and pin<>master)
  
  UPDATE Def
  set gpInn=(select gpInn from Def where pin=@master)
  where pin in (select pin from Def where master = @master and pin<>master)
  
end

else if @data = 6 --ОГРН

UPDATE Def
set OGRN=(select OGRN from Def where pin=@master),
    OGRNDate=(select OGRNDate from Def where pin=@master)
where pin in (select pin from Def where master = @master and pin<>master)

else if @data = 7 --ОКПО

UPDATE Def
set OKPO=(select OKPO from Def where pin=@master),
    OKPO2=(select OKPO2 from Def where pin=@master)
where pin in (select pin from Def where master = @master and pin<>master)

else if @data = 8 --бухгалтер

UPDATE Def
set buh_id=(select buh_id from Def where pin=@master)
where pin in (select pin from Def where master = @master and pin<>master)

else if @data = 9 --телефоны

UPDATE Def
set gpPhone=(select gpPhone from Def where pin=@master),
    brPhone=(select brPhone from Def where pin=@master)
where pin in (select pin from Def where master = @master and pin<>master)



else if @data >= 50 --данные договора
begin

  declare @dck int
  
  if @master=0 set @master=-5

  DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR SELECT dck FROM DefContract WHERE (pin=@master or dckmaster=@dckmaster) and ContrTip=2

  OPEN @CURSOR 

  FETCH NEXT FROM @CURSOR INTO @dck

  WHILE @@FETCH_STATUS = 0
  BEGIN

    if @data = 50 --данные договора основные

      UPDATE DefContract
      set --ContrName=(select ContrName from DefContract where dck=@dck), 
          ContrNum=(select ContrNum from DefContract where dck=@dck),
          ContrDate=(select ContrDate from DefContract where dck=@dck),
          ContrEvalDate=(select ContrEvalDate from DefContract where dck=@dck)
      where ContrTip=2 and dckmaster=@dck

    else if @data = 51 --период сверки
  
      UPDATE DefContract
      set LastSver=(select LastSver from DefContract where dck=@dck)
      where ContrTip=2 and dckmaster=@dck

    else if @data = 52 --отсрочка платежа 

      UPDATE DefContract
      set Srok=(select Srok from DefContract where dck=@dck)
      where ContrTip=2 and dckmaster=@dck

    else if @data = 53 --НДС

      UPDATE DefContract
      set NDS=(select NDS from DefContract where dck=@dck)
      where ContrTip=2 and dckmaster=@dck
    
    else if @data = 54 -- Система налогооблажения 

      UPDATE DefContract
      set TaxMID=(select TaxMID from DefContract where dck=@dck)
      where ContrTip=2 and dckmaster=@dck
      
  
    FETCH NEXT FROM @CURSOR INTO @dck
  END
  
  CLOSE @CURSOR
  DEALLOCATE @CURSOR
  
  if @data = 60 -- Копирование договора
  insert into  dbo.DefContract(
           Actual, Our_id, ContrTip, pin, ContrName, ContrMain, ContrNum, ContrDate, ContrEvalDate, Srok, BnFlag, NDS,
           minOrder, maxDaysOrder, LastSver, Remark, gpOur_ID, Bank_ID, p_id, [limit], Extra, wostamp, DCKOld, PrevP_id,
           AccountID, ag_id, PrevAg_ID, NeedFrizSver, LastFrizSver, Degust, dcnID, DckMaster, NeedCK,  Factoring,
           PrintStandartPhrase, Ncod, ExpressSver, Disab,  Debit, gpBank_ID, FMonDisab, TaxMID, PricePrecision) 
   select dc.Actual, dc.Our_id, dc.ContrTip, d.pin, dc.ContrName, dc.ContrMain, dc.ContrNum, dc.ContrDate, dc.ContrEvalDate, dc.Srok, dc.BnFlag, dc.NDS,
              dc.minOrder, dc.maxDaysOrder, dc.LastSver, dc.Remark, dc.gpOur_ID, dc.Bank_ID, dc.p_id, dc.limit, dc.Extra, dc.wostamp, dc.DCKOld, dc.PrevP_id,
              dc.AccountID, dc.ag_id, dc.PrevAg_ID, dc.NeedFrizSver, dc.LastFrizSver, dc.Degust, dc.dcnID, dc.DckMaster, dc.NeedCK,  dc.Factoring,
              dc.PrintStandartPhrase, dc.Ncod, dc.ExpressSver, dc.Disab,  dc.Debit, dc.gpBank_ID, dc.FMonDisab, dc.TaxMID, dc.PricePrecision 
   from defcontract dc join def d on 1=1
   where dc.dck=@dckmaster and ((d.master=iif(@master=0,-5,@master) and d.pin<>dc.pin) or (d.pin=dc.pin and @master=0))

end

END