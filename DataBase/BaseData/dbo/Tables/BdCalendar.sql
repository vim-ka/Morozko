CREATE TABLE [dbo].[BdCalendar] (
    [BcID]     INT          IDENTITY (1, 1) NOT NULL,
    [BkID]     INT          NOT NULL,
    [nd]       DATETIME     CONSTRAINT [DF__BdCalendar__nd__060EB63F] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [tm]       CHAR (8)     CONSTRAINT [DF__BdCalendar__tm__0702DA78] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Oper]     INT          NULL,
    [Plata]    MONEY        CONSTRAINT [DF__BdCalendar__Plata__7B4643B2] DEFAULT ((0)) NOT NULL,
    [Remark]   VARCHAR (60) NULL,
    [RashFlag] INT          NULL,
    [LostFlag] INT          NULL,
    [LastFlag] TINYINT      NULL,
    [Op]       INT          NULL,
    [Our_ID]   INT          NULL,
    [DepID]    INT          CONSTRAINT [DF__BdCalendar__DepID__6740165C] DEFAULT ((0)) NULL,
    [PlanND]   DATETIME     NULL,
    [Period]   INT          CONSTRAINT [DF__BdCalendar__Period__27AFA12C] DEFAULT ((0)) NULL,
    [BNflag]   BIT          DEFAULT ((0)) NULL,
    [ndPlat]   DATETIME     NULL,
    CONSTRAINT [BdCalendar_pk] PRIMARY KEY CLUSTERED ([BcID] ASC)
);

