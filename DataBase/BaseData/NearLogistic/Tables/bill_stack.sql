CREATE TABLE [NearLogistic].[bill_stack] (
    [bill_stack_id] INT           IDENTITY (1, 1) NOT NULL,
    [bill_name]     VARCHAR (500) DEFAULT ('') NOT NULL,
    [date_create]   DATETIME      DEFAULT (getdate()) NOT NULL,
    [op]            INT           NOT NULL,
    [comp]          VARCHAR (50)  DEFAULT (host_name()) NOT NULL
);

