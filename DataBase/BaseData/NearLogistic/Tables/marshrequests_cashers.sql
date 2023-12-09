CREATE TABLE [NearLogistic].[marshrequests_cashers] (
    [casher_id]     INT           IDENTITY (1, 1) NOT NULL,
    [casher_name]   NVARCHAR (50) NULL,
    [casher_addres] VARCHAR (500) NULL,
    [inn]           NVARCHAR (12) NULL,
    [kpp]           VARCHAR (50)  NULL,
    [phone]         VARCHAR (30)  NULL,
    [extcode]       VARCHAR (50)  NULL,
    [isdel]         BIT           DEFAULT ((0)) NOT NULL,
    [cs]            VARCHAR (50)  NULL,
    [rs]            VARCHAR (50)  NULL,
    [cgid]          INT           NULL,
    [ShortName]     VARCHAR (50)  NULL,
    [ttID]          INT           NULL,
    CONSTRAINT [PK__marshreq__5923A4D8F4597F84] PRIMARY KEY CLUSTERED ([casher_id] ASC)
);

