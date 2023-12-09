CREATE TABLE [dbo].[MarketRequest] (
    [id]         INT             IDENTITY (1, 1) NOT NULL,
    [nd]         DATETIME        NULL,
    [p_id]       INT             NULL,
    [locked]     BIT             DEFAULT ((0)) NULL,
    [stat]       INT             DEFAULT ((1)) NULL,
    [month]      INT             NULL,
    [year]       INT             NULL,
    [otv]        INT             DEFAULT ((-1)) NULL,
    [datefrom]   DATETIME        NULL,
    [dateto]     DATETIME        NULL,
    [actobj]     INT             DEFAULT ((-1)) NULL,
    [acttarget]  INT             DEFAULT ((-1)) NULL,
    [calcrules]  INT             DEFAULT ((-1)) NULL,
    [sum_kol]    INT             DEFAULT ((0)) NULL,
    [must_kol]   INT             DEFAULT ((0)) NULL,
    [bonus_kol]  INT             DEFAULT ((0)) NULL,
    [sum_weight] NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [sum_sum]    NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [pin]        INT             DEFAULT ((-1)) NULL,
    [ag_prem]    NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [comment]    VARCHAR (1024)  NULL,
    [isnet]      BIT             DEFAULT ((0)) NULL,
    [uname]      VARCHAR (512)   NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tip 0 - обычный бюджет
tip 1 - бюджет по превышениям
tip 2 - бюджет компенсации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketRequest';

