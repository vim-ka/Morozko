CREATE TABLE [dbo].[helpdocs] (
    [hid]   INT           IDENTITY (1, 1) NOT NULL,
    [hrtf]  TEXT          NULL,
    [hprim] VARCHAR (200) NULL,
    UNIQUE NONCLUSTERED ([hid] ASC)
);

