CREATE TABLE [dbo].[KassaHro] (
    [KhID]          INT      IDENTITY (1, 1) NOT NULL,
    [ND]            DATETIME CONSTRAINT [DF__KassaHro__ND__607D3EDD] DEFAULT (getdate()) NULL,
    [KassMORN]      MONEY    CONSTRAINT [DF__KassaHro__KassMO__43E1002F] DEFAULT ((0)) NOT NULL,
    [SelNalIN]      MONEY    CONSTRAINT [DF__KassaHro__SelNal__44D52468] DEFAULT ((0)) NOT NULL,
    [SelNalOUT]     MONEY    CONSTRAINT [DF__KassaHro__SelNal__45C948A1] DEFAULT ((0)) NOT NULL,
    [GetRealIN]     MONEY    CONSTRAINT [DF__KassaHro__GetRea__46BD6CDA] DEFAULT ((0)) NOT NULL,
    [GetRealOUT]    MONEY    CONSTRAINT [DF__KassaHro__GetRea__47B19113] DEFAULT ((0)) NOT NULL,
    [Prihod]        MONEY    CONSTRAINT [DF__KassaHro__Prihod__48A5B54C] DEFAULT ((0)) NOT NULL,
    [OurPlata]      MONEY    CONSTRAINT [DF__KassaHro__OurPla__4999D985] DEFAULT ((0)) NOT NULL,
    [Rashod]        MONEY    CONSTRAINT [DF__KassaHro__Rashod__4A8DFDBE] DEFAULT ((0)) NOT NULL,
    [SkladIN]       MONEY    CONSTRAINT [DF__KassaHro__SkladI__4B8221F7] DEFAULT ((0)) NOT NULL,
    [SkladOUT]      MONEY    CONSTRAINT [DF__KassaHro__SkladO__4C764630] DEFAULT ((0)) NOT NULL,
    [SelBnIN]       MONEY    CONSTRAINT [DF__KassaHro__SelBnI__4D6A6A69] DEFAULT ((0)) NOT NULL,
    [SelBnOUT]      MONEY    CONSTRAINT [DF__KassaHro__SELBnO__4E5E8EA2] DEFAULT ((0)) NOT NULL,
    [InputIN]       MONEY    CONSTRAINT [DF__KassaHro__InputI__4F52B2DB] DEFAULT ((0)) NOT NULL,
    [InputOUT]      MONEY    CONSTRAINT [DF__KassaHro__InputO__5046D714] DEFAULT ((0)) NOT NULL,
    [IzmenIN]       MONEY    CONSTRAINT [DF__KassaHro__IzmenI__513AFB4D] DEFAULT ((0)) NULL,
    [IzmenOUT]      MONEY    CONSTRAINT [DF__KassaHro__IzmenO__522F1F86] DEFAULT ((0)) NULL,
    [IspravIN]      MONEY    CONSTRAINT [DF__KassaHro__Isprav__532343BF] DEFAULT ((0)) NOT NULL,
    [IspravOUT]     MONEY    CONSTRAINT [DF__KassaHro__Isprav__541767F8] DEFAULT ((0)) NOT NULL,
    [RemoveIN]      MONEY    CONSTRAINT [DF__KassaHro__Remove__550B8C31] DEFAULT ((0)) NOT NULL,
    [RemoveOUT]     MONEY    CONSTRAINT [DF__KassaHro__Remove__55FFB06A] DEFAULT ((0)) NOT NULL,
    [RKO_Nom]       INT      NULL,
    [RealizIN]      MONEY    CONSTRAINT [DF__KassaHro__Realiz__56F3D4A3] DEFAULT ((0)) NOT NULL,
    [RealizOUT]     MONEY    CONSTRAINT [DF__KassaHro__Realiz__57E7F8DC] DEFAULT ((0)) NOT NULL,
    [PersonMust]    MONEY    CONSTRAINT [DF__KassaHro__Person__58DC1D15] DEFAULT ((0)) NOT NULL,
    [CommMust]      MONEY    CONSTRAINT [DF__KassaHro__CommMu__59D0414E] DEFAULT ((0)) NOT NULL,
    [AllRashod]     MONEY    CONSTRAINT [DF__KassaHro__AllRas__5AC46587] DEFAULT ((0)) NOT NULL,
    [Profit]        MONEY    CONSTRAINT [DF__KassaHro__Profit__5BB889C0] DEFAULT ((0)) NOT NULL,
    [AllDohod]      MONEY    CONSTRAINT [DF__KassaHro__AllDoh__5CACADF9] DEFAULT ((0)) NOT NULL,
    [BuyBakIN]      MONEY    CONSTRAINT [DF__KassaHro__BuyBak__5DA0D232] DEFAULT ((0)) NULL,
    [BuyBakOUT]     MONEY    CONSTRAINT [DF__KassaHro__BuyBak__5E94F66B] DEFAULT ((0)) NULL,
    [VendorKOpl]    MONEY    CONSTRAINT [DF__KassaHro__Vendor__426E8460] DEFAULT ((0)) NULL,
    [EquipmentCost] MONEY    CONSTRAINT [DF__KassaHro__Equipm__4B03CA61] DEFAULT ((0)) NULL,
    CONSTRAINT [KassaHro_pk] PRIMARY KEY CLUSTERED ([KhID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость хол.оборудования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KassaHro', @level2type = N'COLUMN', @level2name = N'EquipmentCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К выплате поставщикам', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KassaHro', @level2type = N'COLUMN', @level2name = N'VendorKOpl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сальдо с поставщиками', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KassaHro', @level2type = N'COLUMN', @level2name = N'CommMust';

