CREATE TABLE [warehouse].[BackTypes] (
    [btID]       INT          IDENTITY (1, 1) NOT NULL,
    [btName]     VARCHAR (50) NOT NULL,
    [btnName]    VARCHAR (10) DEFAULT ('') NOT NULL,
    [btnCaption] VARCHAR (5)  DEFAULT ('') NOT NULL,
    [clr]        VARCHAR (50) CONSTRAINT [DF__BackTypes__clr__4BA6163B] DEFAULT ('') NOT NULL,
    [ord]        INT          DEFAULT ((0)) NOT NULL,
    [clr_]       INT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([btID] ASC)
);

