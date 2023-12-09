CREATE PROCEDURE dbo.SendNotifyMail @ntfy_rcps varchar(128), @ntfy_subj varchar(512), @ntfy_body varchar(max), @with_att bit, @att_files varchar(1024)
-- WITH EXECUTE AS 'MOROZKO\sysadmin' 
AS
BEGIN
print('Hello!')

/*
begin try
--IF (SELECT is_broker_enabled FROM sys.databases WHERE [name] = 'msdb') = 0
--ALTER DATABASE msdb SET ENABLE_BROKER WITH ROLLBACK AFTER 3

--exec sp_configure 'Database Mail XPs', 1;

--RECONFIGURE;

EXEC msdb.dbo.sysmail_start_sp
if @with_att = 0 
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Admin Notify Mailer',
		@recipients = @ntfy_rcps,
		@subject = @ntfy_subj,        
		@body = @ntfy_body;
else
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Admin Notify Mailer',
		@recipients = @ntfy_rcps,
		@subject = @ntfy_subj,        
		@body = @ntfy_body,
        @file_attachments = @att_files;
	
--EXECUTE msdb.dbo.sysmail_stop_sp        
end try
begin catch
  --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
  insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
end catch
*/

end
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SendNotifyMail] TO [MOROZKO\sysadmin]
    AS [dbo];


GO
GRANT TAKE OWNERSHIP
    ON OBJECT::[dbo].[SendNotifyMail] TO [MOROZKO\sysadmin]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SendNotifyMail] TO [MOROZKO\sysadmin]
    AS [dbo];


GO
GRANT CONTROL
    ON OBJECT::[dbo].[SendNotifyMail] TO [MOROZKO\sysadmin]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SendNotifyMail] TO [MOROZKO\sysadmin]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SendNotifyMail] TO [admin]
    AS [dbo];


GO
GRANT TAKE OWNERSHIP
    ON OBJECT::[dbo].[SendNotifyMail] TO [admin]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SendNotifyMail] TO [admin]
    AS [dbo];


GO
GRANT CONTROL
    ON OBJECT::[dbo].[SendNotifyMail] TO [admin]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SendNotifyMail] TO [admin]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SendNotifyMail] TO [guest]
    AS [dbo];


GO
GRANT TAKE OWNERSHIP
    ON OBJECT::[dbo].[SendNotifyMail] TO [guest]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SendNotifyMail] TO [guest]
    AS [dbo];


GO
GRANT CONTROL
    ON OBJECT::[dbo].[SendNotifyMail] TO [guest]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SendNotifyMail] TO [guest]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SendNotifyMail] TO PUBLIC
    AS [dbo];


GO
GRANT TAKE OWNERSHIP
    ON OBJECT::[dbo].[SendNotifyMail] TO PUBLIC
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SendNotifyMail] TO PUBLIC
    AS [dbo];


GO
GRANT CONTROL
    ON OBJECT::[dbo].[SendNotifyMail] TO PUBLIC
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SendNotifyMail] TO PUBLIC
    AS [dbo];

