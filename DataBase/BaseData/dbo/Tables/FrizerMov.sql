CREATE TABLE [dbo].[FrizerMov] (
    [ND]          DATETIME     NULL,
    [TM]          CHAR (8)     NULL,
    [Nom]         INT          NULL,
    [Op]          INT          NULL,
    [Pin0]        INT          NULL,
    [Dck0]        INT          NULL,
    [Pin1]        INT          NULL,
    [Dck1]        INT          NULL,
    [DocDate]     DATETIME     NULL,
    [DocNom]      VARCHAR (20) NULL,
    [remark]      VARCHAR (40) NULL,
    [Price]       MONEY        NULL,
    [NDTm]        DATETIME     NULL,
    [SkladNoFrom] INT          CONSTRAINT [DF__FrizerMov__Sklad__5A129A75] DEFAULT ((-1)) NULL,
    [SkladNoTo]   INT          CONSTRAINT [DF__FrizerMov__Sklad__5B06BEAE] DEFAULT ((-1)) NULL,
    [FrizMV]      INT          IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([FrizMV] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Куда', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerMov', @level2type = N'COLUMN', @level2name = N'SkladNoTo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Откуда', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerMov', @level2type = N'COLUMN', @level2name = N'SkladNoFrom';

