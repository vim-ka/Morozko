CREATE TABLE [NearLogistic].[bills_det] (
    [mhid]         INT             NULL,
    [reqid]        INT             NULL,
    [casher_id]    INT             NULL,
    [mas]          DECIMAL (15, 4) NULL,
    [vol]          DECIMAL (15, 4) NULL,
    [p1]           INT             NULL,
    [p2]           INT             NULL,
    [ord]          INT             NULL,
    [is_old]       BIT             NULL,
    [row_id]       INT             NULL,
    [distance_p1]  INT             NULL,
    [distance_p2]  INT             NULL,
    [km]           INT             NULL,
    [tax]          MONEY           NULL,
    [distance_mas] DECIMAL (15, 4) NULL,
    [distance_vol] DECIMAL (15, 4) NULL,
    [vol_cost]     MONEY           NULL,
    [mas_cost]     MONEY           NULL,
    [req_pay]      MONEY           NULL
);

