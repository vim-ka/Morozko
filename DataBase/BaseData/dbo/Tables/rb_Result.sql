CREATE TABLE [dbo].[rb_Result] (
    [Comp]    VARCHAR (30)    NULL,
    [ND]      DATETIME        NULL,
    [Ncod]    INT             NULL,
    [Ngrp]    INT             NULL,
    [hitag]   INT             NULL,
    [Perc]    DECIMAL (12, 2) NULL,
    [pin]     INT             NULL,
    [NetMode] BIT             NULL,
    [Sell]    INT             NULL,
    [Prod]    DECIMAL (12, 2) NULL,
    [SP]      DECIMAL (12, 2) NULL,
    [RRG]     INT             DEFAULT ((0)) NULL,
    [RbID]    INT             DEFAULT ((0)) NULL,
    [OurID]   TINYINT         NULL
);

