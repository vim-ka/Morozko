CREATE TABLE [dbo].[MarshArcMain] (
    [nom]      INT          IDENTITY (1, 1) NOT NULL,
    [SaveDate] DATETIME     DEFAULT (getdate()) NULL,
    [ND]       DATETIME     NULL,
    [Comp]     VARCHAR (20) NULL,
    [M99]      INT          NULL,
    [remark]   VARCHAR (40) NULL,
    PRIMARY KEY CLUSTERED ([nom] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число нак. с Marsh=99', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshArcMain', @level2type = N'COLUMN', @level2name = N'M99';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К какой дате относится', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshArcMain', @level2type = N'COLUMN', @level2name = N'ND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Когда записан архив', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshArcMain', @level2type = N'COLUMN', @level2name = N'SaveDate';

