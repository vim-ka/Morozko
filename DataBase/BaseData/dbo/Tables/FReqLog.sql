CREATE TABLE [dbo].[FReqLog] (
    [frq]              INT            NULL,
    [ND]               DATETIME       CONSTRAINT [DF__FReqLog__ND__73F0D15B] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [Tm]               CHAR (8)       CONSTRAINT [DF__FReqLog__Tm__74E4F594] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Op]               INT            NULL,
    [FTip]             INT            NULL,
    [uin]              INT            NULL,
    [trID]             INT            NULL,
    [Terr]             VARCHAR (MAX)  NULL,
    [Remark]           VARCHAR (1000) NULL,
    [Res]              VARCHAR (1000) NULL,
    [Other]            VARCHAR (MAX)  NULL,
    [NDBeg]            DATETIME       NULL,
    [ResDohTek]        MONEY          NULL,
    [ResNacTek]        MONEY          NULL,
    [ResDohO]          MONEY          NULL,
    [ResNacO]          MONEY          NULL,
    [ResND]            DATETIME       NULL,
    [frt]              INT            NULL,
    [fct]              INT            NULL,
    [CardLimit]        NUMERIC (7, 2) NULL,
    [CardLimitR]       MONEY          NULL,
    [CardLimitNew]     NUMERIC (7, 2) NULL,
    [CardLimitNewR]    MONEY          NULL,
    [ExParam]          NUMERIC (7, 2) NULL,
    [ExParamR]         MONEY          NULL,
    [ExParamNew]       NUMERIC (7, 2) NULL,
    [ExParamNewR]      MONEY          NULL,
    [PersLimit]        NUMERIC (7, 2) NULL,
    [PersLimitR]       MONEY          NULL,
    [PersLimitNew]     NUMERIC (7, 2) NULL,
    [PersLimitNewR]    MONEY          NULL,
    [ftID]             INT            NULL,
    [ftIDNew]          INT            NULL,
    [mrkVeh]           INT            NULL,
    [mrkVehNew]        INT            NULL,
    [AddTrips]         VARCHAR (1000) NULL,
    [ForecastWeek]     NUMERIC (8, 3) NULL,
    [ForecastMonth]    NUMERIC (8, 3) NULL,
    [ForecastFuel]     NUMERIC (8, 3) NULL,
    [Run1]             NUMERIC (8, 3) NULL,
    [Run2]             NUMERIC (8, 3) NULL,
    [Run3]             NUMERIC (8, 3) NULL,
    [Run4]             NUMERIC (8, 3) NULL,
    [Run5]             NUMERIC (8, 3) NULL,
    [Run6]             NUMERIC (8, 3) NULL,
    [Run7]             NUMERIC (8, 3) NULL,
    [frs]              INT            NULL,
    [fuelnorma]        INT            NULL,
    [forecastmonthdop] NUMERIC (8, 3) NULL,
    [periodfrom]       DATETIME       NULL,
    [periodto]         DATETIME       NULL,
    [periodvol]        INT            NULL,
    [raschetdate]      DATETIME       NULL,
    [raschetuin]       INT            NULL,
    [resfinance]       VARCHAR (1000) NULL,
    [resdirector]      VARCHAR (1000) NULL,
    [checkanalit]      VARCHAR (1)    CONSTRAINT [DF__FReqLog__checkanali__2923B3A9] DEFAULT ((0)) NULL,
    [checkfinance]     VARCHAR (1)    CONSTRAINT [DF__FReqLog__checkfinan__2A17D7E2] DEFAULT ((0)) NULL,
    [checkdirector]    VARCHAR (1)    CONSTRAINT [DF__FReqLog__checkdirec__2B0BFC1B] DEFAULT ((0)) NULL,
    [checkbuh]         VARCHAR (1)    CONSTRAINT [DF__FReqLog__checkbuh__2C002054] DEFAULT ((0)) NULL,
    [staddrname]       VARCHAR (1000) NULL,
    [moneyfrom]        DATETIME       NULL,
    [moneyto]          DATETIME       NULL,
    [depchief]         INT            NULL,
    [limitfrom]        DATETIME       NULL,
    [overfrom]         DATETIME       NULL,
    [overto]           DATETIME       NULL,
    [opertip]          VARCHAR (3)    NULL,
    [checkdepchief]    VARCHAR (1)    CONSTRAINT [DF__FReqLog__checkdepchief__2B0BFC1B] DEFAULT ((0)) NULL,
    [resdepchief]      VARCHAR (1000) NULL,
    [limitrecom]       INT            NULL,
    [limitutv]         INT            NULL,
    [p_id]             INT            NULL,
    [raschet_p_id]     INT            NULL,
    [operator]         INT            NULL,
    [departchief]      INT            NULL,
    [rubutv]           NUMERIC (8, 3) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Состояние заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FReqLog', @level2type = N'COLUMN', @level2name = N'frs';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пробег понедельника', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FReqLog', @level2type = N'COLUMN', @level2name = N'Run1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Предпологаемый расход топлива', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FReqLog', @level2type = N'COLUMN', @level2name = N'ForecastFuel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Предпологаемый пробег в месяц', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FReqLog', @level2type = N'COLUMN', @level2name = N'ForecastMonth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Предпологаемый пробег в неделю', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FReqLog', @level2type = N'COLUMN', @level2name = N'ForecastWeek';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дополнительные поездки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FReqLog', @level2type = N'COLUMN', @level2name = N'AddTrips';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Утвердить с', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FReqLog', @level2type = N'COLUMN', @level2name = N'NDBeg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FReqLog', @level2type = N'COLUMN', @level2name = N'Op';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время подачи заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FReqLog', @level2type = N'COLUMN', @level2name = N'Tm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата подачи заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FReqLog', @level2type = N'COLUMN', @level2name = N'ND';

