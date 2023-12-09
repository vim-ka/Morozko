CREATE TABLE [dbo].[MtConk] (
    [cID]  INT           IDENTITY (1, 1) NOT NULL,
    [ND]   DATETIME      NULL,
    [pin]  INT           NULL,
    [Ngrp] INT           NULL,
    [Conk] VARCHAR (254) NULL,
    PRIMARY KEY CLUSTERED ([cID] ASC)
);

