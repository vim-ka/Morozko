CREATE TABLE [dbo].[FrizerLogDet] (
    [frl]       INT          IDENTITY (1, 1) NOT NULL,
    [ND]        DATETIME     DEFAULT (getdate()) NULL,
    [Nom]       INT          NULL,
    [OldNname]  VARCHAR (60) NULL,
    [NewNname]  VARCHAR (60) NULL,
    [OldInvNom] VARCHAR (20) NULL,
    [NewInvNom] VARCHAR (20) NULL,
    [OldNcod]   INT          NULL,
    [NewNcod]   INT          NULL,
    UNIQUE NONCLUSTERED ([frl] ASC)
);

