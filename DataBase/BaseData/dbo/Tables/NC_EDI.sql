CREATE TABLE [dbo].[NC_EDI] (
    [NeID]        INT           IDENTITY (1, 1) NOT NULL,
    [Nd]          DATETIME      DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [Tm]          CHAR (8)      DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Oper]        TINYINT       DEFAULT ((1)) NULL,
    [Datnom]      INT           NULL,
    [Comp]        VARCHAR (30)  NULL,
    [XmlFileName] VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([NeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-создание ЭСФ, 2-редактирование, 3-возврат', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC_EDI', @level2type = N'COLUMN', @level2name = N'Oper';

