CREATE TABLE [dbo].[FCardsLost] (
    [fcId]    INT           IDENTITY (1, 1) NOT NULL,
    [CardNom] VARCHAR (25)  NULL,
    [uin]     INT           NULL,
    [LD]      DATETIME      NULL,
    [Comm]    VARCHAR (100) NULL,
    [p_id]    INT           NULL,
    UNIQUE NONCLUSTERED ([fcId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'утерянные топливные карты', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FCardsLost';

