CREATE TABLE [dbo].[ScanSklad] (
    [sid]        INT      IDENTITY (1, 1) NOT NULL,
    [mhid]       INT      NULL,
    [act]        TINYINT  NULL,
    [nd]         DATETIME CONSTRAINT [DF__ScanSklad__nd__54F8DF9D] DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [tm]         CHAR (8) CONSTRAINT [DF__ScanSklad__tm__55ED03D6] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [tmStart]    CHAR (8) NULL,
    [tmEnd]      CHAR (8) NULL,
    [spk]        INT      NULL,
    [trID]       INT      NULL,
    [skg]        INT      NULL,
    [checking]   BIT      NULL,
    [tmChecking] CHAR (8) NULL,
    [OP]         INT      NULL,
    [marsh]      INT      NULL,
    [ndmarsh]    DATETIME NULL,
    CONSTRAINT [PK__ScanSkla__DDDFDD365EEFD6CE] PRIMARY KEY CLUSTERED ([sid] ASC)
);

