CREATE TABLE [dbo].[Kassa1Rec] (
    [ISPR]      INT            IDENTITY (1, 1) NOT NULL,
    [ND]        DATETIME       DEFAULT (getdate()) NULL,
    [user_name] NVARCHAR (256) DEFAULT (suser_sname()) NULL,
    [host_name] NCHAR (30)     DEFAULT (host_name()) NULL,
    [app_name]  NVARCHAR (128) DEFAULT (app_name()) NULL,
    [type]      SMALLINT       NULL,
    [KassID]    INT            NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [Kassa1Rec_idx]
    ON [dbo].[Kassa1Rec]([KassID] ASC);

