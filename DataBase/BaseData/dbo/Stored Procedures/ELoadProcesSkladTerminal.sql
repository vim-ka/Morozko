CREATE PROCEDURE dbo.ELoadProcesSkladTerminal
@nd datetime
AS
BEGIN
  select 	z.done [Готова],
  				z.datnom%10000 [Код накладной],
  				r.SkladReg [Регион],
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
          z.spk [КодСотрудника]
  from nvzakaz z
  left join nomen n on n.hitag=z.hitag
  left join nc c on c.datnom=z.datnom
  left join def d on d.pin=c.b_id
  LEFT JOIN Regions r ON d.Reg_ID = r.Reg_ID 
  where c.ND= @nd
  order by 1, tmEnd
END