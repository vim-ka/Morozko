CREATE TABLE [NearLogistic].[marshdet_del] (
    [mdid]      INT IDENTITY (1, 1) NOT NULL,
    [mhid]      INT NOT NULL,
    [DetID]     INT NOT NULL,
    [ReqType]   INT NOT NULL,
    [MarshNumb] INT DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__marshdet__7C73BD7AD13561C6] PRIMARY KEY CLUSTERED ([mdid] ASC)
);

