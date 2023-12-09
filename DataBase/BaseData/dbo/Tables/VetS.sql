CREATE TABLE [dbo].[VetS] (
    [ID]        INT           IDENTITY (1, 1) NOT NULL,
    [Name]      VARCHAR (50)  NULL,
    [FirmName]  VARCHAR (200) NULL,
    [TovName]   VARCHAR (200) NULL,
    [Kol]       VARCHAR (25)  NULL,
    [Pack]      VARCHAR (25)  NULL,
    [Mark]      VARCHAR (100) NULL,
    [Proizv]    VARCHAR (200) NULL,
    [FullExp]   BIT           NULL,
    [dtVrbt]    DATETIME      NULL,
    [Realiz]    VARCHAR (30)  NULL,
    [FromTrans] VARCHAR (70)  NULL,
    [Marsh]     VARCHAR (50)  NULL,
    [ToTrans]   VARCHAR (100) NULL,
    [TransDoc]  VARCHAR (20)  NULL,
    [DopExp]    VARCHAR (40)  NULL,
    [Rem]       VARCHAR (90)  NULL,
    [VidTS]     VARCHAR (15)  NULL,
    [TransFor]  VARCHAR (20)  NULL,
    [Tip]       SMALLINT      NULL,
    UNIQUE NONCLUSTERED ([ID] ASC)
);

