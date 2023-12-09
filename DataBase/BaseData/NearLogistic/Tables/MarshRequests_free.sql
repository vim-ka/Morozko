CREATE TABLE [NearLogistic].[MarshRequests_free] (
    [mrfID]        INT             IDENTITY (1, 1) NOT NULL,
    [mhID]         INT             DEFAULT ((0)) NOT NULL,
    [nd]           DATETIME        NULL,
    [remark]       VARCHAR (500)   NULL,
    [cost]         DECIMAL (15, 2) DEFAULT ((0)) NOT NULL,
    [pin]          INT             NULL,
    [weight]       DECIMAL (15, 4) DEFAULT ((0)) NOT NULL,
    [volume]       DECIMAL (15, 4) DEFAULT ((0)) NOT NULL,
    [kolbox]       DECIMAL (15, 4) DEFAULT ((0)) NOT NULL,
    [DelivCancel]  BIT             DEFAULT ((0)) NOT NULL,
    [comp]         VARCHAR (50)    DEFAULT (host_name()) NOT NULL,
    [dt_create]    DATETIME        DEFAULT (getdate()) NOT NULL,
    [app]          VARCHAR (50)    DEFAULT (app_name()) NOT NULL,
    [op]           INT             NOT NULL,
    [ReqAction]    INT             DEFAULT ((1)) NOT NULL,
    [isDel]        BIT             DEFAULT ((0)) NOT NULL,
    [contact]      VARCHAR (500)   DEFAULT ('') NULL,
    [pallet_count] DECIMAL (15, 4) DEFAULT ((0)) NOT NULL,
    [point_id]     INT             DEFAULT ((-1)) NOT NULL,
    [point_action] INT             DEFAULT ((-1)) NOT NULL,
    [Temp]         INT             NULL,
    [DocNumber]    VARCHAR (100)   NULL,
    [DocDate]      DATETIME        NULL,
    [extcode]      VARCHAR (50)    NULL,
    [pal]          DECIMAL (15, 4) NULL,
    [nal]          BIT             DEFAULT ((0)) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__MarshReq__AC47977DE5412F75]
    ON [NearLogistic].[MarshRequests_free]([mrfID] ASC);

