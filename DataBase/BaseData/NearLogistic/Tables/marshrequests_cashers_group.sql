CREATE TABLE [NearLogistic].[marshrequests_cashers_group] (
    [cgid] INT          IDENTITY (1, 1) NOT NULL,
    [name] VARCHAR (15) NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__marshreq__233EC4FD70B85328]
    ON [NearLogistic].[marshrequests_cashers_group]([cgid] ASC);

