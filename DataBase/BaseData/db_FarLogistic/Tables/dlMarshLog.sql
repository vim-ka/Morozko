﻿CREATE TABLE [db_FarLogistic].[dlMarshLog] (
    [dlMarshID]       INT           NOT NULL,
    [pin]             INT           NULL,
    [IDdlVehicles]    INT           NULL,
    [IDdlDrivers]     INT           NULL,
    [IDdlMarshStatus] INT           NULL,
    [odo_beg_fact]    INT           NULL,
    [odo_end_fact]    INT           NULL,
    [dt_beg_fact]     DATETIME      NULL,
    [dt_beg_plan]     DATETIME      NULL,
    [dt_end_fact]     DATETIME      NULL,
    [dt_end_plan]     DATETIME      NULL,
    [idTrailer]       INT           NULL,
    [date_creation]   DATETIME      NULL,
    [IDUsrPwd]        INT           NULL,
    [PlanDistance]    INT           NULL,
    [PlanCost]        MONEY         NULL,
    [FactDistance]    INT           NULL,
    [FactCost]        MONEY         NULL,
    [Comment]         VARCHAR (100) NULL,
    [dt_cancel]       DATETIME      NULL,
    [SubMarsh]        BIT           NULL,
    [SubFirstName]    VARCHAR (30)  NULL,
    [SubMiddleName]   VARCHAR (30)  NULL,
    [SubSurname]      VARCHAR (30)  NULL,
    [SubPass]         VARCHAR (100) NULL,
    [SubDrvDoc]       VARCHAR (15)  NULL,
    [SubVehInfo]      VARCHAR (100) NULL,
    [SubTrailerInfo]  VARCHAR (100) NULL,
    [SubPhone]        VARCHAR (100) NULL,
    [Comp]            VARCHAR (50)  DEFAULT (host_name()) NULL,
    [DT]              VARCHAR (10)  DEFAULT (CONVERT([varchar](10),getdate(),(104))) NULL,
    [TM]              VARCHAR (10)  DEFAULT (CONVERT([varchar](10),getdate(),(108))) NULL,
    [AppName]         VARCHAR (50)  DEFAULT (app_name()) NULL,
    [Action]          VARCHAR (5)   NULL
);

