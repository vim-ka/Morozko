CREATE TABLE [dbo].[rentabbasecalctable] (
    [date_from]  DATETIME        NULL,
    [date_to]    DATETIME        NULL,
    [calctip]    INT             NULL,
    [pin]        INT             NULL,
    [hitag]      INT             NULL,
    [mainparent] INT             NULL,
    [obl_id]     INT             NULL,
    [nds]        NUMERIC (5, 2)  NULL,
    [datnom]     INT             NULL,
    [refdatnom]  INT             NULL,
    [postvol]    NUMERIC (12, 3) NULL,
    [postvol2]   NUMERIC (12, 3) NULL,
    [cost]       NUMERIC (12, 3) NULL,
    [price]      NUMERIC (12, 3) NULL
);

