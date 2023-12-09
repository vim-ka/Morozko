CREATE TABLE [dbo].[MatrixKZ] (
    [KzID]  INT            IDENTITY (1, 1) NOT NULL,
    [DepID] INT            NULL,
    [SV_ID] INT            NULL,
    [AG_ID] INT            NULL,
    [DCK]   INT            NULL,
    [B_ID]  INT            NULL,
    [Ngrp]  INT            NULL,
    [Hitag] INT            NULL,
    [KZ]    DECIMAL (6, 3) NULL,
    PRIMARY KEY CLUSTERED ([KzID] ASC)
);

