CREATE TABLE [dbo].[ReqFinDet] (
    [id]             INT             IDENTITY (1, 1) NOT NULL,
    [reqnum]         INT             NULL,
    [period_from]    DATETIME        NULL,
    [period_to]      DATETIME        NULL,
    [form_opl]       INT             NULL,
    [summa]          NUMERIC (12, 2) NULL,
    [contr_new]      BIT             NULL,
    [contr_new_name] VARCHAR (250)   NULL,
    [contr_id]       INT             NULL,
    [osn_vid]        INT             NULL,
    [osn_num]        VARCHAR (64)    NULL,
    [osn_date]       DATETIME        NULL,
    [our_id]         INT             DEFAULT ((7)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'данные для осуществления платежа по заявке', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqFinDet';

