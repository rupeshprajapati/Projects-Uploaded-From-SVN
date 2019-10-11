DROP PROCEDURE [Usp_Get_Trans_Tbl_fields_List ]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [Usp_Get_Trans_Tbl_fields_List ]
(@Entry_ty Varchar(2),@Tbl_name Varchar(50))
as
---Declare @Entry_ty Varchar(2),@Tbl_name Varchar(50)
Declare @Main_Field_List Varchar(Max),@Lmc_Field_List Varchar(Max)
	,@Item_Field_List Varchar(Max),@Acdet_Field_List Varchar(Max)
--Select @Tbl_name = 'STMain',@Entry_ty = 'ST'

SELECT @Main_Field_List =(SELECT '['+([Name])+'],' FROM Syscolumns 
	WHERE [Id] = Object_Id(@Tbl_name)
		AND [Name] Not In (SELECT Fld_nm From Lother
		WHERE E_Code = @Entry_ty
		AND Tbl_nm IN('LMC','LMC_VW'))FOR XML PATH(''))

SELECT @Item_Field_List =(SELECT '['+([Name])+'],' FROM Syscolumns 
	WHERE [Id] = Object_Id(Replace(@Tbl_name,'MAIN','ITEM')) FOR XML PATH(''))

SELECT @Acdet_Field_List =(SELECT '['+([Name])+'],' FROM Syscolumns 
	WHERE [Id] = Object_Id(Replace(@Tbl_name,'MAIN','ACDET')) FOR XML PATH(''))

SELECT @Lmc_Field_List = (SELECT '['+RTrim([Fld_nm])+'],' FROM Lother
	WHERE Tbl_nm IN('LMC','LMC_VW')
		AND E_Code = @Entry_ty FOR XML PATH('') ) 

Select @Lmc_Field_List = '[TRAN_CD],'+ISNULL(@Lmc_Field_List,'')

Select Left(@Main_Field_List,Len(@Main_Field_List)-1) as cMain_Flds
	,Left(@Item_Field_List,Len(@Item_Field_List)-1) as cItem_Flds
	,Left(@Acdet_Field_List,Len(@Acdet_Field_List)-1) as cAcdet_Flds
	,Left(@Lmc_Field_List,Len(@Lmc_Field_List)-1) as cLmc_Flds
GO
