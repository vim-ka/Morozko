CREATE TABLE [NearLogistic].[bills] (
    [bill_id]              INT             IDENTITY (1, 1) NOT NULL,
    [mhid]                 INT             NOT NULL,
    [reqid]                INT             NOT NULL,
    [casher_id]            INT             NOT NULL,
    [mas]                  DECIMAL (15, 4) NOT NULL,
    [vol]                  DECIMAL (15, 4) DEFAULT ((0)) NOT NULL,
    [distance]             INT             DEFAULT ((0)) NOT NULL,
    [origin_point_id]      INT             NOT NULL,
    [destination_point_id] INT             NOT NULL,
    [is_old]               BIT             DEFAULT ((0)) NOT NULL,
    [tax]                  MONEY           DEFAULT ((0)) NOT NULL,
    [tax_1kg]              MONEY           DEFAULT ((0)) NOT NULL,
    [req_pay]              MONEY           DEFAULT ((0)) NOT NULL,
    [bill_stack_id]        INT             DEFAULT ((0)) NOT NULL,
    [real_bill_code]       VARCHAR (50)    DEFAULT ('') NOT NULL,
    [real_bill_date]       DATETIME        DEFAULT (getdate()) NOT NULL,
    [locked]               BIT             DEFAULT ((0)) NOT NULL,
    [locked_remark]        VARCHAR (500)   NULL,
    [nal]                  BIT             DEFAULT ((0)) NOT NULL,
    [dt_create]            DATETIME        DEFAULT (getdate()) NOT NULL,
    [comp]                 VARCHAR (50)    DEFAULT (host_name()) NOT NULL,
    [nlTariffParamsID]     INT             DEFAULT ((0)) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [bills_idx5]
    ON [NearLogistic].[bills]([is_old] ASC);


GO
CREATE NONCLUSTERED INDEX [bills_idx4]
    ON [NearLogistic].[bills]([casher_id] ASC);


GO
CREATE NONCLUSTERED INDEX [bills_idx3]
    ON [NearLogistic].[bills]([bill_stack_id] ASC);


GO
CREATE NONCLUSTERED INDEX [bills_idx2]
    ON [NearLogistic].[bills]([reqid] ASC);


GO
CREATE NONCLUSTERED INDEX [bills_idx]
    ON [NearLogistic].[bills]([mhid] ASC);

