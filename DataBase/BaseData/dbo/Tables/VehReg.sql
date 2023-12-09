CREATE TABLE [dbo].[VehReg] (
    [id]     INT         IDENTITY (1, 1) NOT NULL,
    [V_ID]   INT         NULL,
    [Reg_ID] VARCHAR (3) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

