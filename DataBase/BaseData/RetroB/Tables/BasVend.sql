CREATE TABLE [RetroB].[BasVend] (
    [bvid]  INT IDENTITY (1, 1) NOT NULL,
    [BPMid] INT NULL,
    [Ncod]  INT NULL,
    [DCK]   INT NULL,
    CONSTRAINT [PK__BasVend__53F7CFB2E7DEFCDC] PRIMARY KEY CLUSTERED ([bvid] ASC),
    CONSTRAINT [BasVend_fk] FOREIGN KEY ([BPMid]) REFERENCES [RetroB].[BasPricesMain] ([BPMid]) ON UPDATE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BasVend_uq]
    ON [RetroB].[BasVend]([BPMid] ASC, [Ncod] ASC, [DCK] ASC);

