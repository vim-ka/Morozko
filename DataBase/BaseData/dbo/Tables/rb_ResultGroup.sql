CREATE TABLE [dbo].[rb_ResultGroup] (
    [RRG]         INT          IDENTITY (1, 1) NOT NULL,
    [Day0]        DATETIME     NULL,
    [Day1]        DATETIME     NULL,
    [ND]          DATETIME     DEFAULT (getdate()) NULL,
    [Op]          INT          NULL,
    [CName]       VARCHAR (15) NULL,
    [Progress]    INT          CONSTRAINT [DF__rb_Result__Progr__1B806B1F] DEFAULT ((0)) NULL,
    [RestTimeMin] INT          NULL,
    PRIMARY KEY CLUSTERED ([RRG] ASC)
);

