CREATE TABLE [dbo].[SertifVetisAPIlog] (
    [ID]                INT           IDENTITY (1, 1) NOT NULL,
    [ReqType]           SMALLINT      NULL,
    [Operation]         VARCHAR (255) NULL,
    [rcvDate]           DATETIME      NULL,
    [rsltDate]          DATETIME      NULL,
    [Login]             VARCHAR (255) NULL,
    [IssuerID]          VARCHAR (255) NULL,
    [Op]                INT           NULL,
    [Host]              NCHAR (30)    DEFAULT (host_name()) NULL,
    [Req]               VARCHAR (MAX) NULL,
    [Res]               VARCHAR (MAX) NULL,
    [ApplicationStatus] SMALLINT      NULL,
    [ErrCode]           VARCHAR (255) NULL,
    [ErrText]           VARCHAR (MAX) NULL,
    CONSTRAINT [PK_SertifVetisAPIlog_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=ACCEPTED,  1=IN_PROCESS,  2=COMPLETED,  3=REJECTED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifVetisAPIlog';

