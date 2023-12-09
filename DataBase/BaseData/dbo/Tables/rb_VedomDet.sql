CREATE TABLE [dbo].[rb_VedomDet] (
    [rbv]       INT             NULL,
    [DepId]     INT             NULL,
    [B_ID]      INT             NULL,
    [rbID]      INT             NULL,
    [Remark]    VARCHAR (50)    NULL,
    [PayBySell] BIT             NULL,
    [Sell]      DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [Pay]       DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [Perc]      DECIMAL (6, 2)  NULL,
    [Bonus]     DECIMAL (12, 2) NULL,
    [Otvet]     VARCHAR (50)    NULL,
    [Black]     TINYINT         NULL,
    [OborBonus] DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [OurID]     TINYINT         NULL
);

