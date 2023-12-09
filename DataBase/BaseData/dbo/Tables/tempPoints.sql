CREATE TABLE [dbo].[tempPoints] (
    [ID]      INT             IDENTITY (1, 1) NOT NULL,
    [nAZS]    VARCHAR (200)   NULL,
    [pinname] VARCHAR (200)   NULL,
    [dstAddr] VARCHAR (200)   NULL,
    [weight]  DECIMAL (15, 4) NULL,
    [volume]  DECIMAL (15, 4) NULL,
    [remark]  VARCHAR (200)   NULL,
    [tm]      VARCHAR (5)     NULL,
    [date]    DATETIME        NULL,
    [posx]    DECIMAL (15, 6) NULL,
    [posy]    DECIMAL (15, 6) NULL,
    CONSTRAINT [PK_tempMarshRequestFree2_ID_copy] PRIMARY KEY CLUSTERED ([ID] ASC)
);

