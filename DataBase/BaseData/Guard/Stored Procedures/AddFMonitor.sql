CREATE procedure Guard.AddFMonitor 
  @TaskKey varchar(20), @ag_id int, @DCK int,  @taskname varchar(80), 
  @Remark varchar(250), @Report varchar(200), 
  @fmid int OUT, @KolPics int Out, @OrigGrp int out
AS
DECLARE @uin int, @B_ID INT,  @DepID smallint, @Gr1 int, @Gr2 int, @AgFIO varchar(100), @gpName varchar(255), @Otv int, @DestDep int
begin
  -- Какой отдел?
  set @DepID=(select DepID from Agentlist where ag_id=@ag_id);
  set @B_ID=(select pin from Defcontract where dck=@dck)
  
  -- Какая группа фотографий?
  set @OrigGrp=dbo.fnDepPicRemGrp2(@DepID, substring(@remark,1,10), substring(@report,1,10));

  --  if @remark=''
  --    set @OrigGrp=(select isnull(min(Grp),16) as Grp from guard.FMonitorTypes ft where @report like ft.pattern);
  --  else begin
  --    set @Gr1=(select isnull(min(Grp),-1) as Grp from guard.FMonitorTypes ft where @remark like ft.pattern);
  --    set @Gr2=(select isnull(min(Grp),-1) as Grp from guard.FMonitorTypes ft where @report like ft.pattern);
  --    
  --    if @Gr2>@Gr1 set @OrigGrp=@Gr2; 
  --    else if @Gr1>@Gr2 set @OrigGrp=@Gr1; 
  --    else if @Gr1>0 set @OrigGrp=@Gr1;
  --    else set @OrigGrp=16;    
  --  end;

  set @fmid=(select fmid from Guard.FMonitor where taskkey=@taskkey and ag_id=@ag_id and dck=@dck);
  if @fmid is null begin
    INSERT INTO Guard.FMonitor ( taskKey,  ag_id,  B_ID, DCK,  taskname, Remark, Report, OrigGrp)
      values (@taskKey,  @ag_id,  @B_ID, @DCK,  @taskname, @Remark, @Report, @OrigGrp);
    set @fmid=(select scope_identity());
    set @KolPics=0;

    -- Заполнение заявки на претензию к холодильнику:
    if @OrigGrp=17 begin 
      set @uin=(select u.uin from usrPWD u where u.P_ID=(select a.p_id from agentlist a where a.ag_id=@Ag_id));
      set @AgFIO=(select p.Fio from agentlist a inner join Person P on P.p_id=a.p_id where a.ag_id=@Ag_id);
      set @gpname=(select gpName from def where pin=@b_id);


      set @Otv = (select case when sv.depid = 3 then sv.p_id else 3735 end 
                  from 
                    agentlist al 
              		  inner join agentlist sv on sv.AG_ID = al.sv_ag_id
              		where al.ag_id = @ag_id);

      set @DestDep=iif(@depid=3, 3, 18);


      insert into  dbo.Requests(link, ND, DepIDCust, DepIDExec, Op, Content, Remark, NeedND, Plata, RemarkExec,  KsOper,  RemarkFin, PlanND, [Status], RealND, 
               RemarkMain, ReqAvail, Nal,  ReqAv,  FactND,  Period,  RemarkMtr,  Rs,  Rf,  [Sent],  SalaryMonth,  PersonnelDepMessage,  [Type],  
               tm,  rql, Bypass,  Itsright,  [Data],  PlataOver,  ByCall,  Otv2,  Tip2,  Data2,  ResFin2,  Prior2,  Locked,  ResFin2ND,  compname, ag_id) 
      values ( @fmid, getdate(), @DepID, @DestDep, @uin, 'Претензия к ХО в точке #'+cast(@B_ID as varchar)+' '+@gpName+'. Договор #'+cast(@DCK as varchar),
         @remark+' '+@report, dbo.today(), 0,'',NULL,'',dbo.today(),1,dbo.today(),'',0,0,0,NULL,0,'',1,0,0,0,'',0,
               dbo.time(),0,0,0,'',0,0, @Otv,200,'Претензия к ХО (Инициатор:'+@AgFIO+')',0,0,0,NULL,HOST_NAME(), @Ag_ID) 
    end;

  end;
  else 
    set @KolPics=(select count(*) from Guard.FMonitorPics where fmid=@FMID);
  select @fmid as NewFMID, @KolPics as KolPics;
end