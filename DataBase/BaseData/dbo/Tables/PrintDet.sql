﻿CREATE TABLE [dbo].[PrintDet] (
    [comp]        VARCHAR (30)     NULL,
    [Datnom]      BIGINT           NULL,
    [startdatnom] BIGINT           NULL,
    [Tekid]       INT              NULL,
    [Hitag]       INT              NULL,
    [Sklad]       INT              NULL,
    [SkladGroup]  INT              NULL,
    [Name]        VARCHAR (90)     NULL,
    [FName]       VARCHAR (100)    NULL,
    [LongName]    VARCHAR (100)    NULL,
    [Kol]         DECIMAL (10, 3)  NULL,
    [UnID]        INT              NULL,
    [UnitName]    VARCHAR (5)      NULL,
    [K]           DECIMAL (18, 10) DEFAULT ((1)) NULL,
    [Price]       DECIMAL (12, 4)  NULL,
    [Cost]        DECIMAL (12, 4)  NULL,
    [Netto]       DECIMAL (10, 3)  NULL,
    [Brutto]      DECIMAL (10, 3)  NULL,
    [Country]     VARCHAR (50)     NULL,
    [CountryID]   INT              NULL,
    [FabID]       INT              NULL,
    [NDS]         SMALLINT         DEFAULT ((18)) NULL,
    [Sert_ID]     INT              NULL,
    [Dater]       DATETIME         NULL,
    [SrokH]       DATETIME         NULL,
    [Extra]       DECIMAL (7, 2)   DEFAULT ((0)) NULL,
    [Box]         INT              DEFAULT ((1)) NULL
);

