CREATE TABLE [NearLogistic].[MarshStatus] (
    [msID]   INT          NOT NULL,
    [msName] VARCHAR (20) NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__MarshSta__763458CF12EEF7CB]
    ON [NearLogistic].[MarshStatus]([msID] ASC);

