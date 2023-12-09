CREATE TABLE [dbo].[tempmarsh] (
    [mhid]  INT      NULL,
    [drID]  INT      NULL,
    [V_ID]  INT      NULL,
    [ND]    DATETIME NULL,
    [Marsh] INT      NULL,
    [Bonus] MONEY    NULL,
    [pk]    INT      IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [tempmarsh_pk] PRIMARY KEY CLUSTERED ([pk] ASC)
);

