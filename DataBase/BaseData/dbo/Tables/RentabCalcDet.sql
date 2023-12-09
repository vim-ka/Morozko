CREATE TABLE [dbo].[RentabCalcDet] (
    [id]         INT             IDENTITY (1, 1) NOT NULL,
    [type]       SMALLINT        DEFAULT ((0)) NULL,
    [terr_depid] INT             DEFAULT ((0)) NULL,
    [val]        NUMERIC (10, 2) DEFAULT ((0)) NULL,
    [val_type]   SMALLINT        DEFAULT ((0)) NULL,
    [parent_id]  INT             DEFAULT ((-1)) NULL,
    [datefrom]   DATETIME        NULL,
    [dateto]     DATETIME        NULL,
    [hitag]      INT             NULL,
    [ngrp]       INT             NULL,
    [ncod]       INT             NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

