CREATE TABLE [dbo].[_antor_load_data] (
    [id]     INT IDENTITY (1, 1) NOT NULL,
    [marsh]  INT NULL,
    [datnom] INT NULL,
    [ord]    INT NULL,
    [done]   BIT DEFAULT ((0)) NOT NULL
);

