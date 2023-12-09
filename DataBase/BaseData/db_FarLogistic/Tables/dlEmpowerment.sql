CREATE TABLE [db_FarLogistic].[dlEmpowerment] (
    [dlEmpowermentID] INT      NOT NULL,
    [CasherID]        INT      NULL,
    [DriverID]        INT      NULL,
    [VehicleID]       INT      NULL,
    [PricepID]        INT      NULL,
    [DateFrom]        DATE     NULL,
    [DateCreate]      DATETIME NULL,
    [uin]             INT      NULL,
    [DateTO]          DATE     NULL,
    [ActID]           INT      NULL,
    [Our_ID]          INT      NULL,
    CONSTRAINT [dlEmpowerment_uq] UNIQUE NONCLUSTERED ([Our_ID] ASC, [dlEmpowermentID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Действие', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlEmpowerment', @level2type = N'COLUMN', @level2name = N'ActID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пользователь', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlEmpowerment', @level2type = N'COLUMN', @level2name = N'uin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата создания', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlEmpowerment', @level2type = N'COLUMN', @level2name = N'DateCreate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата С', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlEmpowerment', @level2type = N'COLUMN', @level2name = N'DateFrom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД прицеп', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlEmpowerment', @level2type = N'COLUMN', @level2name = N'PricepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД автомобиля', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlEmpowerment', @level2type = N'COLUMN', @level2name = N'VehicleID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД Водителя', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlEmpowerment', @level2type = N'COLUMN', @level2name = N'DriverID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД плательщика', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlEmpowerment', @level2type = N'COLUMN', @level2name = N'CasherID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД доверенности', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlEmpowerment', @level2type = N'COLUMN', @level2name = N'dlEmpowermentID';

