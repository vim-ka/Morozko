CREATE TABLE [Guard].[GroupQuot] (
    [GqID]       INT             IDENTITY (1, 1) NOT NULL,
    [WorkDate]   DATETIME        NULL,
    [ag_ID]      INT             NULL,
    [B_ID]       INT             NULL,
    [Hitag]      INT             NULL,
    [PlanWeight] DECIMAL (10, 1) NULL,
    [PlanPcs]    INT             NULL,
    [OP]         INT             NULL,
    [Host_Name]  VARCHAR (30)    NULL,
    PRIMARY KEY CLUSTERED ([GqID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [GroupQuot_ABH]
    ON [Guard].[GroupQuot]([ag_ID] ASC, [B_ID] ASC, [Hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [GroupQuot_wrkdat]
    ON [Guard].[GroupQuot]([WorkDate] ASC);

