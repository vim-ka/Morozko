CREATE TABLE [dbo].[rb_Vedom] (
    [rbv]  INT      IDENTITY (1, 1) NOT NULL,
    [day0] DATETIME NULL,
    [day1] DATETIME NULL,
    [ND]   DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([rbv] ASC)
);

