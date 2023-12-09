CREATE TABLE [dbo].[ReqReturnBuh] (
    [id]       INT IDENTITY (1, 1) NOT NULL,
    [our_id]   INT NULL,
    [buh_p_id] INT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

