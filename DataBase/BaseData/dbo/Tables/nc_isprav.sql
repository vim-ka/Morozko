CREATE TABLE [dbo].[nc_isprav] (
    [niid]          INT      IDENTITY (1, 1) NOT NULL,
    [datnom]        BIGINT   NOT NULL,
    [LastEditDate]  DATETIME NULL,
    [LastEditNomer] INT      NULL,
    [ND]            DATETIME DEFAULT ([dbo].[today]()) NULL,
    [OP]            INT      NULL,
    PRIMARY KEY CLUSTERED ([niid] ASC)
);

