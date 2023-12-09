
CREATE VIEW NearLogistic.OperationTypes
AS
	select 0 [TypeID],'добавление' [TypeName]
	union select 1,'удаление'
	union select 2,'перемещение'
	union select 3,'смена статуса'
  union select 4,'создание'
  union select 5,'изменение данных'
  union select 6,'изменение тарифа'