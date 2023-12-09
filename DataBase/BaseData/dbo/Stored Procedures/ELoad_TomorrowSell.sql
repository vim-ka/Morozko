CREATE PROCEDURE dbo.ELoad_TomorrowSell
AS
begin
  select * into #tmpNaklTomorrow from (
  select d.Reg_ID [КодРегиона],
         nc.datnom % 10000 [НомерСтаройНакладной], 
         cast(SUBSTRING(nc.remark,CHARINDEX('№', nc.remark)+1,10) as int) [НомерНовойНакладной],
    		 nc.b_id [КодКлиента],
         nc.fam [НаименованиеКлиента],
    		 nv.skladNo [НомерСклада], 
         nv.hitag [КодТовара],
         nm.name [НаименованиеТовара],
         --iif(nm.flgWeight=1,round(nv.curWeight / iif(nm.netto=0,1.0,isnull(nm.Netto,1.0)),0),nv.zakaz) [ШТ],
    		 --iif(nm.flgWeight=1,nv.curWeight,nv.Zakaz*iif(nm.netto=0,1.0,isnull(nm.Netto,1.0))) [КГ],
         iif(nm.flgWeight=0,cast(cast(nv.zakaz as int) as VARCHAR)+' шт' ,cast(nv.curweight as varchar)+' кг') [Количество],
         cast('на завтра' as varchar(20)) [Тип]
  from 
    nc 
    inner join nvzakaz NV on nv.datnom=dbo.InDatNom(cast(SUBSTRING(nc.remark,CHARINDEX('№', nc.remark)+1,10) as int), dateadd(day,1,nc.nd))and patindex('{',nc.remark)=0
    and patindex('}',nc.remark)=0
    inner join nomen nm on nm.hitag=nv.hitag
    inner join def d on d.pin=nc.b_id
  where 
    nc.nd=dateadd(day,-1,dbo.today())
    and (nc.tomorrow=1 or nc.Fam like '%перемещена%') 
    and nv.done=1 and nv.id>0
    
  union
  select d.Reg_ID,
         nv.datnom % 10000, 
         nv.NewDatnom % 10000,
    		 nc.b_id,
         nc.fam,
    		 nv.skladNo,
         nv.hitag, 
         nm.name, 
         --iif(nm.flgWeight=1,round(nv.curWeight / iif(nm.netto=0,1.0,isnull(nm.Netto,1.0)),0),nv.zakaz),
    		 --iif(nm.flgWeight=1,nv.curWeight,nv.Zakaz*iif(nm.netto=0,1.0,isnull(nm.Netto,1.0))),
         iif(nm.flgWeight=0,cast(cast(nv.zakaz as int) as VARCHAR)+' шт' ,cast(nv.curweight as varchar)+' кг'),
         cast('возврат+продажа' as varchar(20)) [Тип]
  from 
    nc 
    inner join nvzakaz NV on nv.datnom=nc.datnom
    inner join nomen nm on nm.hitag=nv.hitag
    inner join def d on d.pin=nc.b_id
  where  
    nv.NewDatnom in (select a.datnom from nc a where a.nd=dbo.today())) x
  order by x.[КодРегиона], x.[НомерСтаройНакладной], x.[НаименованиеТовара]
  
  select * from #tmpNaklTomorrow
  
  select distinct [КодРегиона],[НомерСтаройНакладной],[НомерНовойНакладной],[НомерСклада],[Тип] from #tmpNaklTomorrow
  
  drop table #tmpNaklTomorrow
end;