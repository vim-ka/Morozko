CREATE PROCEDURE [MobAgents].MobSaveMoney  @Type varchar(3), @ag_id int, @dck int, @sm money, @Remark varchar(255), @CompName varchar(30),
                                           @PKO varchar(20), @NDInp datetime, @InBank bit
                                            
AS
BEGIN
 
  declare @TekND datetime, @DepID int, @uin int, @B_ID int, @gpName varchar(100) , @AgFIO varchar(100), @Otv int
  
  
  set @TekND=dbo.today();
 
  set @B_ID = (select pin from DefContract where dck=@DCK);
  set @gpName = (select gpName from Def where pin=@B_ID);
  set @AgFIO=(select p.Fio from person p where p.P_ID=(select a.p_id from agentlist a where a.ag_id=@Ag_id));
  
  
  set @CompName=host_name()
  
  if @Type='z'
  begin  
    set @uin=(select u.uin from usrPWD u where u.P_ID=(select a.p_id from agentlist a where a.ag_id=@Ag_id))
    set @DepID = (select s.DepID from agentlist s where s.ag_id=@Ag_id);   

    select @Otv = Otv from ReqTypes where ReqTypeID=199

    insert into  dbo.Requests(ND, DepIDCust, DepIDExec, Op, Content, Remark, NeedND, Plata, RemarkExec,  KsOper,  RemarkFin, PlanND, [Status], RealND, 
                  RemarkMain, ReqAvail, Nal,  ReqAv,  FactND,  Period,  RemarkMtr,  Rs,  Rf,  [Sent],  SalaryMonth,  PersonnelDepMessage,  [Type],  
                 tm,  rql, Bypass,  Itsright,  [Data],  PlataOver,  ByCall,  Otv2,  Tip2,  Data2,  ResFin2,  Prior2,  Locked,  ResFin2ND,  compname, ag_id) 
    values (getdate(), @DepID, 9, @uin, 'Сбор денежных средств #'+cast(@B_ID as varchar)+' '+@gpName+'. Договор #'+cast(@DCK as varchar),'Забрать ДС. '+@Remark, @TekND, @sm,'',NULL,'',@TekND,1,@TekND,'',0,0,0,NULL,0,'',1,0,0,0,'',0,
             dbo.time(),0,0,0,'',0,0,@Otv,199,'Сбор Д/С (Инициатор:'+@AgFIO+')', 0, 0, 0, NULL, @CompName, @Ag_ID)  
     
    --set @Rk=SCOPE_IDENTITY() 
  end
  else
  if @B_ID <> 28015 --Для тестовой точки оплаты не проводим
  begin
  
    declare @P_ID int, @op int
    set @P_ID=(select a.p_id from agentlist a where a.ag_id=@Ag_id);
    set @op=@ag_id+1000
    set @Remark='ч/з агента '+ cast(@ag_id as varchar)+' '+@AgFIO+' '+@Remark;
  
    EXEC [dbo].[PayNaklOver]  @B_ID, 0, @sm, @Remark, @op, 0, @TekND, 0, 
                              @DCK, 0, @P_ID, 0, 0, 0, @NDInp,
                              @InBank, 0, @PKO, '', 0;
  
  end;  

END