CREATE TABLE [db_FarLogistic].[dlDriveTruck] (
    [drid] INT NULL,
    [v_id] INT NULL,
    [dtID] INT IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [dlDriveTruck_pk] PRIMARY KEY CLUSTERED ([dtID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД транспорта', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDriveTruck', @level2type = N'COLUMN', @level2name = N'v_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД водителя', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDriveTruck', @level2type = N'COLUMN', @level2name = N'drid';

