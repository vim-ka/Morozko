CREATE TABLE [dbo].[VendGroups] (
    [Ncod]   INT NULL,
    [DCK]    INT NULL,
    [Ngrp]   INT NULL,
    [VendCL] INT NULL,
    CONSTRAINT [VendGroups_fk3] FOREIGN KEY ([VendCL]) REFERENCES [dbo].[VendClass] ([VendCL]) ON UPDATE CASCADE
);

