CREATE TABLE [dbo].[SuperVis] (
    [SV_ID]     INT          IDENTITY (1, 1) NOT NULL,
    [Fam]       VARCHAR (50) NULL,
    [BRPay]     FLOAT (53)   NULL,
    [Perc]      FLOAT (53)   NULL,
    [Sviskopl]  FLOAT (53)   NULL,
    [Dohod]     FLOAT (53)   NULL,
    [Oborot]    FLOAT (53)   NULL,
    [PercDohod] FLOAT (53)   NULL,
    [RN]        TINYINT      NULL,
    [Chief]     BIT          CONSTRAINT [DF__SuperVis__Chief__3726238F] DEFAULT ((0)) NULL,
    [uin]       INT          NULL,
    [DepID]     INT          CONSTRAINT [DF__SuperVis__DepID__2CC890AD] DEFAULT ((0)) NOT NULL,
    [Phone]     VARCHAR (40) NULL,
    CONSTRAINT [PK_SUPERVIS] PRIMARY KEY CLUSTERED ([SV_ID] ASC)
);

