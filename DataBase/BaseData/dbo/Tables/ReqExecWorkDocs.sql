CREATE TABLE [dbo].[ReqExecWorkDocs] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [our_id_from] INT           NULL,
    [our_id_to]   INT           NULL,
    [tip2]        INT           NULL,
    [docnom]      VARCHAR (20)  NULL,
    [docdate]     DATETIME      NULL,
    [docnaim]     VARCHAR (256) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

