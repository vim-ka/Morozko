CREATE TABLE [dbo].[Phys] (
    [phId]        INT           IDENTITY (1, 1) NOT NULL,
    [Fio]         VARCHAR (100) NULL,
    [p_id]        INT           NULL,
    [ag_id]       INT           NULL,
    [sv_id]       INT           NULL,
    [uin]         INT           NULL,
    [DepID]       INT           NULL,
    [DepDirector] BIT           CONSTRAINT [DF__Phys__DepDirecto__3648A49D] DEFAULT ((0)) NULL,
    [trID]        INT           NULL,
    [Our_ID]      INT           NULL,
    [Phone]       CHAR (20)     NULL,
    [login]       VARCHAR (15)  NULL,
    [pwd]         VARCHAR (32)  NULL,
    [Email]       VARCHAR (50)  NULL,
    [Remark]      VARCHAR (50)  NULL,
    [Closed]      BIT           DEFAULT ((0)) NULL,
    [NDBeg]       DATETIME      NULL,
    [NDEnd]       DATETIME      NULL,
    [OP]          INT           NULL,
    PRIMARY KEY CLUSTERED ([phId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ заводившего оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата закрытия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'NDEnd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата заведения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'NDBeg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'закрыт', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'Closed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Комментарий', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Электронная почта', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пароль', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'pwd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логин', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'login';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Телефон', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код фирмы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'Our_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Должность', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'trID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Начальник отдела', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'DepDirector';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'отдел', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'DepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ключ usrpwd', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Phys', @level2type = N'COLUMN', @level2name = N'uin';

