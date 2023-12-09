CREATE TABLE [LoadData].[ExpSales] (
    [Comp]        VARCHAR (30)    NULL,
    [DepID]       INT             NULL,
    [sv_id]       INT             NULL,
    [ag_id]       SMALLINT        NULL,
    [b_id]        INT             NOT NULL,
    [DepName]     VARCHAR (70)    NULL,
    [Super]       VARCHAR (100)   NULL,
    [Agent]       VARCHAR (112)   NULL,
    [Klient]      VARCHAR (255)   NULL,
    [SP]          NUMERIC (12, 2) NULL,
    [SC]          DECIMAL (12, 2) NULL,
    [InpSC]       DECIMAL (12, 2) NULL,
    [PercDebit]   NUMERIC (12, 2) NULL,
    [SrokFact]    INT             NOT NULL,
    [PDZ7]        MONEY           NULL,
    [Nacenka]     NUMERIC (12, 2) NULL,
    [PercNacenka] NUMERIC (12, 2) NULL,
    [Back]        DECIMAL (12, 2) NULL,
    [PercBack]    NUMERIC (12, 2) NULL,
    [QtySKU]      INT             NULL
);

