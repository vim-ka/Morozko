CREATE TABLE [dbo].[usrBankScores] (
    [usrID]    INT           IDENTITY (1, 1) NOT NULL,
    [uin]      INT           NULL,
    [FIO]      VARCHAR (100) NULL,
    [p_id]     INT           NULL,
    [numScore] VARCHAR (20)  NULL,
    PRIMARY KEY CLUSTERED ([usrID] ASC)
);

