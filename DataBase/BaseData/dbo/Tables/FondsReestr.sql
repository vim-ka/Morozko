CREATE TABLE [dbo].[FondsReestr] (
    [id]              INT             IDENTITY (1, 1) NOT NULL,
    [p_id]            INT             NULL,
    [form_st_proc]    NUMERIC (5, 2)  NULL,
    [form_ord]        VARCHAR (1024)  NULL,
    [form_period]     VARCHAR (1024)  NULL,
    [target_ord]      VARCHAR (1024)  NULL,
    [target_period]   VARCHAR (1024)  NULL,
    [neg_limit_saldo] NUMERIC (12, 2) NULL,
    [otv]             INT             NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

