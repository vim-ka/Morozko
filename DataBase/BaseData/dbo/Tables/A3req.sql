CREATE TABLE [dbo].[A3req] (
    [a3id]     INT             IDENTITY (1, 1) NOT NULL,
    [ND]       DATETIME        DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [OP]       INT             NULL,
    [Ncod]     INT             NULL,
    [SP]       DECIMAL (12, 2) NULL,
    [SC]       DECIMAL (12, 2) NULL,
    [Done]     TINYINT         CONSTRAINT [DF__A3req__Closed__2F26A5C2] DEFAULT ((0)) NULL,
    [our_id]   TINYINT         NULL,
    [doc_nom]  VARCHAR (10)    NULL,
    [doc_date] DATETIME        NULL,
    [comp]     VARCHAR (16)    NULL,
    [Ncom]     INT             DEFAULT ((0)) NULL,
    [SkMan]    VARCHAR (30)    NULL,
    [GrMan]    VARCHAR (30)    NULL,
    [NumTN]    VARCHAR (200)   NULL,
    PRIMARY KEY CLUSTERED ([a3id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'список номеров договоров (ТН) ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'NumTN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'грузчик', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'GrMan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кладовщик', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'SkMan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер поставки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'Ncom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'компьтер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'comp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата документа поставки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'doc_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'документ поставки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'doc_nom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код нашей фирмы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'our_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0-сырой 10-отредактирован 20-в работе 30-закрыт', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'Done';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'в ценах прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'SC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'в ценах продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'SP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'Ncod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'ND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3req', @level2type = N'COLUMN', @level2name = N'a3id';

