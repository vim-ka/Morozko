CREATE PROCEDURE ELoadMenager.ELoad_ProcesSkladTerminal
@nd datetime,
@skladlist varchar(max) ='',
@done int =0,
@reglist varchar(max) ='',
@marsh int =0,
@time varchar(8) ='00:00:00'
AS
BEGIN
	if object_id('tempdb..#gang') is not null drop table #gang
  create table #gang (gang_id int, gangs varchar(1000))
  insert into #gang(gang_id)
  select distinct sgID from warehouse.sklad_gang
  
  update g set g.gangs=stuff((select N''+s.fio+';'
                              from warehouse.sklad_gang a
                              join dbo.skladpersonal s on s.spk=a.spk
                              where a.spk>0 and a.sgID=g.gang_id
                              order by s.fio
                              for xml path(''), type).value('.','varchar(1000)'),1,0,'')
  from #gang g
  
  
	if object_id('tempdb..#sklad') is not null drop table #sklad
  create table #sklad (id int)
  insert into #sklad select value from string_split(@skladlist,',')
  if len(@skladlist)<1 insert into #sklad select skladno from dbo.skladlist where upweight=1
  
  if object_id('tempdb..#regs') is not null drop table #regs
  create table #regs (id int)
  insert into #regs select value from string_split(@reglist,',')
  if len(isnull(@reglist,''))<1 insert into #regs select sregionid from warehouse.skladreg
  
  create nonclustered index idx_sklad on #sklad(id)
  create nonclustered index idx_reg on #regs(id)
  
  set @time=case when len(@time)=5 then left(@time,5)+':00'
       		  	 	 when len(@time)=7 then '0'+@time
            	 	 when len(@time)=8 then @time end
  
  select * from (
  select 	z.done [Готова],
  				z.datnom%10000 [Код накладной],
          d.brname [НаименованиеКлиента],
          s.DName [Отдел],
  				--r.SkladReg [Регион],
          sk.sregName [Регион],
          c.marsh [Маршрут],
          z.hitag [Код товара],
          n.name [Наименование],
          iif(len(z.remark)<>0,z.Remark,iif(z.done=1,'обработана','не обработана')) [Статус],
          z.dt [Дата поступления], 
          z.tm [Время поступления],
          z.dtEnd [Дата завершения],
          z.tmEnd [Время завершения],
          n.Netto [Вес1шт],
          z.Zakaz [Заказано],
          iif(n.flgWeight=0 and z.curWeight=0,convert(varchar,cast(z.zakaz as int),0)+' шт',convert(varchar,z.curWeight,0)+' кг') [Обработанно],
          iif(n.flgWeight=1,z.curWeight,z.Zakaz*n.netto) [Масса],
          z.tekWeight [ОстатокПередОперацией],
          z.comp [Обработка],
          z.Remark [Примечание],
          z.skladNo [Склад],
          z.op [КодОператора],
          z.spk [КодСотрудника],
          sp.fio [СотрудникСклада],
          '12'+format(m.nd,'ddMMyy')+RIGHT('0000'+CAST(iif(isnull(m.Marsh,0)=0,sk.sregionID,m.marsh) AS VARCHAR(4)),4) [#MarshBarcode],
          '10'+format(c.nd,'ddMMyy')+RIGHT('0000'+CAST(c.DatNom%10000 AS VARCHAR(4)),4) [#NCBarcode],
          case when len(m.TimePlan)=5 then left(timeplan,5)+':00'
       		  	 when len(m.timeplan)=7 then '0'+TimePlan
            	 when len(m.TimePlan)=8 then TimePlan
            	 else null end [Время],
					iif(z.op<=0,'<..>',u.fio) [Оператор],
          iif(z.authorop>1000,autor_agfio.fio,autor_op.fio) [автор заявки],
          #gang.gangs [Бригада],
          cast(iif(patindex('%@Cancel',z.comp)=0,0,1) as bit) [#isCancel]
  from dbo.nvzakaz z
  left join dbo.nomen n on n.hitag=z.hitag
  left join dbo.nc c on c.datnom=z.datnom
  left join dbo.def d on d.pin=c.b_id
  left join dbo.Regions r on d.Reg_ID = r.Reg_ID 
  left join warehouse.skladreg sk on sk.sregionID=r.sregionID
  left join dbo.marsh m on m.mhid=c.mhid
  left join dbo.defcontract dc on dc.dck=c.dck
  left join dbo.agentlist a on a.ag_id=dc.ag_id
  left join dbo.deps s on s.depid=a.depid
  left join dbo.usrpwd u on u.uin=z.op
  left join dbo.skladpersonal sp on sp.spk=z.spk
  left join dbo.agentlist autor_agid on autor_agid.ag_id=z.AuthorOP - 1000
  left join dbo.person autor_agfio on autor_agfio.p_id=autor_agid.p_id
  left join dbo.usrpwd autor_op on autor_op.uin=z.AuthorOP
  left join #gang on #gang.gang_id=z.group_id
  inner join #sklad on #sklad.id=z.skladno
  inner join #regs on #regs.id=r.sregionid
  where c.ND= @nd and z.done=iif(@done=-1,z.Done,@done) and z.zakaz<>0
  			and c.marsh=iif(isnull(@marsh,0)=0,c.marsh,@marsh)) x
	where cast(isnull(x.[время],'00:00:00') as varchar(8))=iif(isnull(@time,'00:00:00')='00:00:00',cast(isnull(x.[время],'00:00:00') as varchar(8)),@time)        
  order by  iif(substring(x.[время],1,1)='0','1','0')+x.[время],
  					x.[Маршрут],x.[Готова],x.[Код накладной],x.[Склад],x.[Наименование]
  
  if object_id('tempdb..#sklad') is not null drop table #sklad
  if object_id('tempdb..#regs') is not null drop table #regs
  if object_id('tempdb..#gang') is not null drop table #gang  
END