CREATE TABLE [dbo].[SkladPlace] (
    [PLID]       INT            IDENTITY (1, 1) NOT NULL,
    [PlaceName]  VARCHAR (30)   NULL,
    [OurAddrFiz] VARCHAR (100)  NULL,
    [PosX]       NUMERIC (9, 6) NULL,
    [PosY]       NUMERIC (9, 6) NULL,
    [point_id]   INT            DEFAULT ((0)) NOT NULL,
    UNIQUE NONCLUSTERED ([PLID] ASC)
);

