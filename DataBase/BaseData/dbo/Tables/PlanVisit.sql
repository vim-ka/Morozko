CREATE TABLE [dbo].[PlanVisit] (
    [id]    INT      IDENTITY (1, 1) NOT NULL,
    [pin]   INT      NOT NULL,
    [dck]   INT      NOT NULL,
    [ag_id] INT      NULL,
    [dt1]   SMALLINT CONSTRAINT [DF__PlanVisit__dt1__740F363E] DEFAULT ((0)) NULL,
    [dt2]   SMALLINT CONSTRAINT [DF__PlanVisit__dt2__75035A77] DEFAULT ((0)) NULL,
    [dt3]   SMALLINT CONSTRAINT [DF__PlanVisit__dt3__75F77EB0] DEFAULT ((0)) NULL,
    [dt4]   SMALLINT CONSTRAINT [DF__PlanVisit__dt4__76EBA2E9] DEFAULT ((0)) NULL,
    [dt5]   SMALLINT CONSTRAINT [DF__PlanVisit__dt5__77DFC722] DEFAULT ((0)) NULL,
    [dt6]   SMALLINT CONSTRAINT [DF__PlanVisit__dt6__78D3EB5B] DEFAULT ((0)) NULL,
    [dt7]   SMALLINT CONSTRAINT [DF__PlanVisit__dt7__79C80F94] DEFAULT ((0)) NULL,
    [tip1]  TINYINT  CONSTRAINT [DF__PlanVisit__tip1__473E2675] DEFAULT ((0)) NULL,
    [tip2]  TINYINT  CONSTRAINT [DF__PlanVisit__tip2__48324AAE] DEFAULT ((0)) NULL,
    [tip3]  TINYINT  CONSTRAINT [DF__PlanVisit__tip3__49266EE7] DEFAULT ((0)) NULL,
    [tip4]  TINYINT  CONSTRAINT [DF__PlanVisit__tip4__4A1A9320] DEFAULT ((0)) NULL,
    [tip5]  TINYINT  CONSTRAINT [DF__PlanVisit__tip5__4B0EB759] DEFAULT ((0)) NULL,
    [tip6]  TINYINT  CONSTRAINT [DF__PlanVisit__tip6__4C02DB92] DEFAULT ((0)) NULL,
    [tip7]  TINYINT  CONSTRAINT [DF__PlanVisit__tip7__4CF6FFCB] DEFAULT ((0)) NULL,
    CONSTRAINT [PlanVisit_pk] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [PlanVisit_uq] UNIQUE NONCLUSTERED ([pin] ASC, [ag_id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PlanVisit', @level2type = N'COLUMN', @level2name = N'dck';

