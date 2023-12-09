CREATE TABLE [RetroB].[rb_Vedom] (
    [vedID]     INT          IDENTITY (1, 1) NOT NULL,
    [day0]      DATETIME     NULL,
    [day1]      DATETIME     NULL,
    [ND]        DATETIME     DEFAULT (getdate()) NULL,
    [Comp]      VARCHAR (25) NULL,
    [Cancelled] BIT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([vedID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cancelled=1 если ведомость отменена.', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Vedom', @level2type = N'COLUMN', @level2name = N'Cancelled';

