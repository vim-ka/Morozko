CREATE TABLE [dbo].[planSell] (
    [nd]        DATETIME        NULL,
    [dck]       INT             NULL,
    [hitag]     INT             NULL,
    [flgWeight] BIT             DEFAULT ((0)) NULL,
    [qty]       DECIMAL (10, 2) NULL,
    [psk]       INT             IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [planSell_pk] PRIMARY KEY CLUSTERED ([psk] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_planSell]
    ON [dbo].[planSell]([nd] ASC, [dck] ASC, [hitag] ASC);

