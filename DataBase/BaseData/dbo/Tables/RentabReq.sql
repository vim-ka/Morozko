CREATE TABLE [dbo].[RentabReq] (
    [id]          INT             IDENTITY (1, 1) NOT NULL,
    [datefrom]    DATETIME        NULL,
    [dateto]      DATETIME        NULL,
    [calctip]     INT             NULL,
    [withactn]    BIT             DEFAULT ((0)) NULL,
    [isnet]       BIT             DEFAULT ((0)) NULL,
    [ncod]        INT             NULL,
    [withul]      BIT             DEFAULT ((0)) NULL,
    [ngrp]        INT             NULL,
    [adm_coeff]   NUMERIC (10, 2) NULL,
    [retrob_post] NUMERIC (10, 2) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

