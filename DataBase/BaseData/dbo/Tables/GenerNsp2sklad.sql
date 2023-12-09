CREATE TABLE [dbo].[GenerNsp2sklad] (
    [Comp]  VARCHAR (20) NULL,
    [sklad] INT          NULL,
    [Enab]  BIT          DEFAULT ((1)) NULL
);


GO
CREATE CLUSTERED INDEX [GenerNsp2sklad_idx]
    ON [dbo].[GenerNsp2sklad]([Comp] ASC, [sklad] ASC);

