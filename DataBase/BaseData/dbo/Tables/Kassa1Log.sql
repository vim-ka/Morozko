CREATE TABLE [dbo].[Kassa1Log] (
    [nd]          DATETIME       CONSTRAINT [DF__Kassa1Log__nd__060EB63F] DEFAULT (dateadd(day,datediff(day,(0),getdate()),(0))) NULL,
    [tm]          CHAR (8)       CONSTRAINT [DF__Kassa1Log__tm__0702DA78] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Oper]        INT            NULL,
    [Act]         VARCHAR (4)    NULL,
    [SourDate]    DATETIME       NULL,
    [Nnak]        INT            NULL,
    [Plata]       MONEY          CONSTRAINT [DF__Kassa1Log__Plata__7B4643B2] DEFAULT ((0)) NOT NULL,
    [Fam]         VARCHAR (40)   NULL,
    [P_ID]        INT            NULL,
    [B_ID]        INT            NULL,
    [V_ID]        INT            NULL,
    [Ncod]        INT            NULL,
    [Remark]      VARCHAR (60)   NULL,
    [RashFlag]    INT            NULL,
    [LostFlag]    INT            NULL,
    [LastFlag]    TINYINT        NULL,
    [Op]          INT            NULL,
    [Bank_ID]     INT            CONSTRAINT [DF__Kassa1Log__Bank_ID__3DC8FF7D] DEFAULT ((0)) NULL,
    [Our_ID]      INT            NULL,
    [BankDay]     DATETIME       NULL,
    [Actn]        TINYINT        CONSTRAINT [DF__Kassa1Log__Actn__2C88998B] DEFAULT ((0)) NULL,
    [Ck]          TINYINT        NULL,
    [Thr]         INT            NULL,
    [ThrFam]      VARCHAR (40)   NULL,
    [DocNom]      INT            NULL,
    [OrigRecn]    INT            NULL,
    [ForPrint]    TINYINT        CONSTRAINT [DF__Kassa1__LogForPrint__324172E1] DEFAULT ((1)) NULL,
    [SourDatNom]  INT            NULL,
    [StNom]       INT            CONSTRAINT [DF__Kassa1__StNom__Log7E038023] DEFAULT ((0)) NULL,
    [FromBank_ID] SMALLINT       CONSTRAINT [DF__Kassa1Log__FromBank__53AD53A4] DEFAULT ((0)) NULL,
    [SkladNo]     INT            NULL,
    [DepID]       INT            CONSTRAINT [DF__Kassa1Log__DepID__6740165C] DEFAULT ((0)) NULL,
    [B_idPlat]    INT            CONSTRAINT [DF__Kassa1Log__B_idPlat__2A2C1B24] DEFAULT ((0)) NULL,
    [OperOld]     INT            NULL,
    [NDInp]       DATETIME       NULL,
    [InBank]      BIT            CONSTRAINT [DF__Kassa1Log__InBank__2E91A8E5] DEFAULT ((0)) NULL,
    [Nalog]       NUMERIC (4, 2) CONSTRAINT [DF__Kassa1Log__Nalog__7A08D20D] DEFAULT ((0)) NULL,
    [RemarkPlat]  VARCHAR (100)  NULL,
    [pin]         INT            CONSTRAINT [DF__Kassa1Log__pin__7C9B25F5] DEFAULT ((0)) NULL,
    [platarez]    MONEY          NULL,
    [DCK]         INT            NULL,
    [KassaNo]     INT            CONSTRAINT [DF__Kassa1Log__KassaNo__6C1AA569] DEFAULT ((0)) NULL,
    [RealOper]    BIT            CONSTRAINT [DF__Kassa1Log__RealOper__0C8774FB] DEFAULT ((0)) NULL,
    [kassa1LogID] INT            IDENTITY (1, 1) NOT NULL,
    [kassid]      INT            NOT NULL,
    [type]        SMALLINT       NULL,
    [user_name]   NVARCHAR (256) DEFAULT (suser_sname()) NULL,
    [datetime]    DATETIME       DEFAULT (getdate()) NULL,
    [host_name]   NCHAR (30)     DEFAULT (host_name()) NULL,
    [app_name]    NVARCHAR (128) DEFAULT (app_name()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя приложения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1Log', @level2type = N'COLUMN', @level2name = N'app_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя компа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1Log', @level2type = N'COLUMN', @level2name = N'host_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1Log', @level2type = N'COLUMN', @level2name = N'datetime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя пользователя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1Log', @level2type = N'COLUMN', @level2name = N'user_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип изменения 0 - insert, 1 - delete, 2 - update', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1Log', @level2type = N'COLUMN', @level2name = N'type';

