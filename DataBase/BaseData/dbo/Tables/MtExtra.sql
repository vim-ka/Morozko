CREATE TABLE [dbo].[MtExtra] (
    [ID]      INT        IDENTITY (1, 1) NOT NULL,
    [B_ID]    INT        NULL,
    [Hitag]   INT        NULL,
    [Extra]   FLOAT (53) NULL,
    [BegDate] DATETIME   DEFAULT (getdate()) NULL,
    [EndDate] DATETIME   DEFAULT (getdate()+(10)) NULL,
    [Actual]  BIT        NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [MtExtra_uq] UNIQUE NONCLUSTERED ([B_ID] ASC, [Hitag] ASC)
);

