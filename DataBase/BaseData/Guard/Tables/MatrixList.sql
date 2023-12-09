CREATE TABLE [Guard].[MatrixList] (
    [MlID]   INT          IDENTITY (1, 1) NOT NULL,
    [ND]     DATE         DEFAULT ([dbo].[today]()) NULL,
    [Name]   VARCHAR (50) NULL,
    [Remark] VARCHAR (50) NULL,
    [Actual] BIT          DEFAULT ((1)) NULL,
    [Day0]   DATETIME     NULL,
    [Day1]   DATETIME     NULL,
    [OP]     INT          NULL,
    PRIMARY KEY CLUSTERED ([MlID] ASC)
);

