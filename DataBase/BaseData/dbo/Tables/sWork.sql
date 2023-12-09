CREATE TABLE [dbo].[sWork] (
    [WorkID]   INT         IDENTITY (1, 1) NOT NULL,
    [ND]       DATETIME    DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [tm]       VARCHAR (8) DEFAULT (CONVERT([varchar],getdate(),(8))) NULL,
    [OP]       INT         NULL,
    [DevID]    INT         NULL,
    [Marsh]    INT         NULL,
    [NDMarsh]  DATETIME    NULL,
    [WType]    TINYINT     NULL,
    [Comleted] BIT         NULL,
    UNIQUE NONCLUSTERED ([WorkID] ASC)
);

