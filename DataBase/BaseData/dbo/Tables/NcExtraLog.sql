CREATE TABLE [dbo].[NcExtraLog] (
    [ND]         DATETIME       DEFAULT (getdate()) NULL,
    [SourDatnom] BIGINT         NULL,
    [NewDatnom]  BIGINT         NULL,
    [SourExtra]  DECIMAL (7, 2) NULL,
    [NewExtra]   DECIMAL (7, 2) NULL,
    [Remark]     VARCHAR (80)   NULL,
    [Comp]       VARCHAR (20)   NULL,
    [Op]         INT            NULL
);

