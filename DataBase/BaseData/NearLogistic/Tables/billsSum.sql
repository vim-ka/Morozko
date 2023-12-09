CREATE TABLE [NearLogistic].[billsSum] (
    [bill_id]          INT           IDENTITY (1, 1) NOT NULL,
    [mhid]             INT           NOT NULL,
    [casher_id]        INT           NOT NULL,
    [mas]              AS            ([NearLogistic].[GetMasSum]([mhid],[casher_id],[nal])),
    [vol]              AS            ([NearLogistic].[GetVolSum]([mhid],[casher_id],[nal])),
    [distance]         INT           DEFAULT ((0)) NOT NULL,
    [realdist]         FLOAT (53)    NULL,
    [is_old]           BIT           DEFAULT ((0)) NOT NULL,
    [tax]              MONEY         DEFAULT ((0)) NOT NULL,
    [tax_1kg]          MONEY         DEFAULT ((0)) NOT NULL,
    [req_pay]          MONEY         DEFAULT ((0)) NOT NULL,
    [bill_stack_id]    INT           DEFAULT ((0)) NOT NULL,
    [real_bill_code]   VARCHAR (50)  DEFAULT ('') NOT NULL,
    [real_bill_date]   DATETIME      DEFAULT (getdate()) NOT NULL,
    [locked]           BIT           DEFAULT ((0)) NOT NULL,
    [locked_remark]    VARCHAR (500) NULL,
    [nal]              BIT           DEFAULT ((0)) NOT NULL,
    [dt_create]        DATETIME      DEFAULT (getdate()) NOT NULL,
    [comp]             VARCHAR (50)  DEFAULT (host_name()) NOT NULL,
    [RecCount]         AS            ([NearLogistic].[GetRecCount]([mhid],[casher_id],[nal])),
    [nlTariffParamsID] INT           DEFAULT ((0)) NOT NULL,
    [auto]             BIT           NULL,
    CONSTRAINT [PK_billsSum_bill_id_copy] PRIMARY KEY CLUSTERED ([bill_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [bills_idx]
    ON [NearLogistic].[billsSum]([mhid] ASC);


GO
CREATE NONCLUSTERED INDEX [bills_idx3]
    ON [NearLogistic].[billsSum]([bill_stack_id] ASC);


GO
CREATE NONCLUSTERED INDEX [bills_idx4]
    ON [NearLogistic].[billsSum]([casher_id] ASC);


GO
CREATE NONCLUSTERED INDEX [bills_idx5]
    ON [NearLogistic].[billsSum]([is_old] ASC);

