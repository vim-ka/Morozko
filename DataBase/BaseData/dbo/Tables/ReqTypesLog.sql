CREATE TABLE [dbo].[ReqTypesLog] (
    [ReqTypeId]     INT           NULL,
    [ReqTypeParent] INT           NULL,
    [ReqTypeName]   VARCHAR (255) NULL,
    [ReqReglCode]   INT           CONSTRAINT [DF__ReqTypesLog__ReqReg__314FB0AD] DEFAULT ((1)) NULL,
    [DepId]         INT           CONSTRAINT [DF__ReqTypesLog__DepId__0941BF53] DEFAULT ((-1)) NULL,
    [IspInterval]   INT           CONSTRAINT [DF__ReqTypesLog__IspInt__75F9E0B5] DEFAULT ((3)) NULL,
    [NeedFin]       INT           CONSTRAINT [DF__ReqTypesLog__NeedFi__77E22927] DEFAULT ((0)) NULL,
    [NeedBuh]       INT           CONSTRAINT [DF__ReqTypesLog__NeedBu__78D64D60] DEFAULT ((0)) NULL,
    [NeedSogl]      INT           CONSTRAINT [DF__ReqTypesLog__NeedSo__4F35194F] DEFAULT ((0)) NULL,
    [Otv]           INT           CONSTRAINT [DF__ReqTypesLog__Otv__6EADC4A8] DEFAULT ((-1)) NULL,
    [user_id]       INT           NULL,
    [user_datetime] DATETIME      NULL,
    [user_type]     VARCHAR (3)   NULL
);

