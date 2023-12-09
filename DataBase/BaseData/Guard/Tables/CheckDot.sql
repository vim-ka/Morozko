CREATE TABLE [Guard].[CheckDot] (
    [chID]    INT      IDENTITY (1, 1) NOT NULL,
    [b_id]    INT      NULL,
    [ND]      DATETIME NULL,
    [Ice]     BIT      DEFAULT ((0)) NULL,
    [Barcode] BIT      DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([chID] ASC)
);

