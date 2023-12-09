﻿CREATE TABLE [dbo].[printMain] (
    [PmID]        INT             IDENTITY (1, 1) NOT NULL,
    [Comp]        VARCHAR (30)    NULL,
    [datnom]      BIGINT          NULL,
    [B_ID]        INT             NULL,
    [OurID]       SMALLINT        NULL,
    [gpOur_ID]    INT             NULL,
    [StfDate]     DATETIME        NULL,
    [Stfnom]      VARCHAR (50)    NULL,
    [SP]          DECIMAL (12, 2) NULL,
    [SNds]        DECIMAL (10, 2) NULL,
    [SNds10]      DECIMAL (10, 2) NULL,
    [SNds18]      DECIMAL (10, 2) NULL,
    [SNds20]      DECIMAL (10, 2) NULL,
    [SBase10]     DECIMAL (10, 2) NULL,
    [SBase18]     DECIMAL (10, 2) NULL,
    [SBase20]     DECIMAL (10, 2) NULL,
    [SKol]        DECIMAL (10, 3) NULL,
    [SNetto]      DECIMAL (10, 3) NULL,
    [SBrutto]     DECIMAL (10, 3) NULL,
    [SBox]        DECIMAL (8, 1)  NULL,
    [BrName]      VARCHAR (255)   NULL,
    [BrAddress]   VARCHAR (255)   NULL,
    [BrINN]       VARCHAR (15)    NULL,
    [BrKpp]       VARCHAR (15)    NULL,
    [BrOGRN]      VARCHAR (15)    NULL,
    [BrBIK]       VARCHAR (15)    NULL,
    [BrBank]      VARCHAR (200)   NULL,
    [BrRSchet]    VARCHAR (50)    NULL,
    [BrCSchet]    VARCHAR (50)    NULL,
    [gpName]      VARCHAR (255)   NULL,
    [gpAddress]   VARCHAR (255)   NULL,
    [gpINN]       VARCHAR (15)    NULL,
    [gpKpp]       VARCHAR (15)    NULL,
    [gpOGRN]      VARCHAR (15)    NULL,
    [gpBIK]       VARCHAR (15)    NULL,
    [gpBank]      VARCHAR (200)   NULL,
    [gpRSchet]    VARCHAR (50)    NULL,
    [gpCSchet]    VARCHAR (50)    NULL,
    [ourName]     VARCHAR (255)   NULL,
    [ourAddress]  VARCHAR (255)   NULL,
    [ourINN]      VARCHAR (15)    NULL,
    [ourKpp]      VARCHAR (15)    NULL,
    [ourOGRN]     VARCHAR (15)    NULL,
    [ourBIK]      VARCHAR (15)    NULL,
    [ourBank]     VARCHAR (200)   NULL,
    [ourRSchet]   VARCHAR (50)    NULL,
    [ourCSchet]   VARCHAR (50)    NULL,
    [ourDirector] VARCHAR (50)    NULL,
    [ourGlavbuh]  VARCHAR (50)    NULL,
    [OpFam]       VARCHAR (50)    NULL,
    [Kladov]      VARCHAR (50)    NULL,
    [PrikazNom]   VARCHAR (50)    NULL,
    [PrikazDate]  DATETIME        NULL,
    [VehNomer]    VARCHAR (20)    NULL,
    [VehName]     VARCHAR (50)    NULL,
    [Driver]      VARCHAR (50)    NULL,
    [brIndex]     VARCHAR (6)     NULL,
    [NkHead]      VARCHAR (30)    DEFAULT ('Накладная') NULL,
    [Suff]        VARCHAR (20)    NULL,
    [Srok]        INT             DEFAULT ((30)) NULL,
    [AgentPhone]  VARCHAR (30)    NULL,
    PRIMARY KEY CLUSTERED ([PmID] ASC)
);
