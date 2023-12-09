CREATE TABLE [dbo].[CommanServ] (
    [csID] INT IDENTITY (1, 1) NOT NULL,
    [ncom] INT NULL,
    [stID] INT NULL,
    [qty]  INT DEFAULT ((0)) NULL,
    CONSTRAINT [PK_CommanServ_csID] PRIMARY KEY CLUSTERED ([csID] ASC)
);

