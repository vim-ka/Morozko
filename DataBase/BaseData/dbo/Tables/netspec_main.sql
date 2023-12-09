CREATE TABLE [dbo].[netspec_main] (
    [nmid]       INT          IDENTITY (1, 1) NOT NULL,
    [StartDate]  DATETIME     NULL,
    [FinishDate] DATETIME     NULL,
    [OP]         INT          NULL,
    [Activ]      BIT          DEFAULT ((1)) NULL,
    [Remark]     VARCHAR (30) NULL,
    PRIMARY KEY CLUSTERED ([nmid] ASC)
);

