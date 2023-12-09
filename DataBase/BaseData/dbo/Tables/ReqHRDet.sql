CREATE TABLE [dbo].[ReqHRDet] (
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    [reqnum]     INT           NULL,
    [vacancy]    VARCHAR (128) NULL,
    [territory]  VARCHAR (512) NULL,
    [exworker]   VARCHAR (128) NULL,
    [expand]     VARCHAR (512) NULL,
    [worktime]   VARCHAR (128) NULL,
    [needchars]  VARCHAR (255) NULL,
    [needperiod] VARCHAR (128) NULL,
    [normatives] VARCHAR (255) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'таблица для кадровых заявок', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqHRDet';

