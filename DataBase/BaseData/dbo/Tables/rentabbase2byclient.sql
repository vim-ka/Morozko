﻿CREATE TABLE [dbo].[rentabbase2byclient] (
    [date_from]         DATETIME        NULL,
    [date_to]           DATETIME        NULL,
    [calctip]           INT             NULL,
    [pin]               INT             NULL,
    [s_postvol]         NUMERIC (18, 3) NULL,
    [s_postvol2]        NUMERIC (18, 3) NULL,
    [s_cost]            NUMERIC (18, 3) NULL,
    [s_price]           NUMERIC (18, 3) NULL,
    [naz_proc]          NUMERIC (18, 3) NULL,
    [naz_with_NDS]      NUMERIC (18, 3) NULL,
    [NDS]               NUMERIC (5, 2)  NULL,
    [naz_withoutNDS]    NUMERIC (18, 3) NULL,
    [naz_kg]            NUMERIC (18, 3) NULL,
    [naz_kg_withoutNDS] NUMERIC (18, 3) NULL,
    [avg_cost]          NUMERIC (18, 3) NULL,
    [avg_price]         NUMERIC (18, 3) NULL,
    [s_postvol_kol]     NUMERIC (18, 3) NULL,
    [s_postvol2_kol]    NUMERIC (18, 3) NULL,
    [a_postvol_kol]     NUMERIC (18, 3) DEFAULT ((0)) NULL,
    [a_postvol_kol2]    NUMERIC (18, 3) DEFAULT ((0)) NULL,
    [fg]                INT             DEFAULT ((-1)) NULL,
    [real_pin]          INT             DEFAULT ((-1)) NULL
);
