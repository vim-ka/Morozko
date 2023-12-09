CREATE TABLE [dbo].[FFuelLimit] (
    [flId]           INT             IDENTITY (1, 1) NOT NULL,
    [uin]            INT             NULL,
    [limit]          INT             NULL,
    [datefrom]       DATETIME        NULL,
    [p_id]           INT             NULL,
    [locked]         BIT             DEFAULT ((0)) NULL,
    [byfact]         BIT             DEFAULT ((0)) NULL,
    [norma]          NUMERIC (3, 1)  CONSTRAINT [DF__FFuelLimi__norma__5A7CAEC9] DEFAULT ((10)) NULL,
    [base_fuel_type] INT             DEFAULT ((2)) NULL,
    [sign_porog]     NUMERIC (12, 2) DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([flId] ASC)
);

