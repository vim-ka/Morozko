CREATE PROCEDURE dbo.GetProcess
AS
BEGIN
  SET NOCOUNT ON
  SELECT    
  s.spid [КодПроцеса]
 ,s.blocked [БлокирующийПроцесс]
 ,s.waittime / 1000.0 [ВремяОжидания]
 ,s.lastwaittype [ПоследнийТипОжидания]
 ,s.open_tran [ОткрытыхТранзакций]
 ,s.status [СтатусПроцесса]
 ,s.hostname [Компьютер]
 ,s.program_name [Приложение]
 ,(select text from sys.dm_exec_sql_text(s.sql_handle)) [SQL]
  FROM sys.sysprocesses s
  WHERE s.open_tran <> 0
  order by s.waittime desc
  SET NOCOUNT OFF
END