CREATE TABLE [dbo].[FrizAct] (
    [ActID] INT      IDENTITY (1, 1) NOT NULL,
    [ND]    DATETIME CONSTRAINT [DF__FrizAct__ND__3BE18262] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [OP]    INT      NULL,
    [Ag_ID] INT      NULL,
    UNIQUE NONCLUSTERED ([ActID] ASC)
);

