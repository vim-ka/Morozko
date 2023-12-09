CREATE TABLE [dbo].[bp2] (
    [Hitag]    INT          NULL,
    [B_ID]     INT          NULL,
    [Price]    MONEY        NULL,
    [isWeight] BIT          DEFAULT ((0)) NULL,
    [Comp]     VARCHAR (16) NULL,
    [OP]       INT          NULL,
    [Saved]    DATETIME     DEFAULT (getdate()) NULL
);

