DROP PROCEDURE [Drop_Dados_report]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [Drop_Dados_report]
@RepIdOrName Varchar(100)
as
Declare @RepId Varchar(10)
If Exists(Select Repid From UsRep Where repid=@RepIdOrName or RepNm=@RepIdOrName)
Begin
	Select @RepId =Repid From UsRep Where repid=@RepIdOrName or RepNm=@RepIdOrName
	BEGIN TRY  
		BEGIN TRANSACTION
		
			Delete from para_query_master Where repid=@RepId 

			DELETE from uslty Where lvltid In
				(	select a.lvltid from uslty a 
					Inner Join (Select lvlid as lvltid,count(lvlid) as lvlcount from usrlv group by lvlid having count(lvlid)=1) b on (a.lvltid=b.lvltid)
					where a.lvltid in (Select LvlID From Usrlv Where QryID in (Select QryID from usqry Where repid=@RepId))	
				) 	

			Delete from uscol where colid in (Select colid from uscrl Where repid=@RepId)	

			Delete from uscrl Where repid=@RepId
			
			Delete from usrlv Where QryID in (select QryID from usqry Where repid=@RepId)

			Delete from usqry Where repid=@RepId

			Delete from usrep Where repid=@RepId

		COMMIT TRANSACTION
	END TRY  
	BEGIN CATCH  
		 ROLLBACK TRANSACTION
	END CATCH  
End
GO
