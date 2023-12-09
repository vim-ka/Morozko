CREATE TABLE [dbo].[tdSver] (
    [tdsId]       INT             IDENTITY (1, 1) NOT NULL,
    [ND]          DATETIME        NULL,
    [Comp]        VARCHAR (20)    NULL,
    [Hitag]       INT             NULL,
    [Sklad]       SMALLINT        NULL,
    [Weight]      VARCHAR (7)     NULL,
    [Box]         INT             NULL,
    [Delta]       INT             NULL,
    [Done]        BIT             CONSTRAINT [DF__tdSver__Done__08012052] DEFAULT ((0)) NULL,
    [TomorrowRez] INT             DEFAULT ((0)) NULL,
    [ID]          INT             NULL,
    [SP]          DECIMAL (12, 2) NULL,
    CONSTRAINT [tdSver_pk] PRIMARY KEY CLUSTERED ([tdsId] ASC)
);

