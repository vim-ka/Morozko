CREATE TABLE [dbo].[NeedVerifOld] (
    [pin]      INT      NOT NULL,
    [NeedSver] BIT      NULL,
    [LastSver] DATETIME NULL,
    PRIMARY KEY CLUSTERED ([pin] ASC)
);

