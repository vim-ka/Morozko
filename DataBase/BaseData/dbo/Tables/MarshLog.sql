CREATE TABLE [dbo].[MarshLog] (
    [LgId]    INT          IDENTITY (1, 1) NOT NULL,
    [mhid]    INT          CONSTRAINT [DF__MarshLog__mhid__046664EF] DEFAULT ((0)) NULL,
    [ND]      DATETIME     CONSTRAINT [DF__MarshLog__ND__16300F6F] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [TM]      CHAR (8)     CONSTRAINT [DF__MarshLog__TM__172433A8] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Marsh]   INT          NULL,
    [MarshND] DATETIME     NULL,
    [Op]      INT          NULL,
    [Remark]  VARCHAR (50) NULL,
    [mState]  INT          NULL,
    PRIMARY KEY CLUSTERED ([LgId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Статус маршрута 
1- маршрут набран
2- разрешена печать
3- исправить(переформировать маршрут)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshLog', @level2type = N'COLUMN', @level2name = N'mState';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id маршрута в табл Marsh', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshLog', @level2type = N'COLUMN', @level2name = N'mhid';

