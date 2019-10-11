DROP PROCEDURE [prcGetItRef]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [prcGetItRef]
	@Entry_ty varchar(2)
as
set nocount on
select entry_ty,rentry_ty,rinv_sr,rinv_no,rl_yn,ritem_no from it_ref where entry_ty = @Entry_ty
GO
