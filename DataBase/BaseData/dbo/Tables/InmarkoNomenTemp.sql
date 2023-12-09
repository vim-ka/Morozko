CREATE TABLE [dbo].[InmarkoNomenTemp] (
    [CodeNum]    VARCHAR (10)    NOT NULL,
    [Name]       VARCHAR (120)   NULL,
    [NDS]        TINYINT         NULL,
    [Weight]     NUMERIC (10, 5) NULL,
    [MinP]       INT             NULL,
    [BaseUnit]   VARCHAR (5)     NULL,
    [Hitag]      INT             NULL,
    [CodeNumOld] VARCHAR (10)    NULL,
    UNIQUE NONCLUSTERED ([CodeNum] ASC)
);

