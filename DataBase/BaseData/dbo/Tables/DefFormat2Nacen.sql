CREATE TABLE [dbo].[DefFormat2Nacen] (
    [Ngrp]     INT            NULL,
    [dfID]     INT            NULL,
    [MinNacen] DECIMAL (7, 2) NULL
);


GO
CREATE NONCLUSTERED INDEX [DefFormat2Nacen_idx]
    ON [dbo].[DefFormat2Nacen]([Ngrp] ASC, [dfID] ASC);

