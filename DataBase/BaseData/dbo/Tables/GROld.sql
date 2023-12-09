CREATE TABLE [dbo].[GROld] (
    [Ngrp]       INT          NOT NULL,
    [GrpName]    VARCHAR (30) NULL,
    [Vet]        BIT          CONSTRAINT [DF__GR__Vet__59B045BD1] DEFAULT ((0)) NULL,
    [Parent]     INT          CONSTRAINT [DF__GR__Parent__0524B3A71] DEFAULT ((0)) NOT NULL,
    [Category]   INT          CONSTRAINT [DF__GR__Category__68FD76451] DEFAULT ((1)) NULL,
    [MainParent] INT          CONSTRAINT [DF__GR__MainParent__4A44B0521] DEFAULT ((0)) NULL,
    [Levl]       INT          CONSTRAINT [DF__GR__Levl__40DB41A91] DEFAULT ((0)) NULL,
    CONSTRAINT [GR_pk1] PRIMARY KEY CLUSTERED ([Ngrp] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Старший предок', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GROld', @level2type = N'COLUMN', @level2name = N'MainParent';

