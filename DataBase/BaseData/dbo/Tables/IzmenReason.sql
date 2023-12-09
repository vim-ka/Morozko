CREATE TABLE [dbo].[IzmenReason] (
    [irid]     INT          NOT NULL,
    [Reason]   VARCHAR (80) NULL,
    [Positive] BIT          NULL,
    [Act]      VARCHAR (4)  NULL,
    PRIMARY KEY CLUSTERED ([irid] ASC)
);

