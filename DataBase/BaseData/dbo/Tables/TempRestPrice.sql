CREATE TABLE [dbo].[TempRestPrice] (
    [ND]         DATETIME        NULL,
    [hitag]      INT             NULL,
    [code1C]     VARCHAR (30)    NULL,
    [Price]      MONEY           NULL,
    [flgWeight]  BIT             NULL,
    [MinVPrice]  DECIMAL (10, 2) NULL,
    [MaxVPrice]  DECIMAL (10, 2) NULL,
    [Dbl]        BIT             CONSTRAINT [DF__TempRestPri__Dbl__40F2B247] DEFAULT ((0)) NULL,
    [MinP]       INT             CONSTRAINT [DF__TempRestPr__MinP__42DAFAB9] DEFAULT ((1)) NULL,
    [units]      VARCHAR (30)    NULL,
    [flgExists]  BIT             NULL,
    [Name]       VARCHAR (100)   NULL,
    [flgErr]     BIT             CONSTRAINT [DF__TempRestP__flgEr__45B76764] DEFAULT ((0)) NULL,
    [Suspicious] BIT             CONSTRAINT [DF__TempRestP__Suspi__46AB8B9D] DEFAULT ((0)) NULL,
    [ID]         INT             NULL
);

