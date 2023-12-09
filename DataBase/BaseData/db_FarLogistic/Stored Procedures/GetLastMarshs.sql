CREATE PROCEDURE db_FarLogistic.GetLastMarshs
AS
BEGIN
  select 	top 50
					m.dlMarshID [id],
					cast(m.dlMarshID as varchar)+'::{'+ms.Race+'}' [list] 
	from db_FarLogistic.dlMarsh m
	join db_FarLogistic.MarshInStrings() ms on ms.MarshID=m.dlMarshID
	where m.IDdlMarshStatus=4
	order by m.dlMarshID desc
END