CREATE TABLE [Guard].[MatrixLDet] (
    [mldID]    INT      IDENTITY (1, 1) NOT NULL,
    [mlid]     INT      NOT NULL,
    [hitag]    INT      NULL,
    [MinQty]   INT      NULL,
    [MinVitr]  INT      NULL,
    [OnMatrix] BIT      DEFAULT ((0)) NULL,
    [MGrp]     SMALLINT DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([mldID] ASC)
);

