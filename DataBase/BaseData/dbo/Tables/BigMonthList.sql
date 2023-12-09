CREATE TABLE [dbo].[BigMonthList] (
    [b_id]  INT NULL,
    [hitag] INT NULL
);


GO
CREATE NONCLUSTERED INDEX [BML_Hitag_idx]
    ON [dbo].[BigMonthList]([hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [BML_BID_idx]
    ON [dbo].[BigMonthList]([b_id] ASC);

