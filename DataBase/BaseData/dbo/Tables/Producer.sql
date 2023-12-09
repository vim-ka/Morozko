CREATE TABLE [dbo].[Producer] (
    [ProducerID]   INT           IDENTITY (1, 1) NOT NULL,
    [ProducerName] VARCHAR (50)  NULL,
    [CodeId]       INT           NULL,
    [ProducerAddr] VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([ProducerID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование производителя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Producer', @level2type = N'COLUMN', @level2name = N'ProducerName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД Производителя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Producer', @level2type = N'COLUMN', @level2name = N'ProducerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Производители', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Producer';

