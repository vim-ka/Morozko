CREATE TABLE [dbo].[SRep_GR] (
    [Ngrp]    INT          NOT NULL,
    [GrpName] VARCHAR (30) NULL,
    [Vet]     BIT          DEFAULT (0) NULL,
    PRIMARY KEY CLUSTERED ([Ngrp] ASC)
);

