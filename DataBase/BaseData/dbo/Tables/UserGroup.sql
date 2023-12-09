CREATE TABLE [dbo].[UserGroup] (
    [id]     INT          IDENTITY (1, 1) NOT NULL,
    [grname] VARCHAR (20) NULL,
    [grprim] VARCHAR (50) NULL,
    [grpub]  BIT          DEFAULT ((0)) NULL,
    [ord]    INT          DEFAULT ((1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Группы пользователей - редактировать ОЧЕНЬ аккуратно', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserGroup';

