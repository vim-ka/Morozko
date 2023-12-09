CREATE TABLE [dbo].[PrihodReq] (
    [PrihodRID]          INT             IDENTITY (1, 1) NOT NULL,
    [PrihodRDate]        DATETIME        CONSTRAINT [DF__PrihodReq__ND__769833DC] DEFAULT (CONVERT([varchar],getdate(),(4))) NULL,
    [PrihodROperatorID]  INT             NULL,
    [PrihodRVendersID]   INT             NULL,
    [PrihodRSumPrice]    DECIMAL (19, 4) NULL,
    [PrihodRSumCost]     DECIMAL (19, 4) NULL,
    [PrihodRDone]        TINYINT         DEFAULT ((0)) NULL,
    [PrihodROurID]       TINYINT         DEFAULT ((7)) NULL,
    [PrihodRDocNum]      VARCHAR (20)    NULL,
    [PrihodRDocDate]     DATETIME        NULL,
    [PrihodRComp]        VARCHAR (16)    NULL,
    [PrihodROrdersID]    INT             NULL,
    [PrihodRTNNum]       VARCHAR (30)    NULL,
    [PrihodRTNDate]      DATETIME        NULL,
    [PrihodRDefContract] INT             NULL,
    [PrihodRDefSafeCust] BIT             DEFAULT ((0)) NULL,
    [PrihodRSaveTo]      BIT             DEFAULT ((0)) NULL,
    [PrihodROpSave]      BIT             DEFAULT ((0)) NULL,
    [PrihodRVenderPin]   INT             NOT NULL,
    [PrihodRPinOwner]    INT             NULL,
    [PrihodRDCKOwner]    INT             NULL,
    [PrihodRNDS10]       MONEY           NULL,
    [PrihodRNDS18]       MONEY           NULL,
    [PrihodRSumNDS]      MONEY           NULL,
    [NeedReCalc]         BIT             DEFAULT ((0)) NULL,
    [PrihodRAllow]       BIT             DEFAULT ((0)) NOT NULL,
    [dlMarshID]          INT             DEFAULT ((0)) NOT NULL,
    [dlMarshCost]        MONEY           DEFAULT ((0)) NOT NULL,
    [PrihodRNDS20]       DECIMAL (12, 2) NULL,
    PRIMARY KEY CLUSTERED ([PrihodRID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Зона изменения дат операторами( 0 - имеют право менять, 1- уже сохранили можно редактировать этим днем и удаляется на след день)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodROpSave';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сохранять ли до завтра', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRSaveTo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'это Ответ хранение (1) или нет (0)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRDefSafeCust';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'договор с поставщиком', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRDefContract';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата товарной накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRTNDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер товарной накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRTNNum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД прихода в табл Orders', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodROrdersID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'компьтер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRComp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата счет-факт', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRDocDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'счет-факт ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRDocNum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к удалению!!!', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodROurID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0-сырой 10-отредактирован 20-в работе 30-закрыт', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRDone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'в ценах прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRSumCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'в ценах продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRSumPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRVendersID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodROperatorID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReq', @level2type = N'COLUMN', @level2name = N'PrihodRID';

