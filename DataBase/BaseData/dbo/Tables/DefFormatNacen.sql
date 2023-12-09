CREATE TABLE [dbo].[DefFormatNacen] (
    [Ngrp]     INT            NULL,
    [dfID]     INT            NULL,
    [MinNacen] DECIMAL (7, 2) NULL
);


GO
CREATE NONCLUSTERED INDEX [DefFormatNacen_idx]
    ON [dbo].[DefFormatNacen]([Ngrp] ASC, [dfID] ASC);

