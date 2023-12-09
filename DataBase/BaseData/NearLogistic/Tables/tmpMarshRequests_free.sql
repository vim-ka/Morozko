CREATE TABLE [NearLogistic].[tmpMarshRequests_free] (
    [mrfID]         INT             IDENTITY (1, 1) NOT NULL,
    [nd]            DATETIME        NULL,
    [remark]        VARCHAR (500)   NULL,
    [cost]          DECIMAL (15, 2) NULL,
    [pin]           INT             NULL,
    [weight]        DECIMAL (15, 4) NULL,
    [volume]        DECIMAL (15, 4) NULL,
    [kolbox]        DECIMAL (15, 4) NULL,
    [contact]       VARCHAR (500)   NULL,
    [pallet_count]  DECIMAL (15, 4) NULL,
    [ext_point_id]  VARCHAR (40)    NULL,
    [Temp]          INT             NULL,
    [DocNumber]     VARCHAR (100)   NULL,
    [DocDate]       DATETIME        NULL,
    [extcode]       VARCHAR (50)    NULL,
    [pal]           DECIMAL (15, 4) NULL,
    [nal]           BIT             NULL,
    [point_name]    VARCHAR (150)   NULL,
    [point_address] VARCHAR (250)   NULL,
    [tm]            VARCHAR (8)     NULL
);

