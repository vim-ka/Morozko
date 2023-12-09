CREATE PROCEDURE dbo.SetBlockDef @pin int, @dck int, @master bit, @block bit, @debit bit, @op int, @Comment varchar(100)
AS
BEGIN

  create table #NeedDCK (dck int)
   

  if @dck > 0 --блокировка договора
  begin
    if @master=1 
    insert into #NeedDCK (dck)
    select c.dck from defcontract c where c.dckmaster=@dck
    else
    insert into #NeedDCK (dck)
    values (@dck)
  end  
  else  
  if @pin > 0 --блокировка покупателя целиком
  begin
    if @master=1 
    insert into #NeedDCK (dck)
    select c.dck from defcontract c where c.contrtip=2 and c.pin in (select d.pin from def d where d.master=@pin )
    else
    insert into #NeedDCK (dck)
    select c.dck from defcontract c where c.pin=@pin and c.contrtip=2
  end
  
  if @debit=0
  update defcontract set disab=@block where dck in (select dck from #NeedDCK) and isnull(Debit,0)=0
  else
  update defcontract set disab=@block, debit=@block where dck in (select dck from #NeedDCK)
  
  insert into dbo.EnabLog (B_ID, BrFam, ag_id, AgFam, sv_id, SvFam, Enab, CheckDate, OP, Comment, DCK) 
  values (@pin,'',0,'',0,'',@block,getdate(),@op,@Comment,@dck);

  
END