CREATE TABLE [dbo].[Rests] (
    [ID]      INT             IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME        DEFAULT (getdate()) NULL,
    [pin]     INT             NULL,
    [hitag]   INT             NULL,
    [qty]     NUMERIC (10, 2) NULL,
    [ag_idn]  TINYINT         NULL,
    [DCK]     INT             NULL,
    [ag_id]   INT             NULL,
    [NeedDay] DATE            DEFAULT ([dbo].[today]()) NULL,
    [Remark]  VARCHAR (500)   NULL,
    [Price]   DECIMAL (10, 2) NULL,
    [weight]  DECIMAL (10, 3) DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [rests_5idx]
    ON [dbo].[Rests]([hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [rests_4idx]
    ON [dbo].[Rests]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [rests_3idx]
    ON [dbo].[Rests]([ag_id] ASC);


GO
CREATE NONCLUSTERED INDEX [rests_2idx]
    ON [dbo].[Rests]([DCK] ASC);


GO
CREATE NONCLUSTERED INDEX [rests_1idx]
    ON [dbo].[Rests]([ND] ASC);

