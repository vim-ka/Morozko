CREATE TABLE [dbo].[SkladPersonal] (
    [spk]    INT           IDENTITY (1, 1) NOT NULL,
    [FIO]    VARCHAR (128) NULL,
    [Closed] BIT           DEFAULT ((0)) NULL,
    [p_id]   INT           NULL,
    [trID]   INT           DEFAULT ((0)) NULL,
    [uin]    INT           DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([spk] ASC)
);


GO
CREATE NONCLUSTERED INDEX [SkladPersonal_idx3]
    ON [dbo].[SkladPersonal]([trID] ASC);


GO
CREATE NONCLUSTERED INDEX [SkladPersonal_idx2]
    ON [dbo].[SkladPersonal]([p_id] ASC);


GO
CREATE NONCLUSTERED INDEX [SkladPersonal_idx]
    ON [dbo].[SkladPersonal]([spk] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Внешний ключ на usrPwd', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladPersonal', @level2type = N'COLUMN', @level2name = N'uin';

