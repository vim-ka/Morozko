CREATE TABLE [RestMon].[rm_Job] (
    [hitag]     INT      NULL,
    [Sklad]     SMALLINT NULL,
    [MinRest]   INT      NULL,
    [GetPart]   INT      NULL,
    [tip]       SMALLINT DEFAULT ((1)) NULL,
    [LockRest]  INT      DEFAULT ((0)) NULL,
    [Ncod]      INT      NULL,
    [SourSklad] INT      NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Если tip=2 и текущий остаток<=LockRest, строка блокируется.', @level0type = N'SCHEMA', @level0name = N'RestMon', @level1type = N'TABLE', @level1name = N'rm_Job', @level2type = N'COLUMN', @level2name = N'LockRest';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-задача перемещения,2-блокировки', @level0type = N'SCHEMA', @level0name = N'RestMon', @level1type = N'TABLE', @level1name = N'rm_Job', @level2type = N'COLUMN', @level2name = N'tip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отслеживаемый склад', @level0type = N'SCHEMA', @level0name = N'RestMon', @level1type = N'TABLE', @level1name = N'rm_Job', @level2type = N'COLUMN', @level2name = N'Sklad';

