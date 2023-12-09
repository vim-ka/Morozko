CREATE TABLE [Guard].[MatrixJoinDeps] (
    [mjdID]     INT      IDENTITY (1, 1) NOT NULL,
    [Mlid]      INT      NOT NULL,
    [DepID]     SMALLINT NOT NULL,
    [flgActive] BIT      DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([mjdID] ASC)
);

