CREATE TABLE [NearLogistic].[nlListPayDet] (
    [LPDID]            INT            IDENTITY (1, 1) NOT NULL,
    [ListNo]           INT            NOT NULL,
    [mhid]             INT            NULL,
    [Nd]               DATETIME       NULL,
    [Marsh]            INT            NULL,
    [OplataSum]        MONEY          NULL,
    [OplataOther]      MONEY          NULL,
    [Dist]             FLOAT (53)     NULL,
    [DistPay]          FLOAT (53)     NULL,
    [DrvPay]           FLOAT (53)     NULL,
    [weight]           FLOAT (53)     NULL,
    [Dots]             INT            NULL,
    [DotsPay]          FLOAT (53)     NULL,
    [SpedPay]          FLOAT (53)     NULL,
    [PercWorkPay]      FLOAT (53)     NULL,
    [Peni]             FLOAT (53)     NULL,
    [BrDolg]           FLOAT (53)     NULL,
    [Podotchet]        FLOAT (53)     NULL,
    [nlTariffParamsID] INT            NULL,
    [drID]             INT            NULL,
    [SpedDrID]         INT            NULL,
    [v_id]             INT            NULL,
    [ScanND]           DATETIME       NULL,
    [dopWeight]        FLOAT (53)     NULL,
    [Direction]        VARCHAR (150)  NULL,
    [v_idTr]           INT            NULL,
    [vetPay]           MONEY          NULL,
    [wayPay]           MONEY          NULL,
    [SecondDriver]     BIT            NULL,
    [Bonus]            MONEY          DEFAULT ((0)) NOT NULL,
    [DurationHr]       NUMERIC (5, 2) NULL,
    [HourPay]          MONEY          NULL,
    [TimeGo]           DATETIME       NULL,
    [TimeBack]         DATETIME       NULL,
    CONSTRAINT [nlListPayDet_pk] PRIMARY KEY CLUSTERED ([LPDID] ASC),
    CONSTRAINT [nlListPayDet_fk] FOREIGN KEY ([ListNo]) REFERENCES [NearLogistic].[nlListPay] ([ListNo]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [nlListPayDet_uq]
    ON [NearLogistic].[nlListPayDet]([mhid] ASC);


GO
CREATE NONCLUSTERED INDEX [nlListPayDet_idx]
    ON [NearLogistic].[nlListPayDet]([ListNo] ASC);

