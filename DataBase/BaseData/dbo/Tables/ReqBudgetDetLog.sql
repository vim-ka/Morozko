﻿CREATE TABLE [dbo].[ReqBudgetDetLog] (
    [rbid]        INT             NULL,
    [kso]         INT             NULL,
    [contr]       INT             NULL,
    [contr_new]   BIT             NULL,
    [contr_txt]   VARCHAR (128)   NULL,
    [sum_opl]     NUMERIC (16, 2) NULL,
    [tip_plat]    INT             NULL,
    [plan_nd]     DATETIME        NULL,
    [depCFO]      INT             NULL,
    [comm]        VARCHAR (1024)  NULL,
    [sum_req]     NUMERIC (16, 2) NULL,
    [compens]     BIT             NULL,
    [compensidx]  INT             NULL,
    [compensnd]   DATETIME        NULL,
    [constplat]   BIT             NULL,
    [addtofp]     BIT             NULL,
    [fp_nd_fix]   DATETIME        NULL,
    [fondsaldo]   NUMERIC (16, 2) NULL,
    [fondplansum] NUMERIC (16, 2) NULL,
    [issogl]      SMALLINT        NULL,
    [LogID]       INT             IDENTITY (1, 1) NOT NULL,
    [ID]          INT             NOT NULL,
    [type]        SMALLINT        NULL,
    [user_name]   NVARCHAR (256)  DEFAULT (suser_sname()) NULL,
    [datetime]    DATETIME        DEFAULT (getdate()) NULL,
    [host_name]   NCHAR (30)      DEFAULT (host_name()) NULL,
    [app_name]    NVARCHAR (128)  DEFAULT (app_name()) NULL,
    [mandatory]   BIT             NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя приложения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqBudgetDetLog', @level2type = N'COLUMN', @level2name = N'app_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя компа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqBudgetDetLog', @level2type = N'COLUMN', @level2name = N'host_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqBudgetDetLog', @level2type = N'COLUMN', @level2name = N'datetime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя пользователя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqBudgetDetLog', @level2type = N'COLUMN', @level2name = N'user_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип изменения 0 - insert, 1 - delete, 2 - update', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqBudgetDetLog', @level2type = N'COLUMN', @level2name = N'type';

