CREATE TABLE [dbo].[FMonitorPics] (
    [mpID]    INT          IDENTITY (1, 1) NOT NULL,
    [fmID]    INT          NOT NULL,
    [PicName] VARCHAR (50) NULL,
    [Done]    BIT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([mpID] ASC)
);

