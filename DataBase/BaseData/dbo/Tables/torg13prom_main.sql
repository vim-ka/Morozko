CREATE TABLE [dbo].[torg13prom_main] (
    [tmID]       INT           IDENTITY (1, 1) NOT NULL,
    [CreateDate] DATETIME      DEFAULT ([dbo].[today]()) NULL,
    [ND]         DATETIME      NULL,
    [Op]         INT           NULL,
    [TM]         VARCHAR (8)   DEFAULT ([dbo].[GetTime]()) NULL,
    [Comp]       VARCHAR (30)  NULL,
    [Dest]       VARCHAR (400) NULL,
    PRIMARY KEY CLUSTERED ([tmID] ASC)
);

