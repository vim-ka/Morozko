CREATE TABLE [dbo].[CheckPrint] (
    [CpID]            INT             IDENTITY (1, 1) NOT NULL,
    [nd]              DATETIME        DEFAULT ([dbo].[today]()) NULL,
    [TM]              VARCHAR (8)     DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Comp]            VARCHAR (30)    DEFAULT (host_name()) NULL,
    [Tip]             SMALLINT        DEFAULT ((0)) NULL,
    [flgPrepaid]      BIT             DEFAULT ((0)) NULL,
    [SP]              DECIMAL (10, 2) NULL,
    [RefCpID]         INT             DEFAULT ((0)) NOT NULL,
    [KassType]        SMALLINT        DEFAULT ((0)) NULL,
    [KassCheckNumber] INT             DEFAULT ((0)) NULL,
    [KassID]          INT             NULL,
    PRIMARY KEY CLUSTERED ([CpID] ASC)
);

