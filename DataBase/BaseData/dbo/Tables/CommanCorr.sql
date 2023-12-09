CREATE TABLE [dbo].[CommanCorr] (
    [IDCorr] INT          IDENTITY (1, 1) NOT NULL,
    [ND]     DATETIME     NULL,
    [NCOM]   INT          NULL,
    [Corr]   MONEY        NULL,
    [OP]     INT          NULL,
    [Remark] VARCHAR (80) NULL,
    [ccID]   INT          NULL,
    PRIMARY KEY CLUSTERED ([IDCorr] ASC),
    CONSTRAINT [CommanCorr_fk] FOREIGN KEY ([ccID]) REFERENCES [dbo].[CommanCorrReason] ([ccID]) ON UPDATE CASCADE
);

