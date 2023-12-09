CREATE TABLE [dbo].[ExLog] (
    [ND]      DATETIME      DEFAULT (getdate()) NULL,
    [OP]      INT           NULL,
    [FIO]     VARCHAR (50)  NULL,
    [Remark]  VARCHAR (150) NULL,
    [BegDATE] DATETIME      NULL,
    [EndDATE] DATETIME      NULL
);

