CREATE TABLE [NearLogistic].[RequestsActions] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [action_name] VARCHAR (50) DEFAULT ('') NOT NULL,
    [flag]        INT          DEFAULT ((1)) NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__Requests__3213E83E711249C9]
    ON [NearLogistic].[RequestsActions]([id] ASC);

