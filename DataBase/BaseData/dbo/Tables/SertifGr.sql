CREATE TABLE [dbo].[SertifGr] (
    [IdGR]  INT IDENTITY (1, 1) NOT NULL,
    [Ngrp]  INT NULL,
    [IdCat] INT NULL,
    CONSTRAINT [PK_SertifGr_IdGR_copy] PRIMARY KEY CLUSTERED ([IdGR] ASC)
);

