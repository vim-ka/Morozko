CREATE TABLE [dbo].[HlebTemp] (
    [INV_NUM]    CHAR (20)       NULL,
    [INV_DATE]   DATETIME        NULL,
    [CL_ID]      CHAR (20)       NULL,
    [ADDR]       CHAR (200)      NULL,
    [WAREHOUSE]  CHAR (150)      NULL,
    [PROD_ID]    CHAR (20)       NULL,
    [FACT_CNT]   NUMERIC (20, 5) NULL,
    [NDS]        NUMERIC (20, 5) NULL,
    [FULL_PRICE] NUMERIC (20, 5) NULL,
    [STEP_NUM]   NUMERIC (20, 5) NULL,
    [TAX]        CHAR (20)       NULL,
    [WARRANT]    CHAR (20)       NULL,
    [SALESTYPE]  CHAR (20)       NULL
);

