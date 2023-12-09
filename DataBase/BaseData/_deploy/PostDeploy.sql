DECLARE @env VARCHAR(10);
SET @env = '$(env)';

IF @env = 'dev'
BEGIN
:r  .\AlterUDFforDEV.sql
END

--- Reporting
:r  .\Data\Reporting.Category.sql
:r  .\Data\Reporting.Report.sql
:r  .\Data\Reporting.SqlStatement.sql
:r  .\Data\Reporting.ReportParam.sql
:r  .\Data\Reporting.ParamFiller.sql
:r  .\Data\Reporting.ParamFillerParam.sql
:r  .\Data\Reporting.ReportParamFiller.sql
---  

DECLARE @DbName NVARCHAR(50) = DB_NAME()
DECLARE @UpdateId UNIQUEIDENTIFIER, @Comment NVARCHAR(500), @Version NVARCHAR(32) = (SELECT dbo.__DBVERSION__());

SET XACT_ABORT ON;

BEGIN TRY
	BEGIN TRANSACTION

	SELECT @UpdateId = '3E5C53B0-E5FC-4DE7-A0EB-FD3E973EF2DC',
	       @Comment = N'PSD-567: Initial fill dbo.SlotNumber_EmploymentType_Placement and SlotNumberMeta.IsArchived';
	$(BeginUpdate)
	    :r  .\Data\CleanUp_SlotNumberMetaRelocation.sql
	$(EndUpdate)

	SELECT @UpdateId = '1CD7C6F2-BE02-4FC4-B4BB-F2C4C1F38C74',
	       @Comment = N'PSD-511: Translate import file mapping result';
	$(BeginUpdate)
	    :r  .\Data\Translate_T_MAPPING_RESULT.sql
	$(EndUpdate)

	SELECT @UpdateId = '6750D758-A2F0-4F4A-80A6-D9D44BB5CBDA',
	       @Comment = N'PSD-642: Initial filling data into the table';
	$(BeginUpdate)
	    :r  .\Data\Fill_BonusType_CheckMetadata.sql
	$(EndUpdate)

	SELECT @UpdateId = '126D5CF3-B907-4622-B925-0C5698E5FC5D',
	       @Comment = N'PSD-757: Filling T_BonusType_BONUS_GROUP';
	$(BeginUpdate)
	    :r  .\Data\Filling_T_BonusType_BONUS_GROUP.sql
	$(EndUpdate)

	SELECT @UpdateId = 'E7BEE40A-88CD-4100-87AB-F1AD650386F7',
	       @Comment = N'PSD-697: Сreate logs and components';
	$(BeginUpdate)
	    :r  .\Data\Fill_DBEntity.sql		
	$(EndUpdate)

	SELECT @UpdateId = '3BF56EA1-59EC-48EC-9E53-F83FC3FC8B28',
	       @Comment = N'PSD-697: Run SP';
	$(BeginUpdate)
		:r  .\Data\CreateLogTriggers.sql		
	$(EndUpdate)

	SELECT @UpdateId = '91854E74-E7F3-4F99-88EF-2092ABD633B7',
	       @Comment = N'PSD-968: filling in the status directory for BS';
	$(BeginUpdate)
		:r  .\Data\Fill_BatchStatus.sql	
	$(EndUpdate)

	SELECT @UpdateId = 'D0EA4D88-C4CB-48B7-AAD4-E530D56F7AE2',
	       @Comment = N'adding a new type - deleting';
	$(BeginUpdate)
		:r  .\Data\Fill_InteropRequestTypeOption.sql	
	$(EndUpdate)
	
	SELECT @UpdateId = '80CFDEFC-8F5A-450A-8D17-552F391B468B',
	       @Comment = N'PSD-966: Fill InteropRequestTypeOption  for Request and Responce to BS';
	$(BeginUpdate)
	    :r  .\Data\Fill_InteropRequestTypeOption_ReqResp.sql
	$(EndUpdate)

	SELECT @UpdateId = '829C97A4-DF04-42F5-B3D1-FE1F9167F0EB',
	       @Comment = N'PSD-969: Update Value to SOW request table';
	$(BeginUpdate)
	    :r  .\Data\Update_Value_For_SOWRequest.sql
	$(EndUpdate)

	SELECT @UpdateId = '74B3CDF5-BB48-4A53-9F57-3B9C88CC756A',
	       @Comment = N'PSD-969: Add Value to RequestStatus';
	$(BeginUpdate)
	    :r  .\Data\Add_Value_RequestStatus.sql
	$(EndUpdate)


	SELECT @UpdateId = '08B8D908-0E0B-496A-82C4-36586FA82C32',
	       @Comment = N'PSD-1058: Add new parameters ';
	$(BeginUpdate)
	    :r  .\Data\Add_new_filters.sql
	$(EndUpdate)

	SELECT @UpdateId = '9308907C-8373-4039-B356-3EC9956249AF',
	       @Comment = N'PSD-1058: Delete extra filters';
	$(BeginUpdate)
	    :r  .\Data\Delete_extra_filters.sql
	$(EndUpdate)

	SELECT @UpdateId = 'C9186BD8-ED38-439E-8B7E-911B48A26A1C',
	       @Comment = N'PSD-1037: add new column';
	$(BeginUpdate)
	    :r  .\Data\Add_NEW_Column_T_USER_PMUser.sql
	$(EndUpdate)

	SELECT @UpdateId = '6A0DF020-E19C-448B-9235-CAA61CEF7F87',
	       @Comment = N'PSD-1070: Add new values for PayrollPaymentSlotStatus';
	$(BeginUpdate)
	    :r  .\Data\Add_Values_PayrollPaymentSlotStatus.sql
	$(EndUpdate)

	SELECT @UpdateId = '1B0F4121-E602-414F-9D78-B5EE7368563B',
	       @Comment = N'PSD-1085: reorder columns in the report';
	$(BeginUpdate)
	    :r  .\Data\Add_Values_PayrollPaymentSlotStatus.sql
	$(EndUpdate)

	SELECT @UpdateId = '55EECE6C-07C3-41A1-9B3F-1B3B6BAA5011',
	       @Comment = N'PSD-1099: Fill APIRequestTypeOption';
	$(BeginUpdate)
	    :r  .\Data\Fill_APIRequestTypeOption.sql
	$(EndUpdate)

	SELECT @UpdateId = '3ECD1F39-7516-4889-ACA2-4AD727357465',
	       @Comment = N'PSD-1148: Add values to T_BONUS_GROUP';
	$(BeginUpdate)
	    :r  .\Data\AddValueToIncludedColumns_T_BONUS_GROUP.sql
	$(EndUpdate)

	SELECT @UpdateId = 'B850A3CF-F929-4AD7-BC40-7E97E0A57E53',
	       @Comment = N'PSD-1148: Add values to T_HISTORY_BONUS_GROUP';
	$(BeginUpdate)
	    :r  .\Data\AddValueToIncludedColumns_T_HISTORY_BONUS_GROUP.sql
	$(EndUpdate)
	
	SELECT @UpdateId = '73EA40DC-B4D2-4C85-8A3F-BF593DCC0C40',
	       @Comment = N'PSD-1065: D2M Notifications';
	$(BeginUpdate)
	    :r  .\Data\Add_Value_SysConfig_KV.sql
	$(EndUpdate)


    COMMIT;
    PRINT 'PostDeployment script executed successfully';
END TRY
BEGIN CATCH
    DECLARE @ErrorSeverity int = ERROR_SEVERITY(), @ErrorState int = ERROR_STATE(), @ErrorNumber int = ERROR_NUMBER(), @ErrorMessage nvarchar(4000) = ERROR_MESSAGE(), @ErrorLine INT = ERROR_LINE(), @UpdateIdStr VARCHAR(36) = CONVERT(VARCHAR(36), @UpdateId);
    IF @@TRANCOUNT > 0
        ROLLBACK;

    PRINT '!!!PostDeployment script error!!!';
    RAISERROR('%s (%d) at line %d. Update ID: ''%s''', @ErrorSeverity, @ErrorState, @ErrorMessage, @ErrorNumber, @ErrorLine, @UpdateIdStr);
END CATCH