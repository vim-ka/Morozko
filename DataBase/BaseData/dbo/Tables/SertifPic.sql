CREATE TABLE [dbo].[SertifPic] (
    [PicK]     INT             IDENTITY (1, 1) NOT NULL,
    [sert_id]  INT             NULL,
    [SPic]     VARBINARY (MAX) NULL,
    [SPicName] VARCHAR (20)    NULL,
    [ND]       DATETIME        CONSTRAINT [DF__SertifPic__ND__45CA13F8] DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [TM]       CHAR (8)        CONSTRAINT [DF__SertifPic__TM__46BE3831] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Op]       SMALLINT        NULL,
    [isDel]    BIT             DEFAULT ((0)) NOT NULL,
    UNIQUE NONCLUSTERED ([PicK] ASC)
);

