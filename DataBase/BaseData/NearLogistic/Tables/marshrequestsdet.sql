CREATE TABLE [NearLogistic].[marshrequestsdet] (
    [mrdid]     INT             IDENTITY (1, 1) NOT NULL,
    [mrfid]     INT             NOT NULL,
    [point_id]  INT             NOT NULL,
    [action_id] INT             NOT NULL,
    [nd]        DATETIME        NULL,
    [vol]       DECIMAL (15, 4) NULL,
    [mas]       DECIMAL (15, 4) NULL,
    [pal]       INT             NULL,
    [place]     INT             DEFAULT ((0)) NOT NULL
);

