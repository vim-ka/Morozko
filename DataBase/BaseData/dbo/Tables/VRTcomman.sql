CREATE TABLE [dbo].[VRTcomman] (
    [Ncom]       INT         IDENTITY (1, 1) NOT NULL,
    [date]       DATETIME    NULL,
    [Time]       VARCHAR (8) NULL,
    [our_id]     SMALLINT    NULL,
    [our_idFrom] SMALLINT    NULL,
    CONSTRAINT [PK_VRTcomman_Ncom] PRIMARY KEY CLUSTERED ([Ncom] ASC)
);

