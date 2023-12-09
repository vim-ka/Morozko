CREATE TABLE [dbo].[PsScores_new] (
    [P_ID]  INT          NOT NULL,
    [StID]  INT          CONSTRAINT [DF__PsScores_new__stNom__33758E3C] DEFAULT ((0)) NOT NULL,
    [StNom] AS           ([P_ID]*(100)+[StID]) PERSISTED,
    [FName] VARCHAR (30) NULL,
    [Must]  MONEY        CONSTRAINT [DF__PsScores_new__Must__1C5D1EBA] DEFAULT ((0)) NULL,
    CONSTRAINT [PsScores_new_uq] UNIQUE NONCLUSTERED ([P_ID] ASC, [StID] ASC)
);

