CREATE TABLE [dbo].[rentabretrob2] (
    [date_from]  DATETIME        NULL,
    [date_to]    DATETIME        NULL,
    [calctip]    INT             NULL,
    [pin]        INT             NULL,
    [mainparent] INT             NULL,
    [obl_id]     INT             NULL,
    [sum_bonus]  NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [hitag]      INT             NULL,
    [ncod]       INT             NULL
);

