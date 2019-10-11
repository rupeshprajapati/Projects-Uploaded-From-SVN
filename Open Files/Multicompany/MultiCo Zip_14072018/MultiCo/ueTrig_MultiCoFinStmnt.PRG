Parameters vDataSessionId
Local EXPARA

EXPARA=' '
x=""

Set DataSession To vDataSessionId

Do Form uefrm_MultiCoSelFinStmnt.scx With vDataSessionId To x

EXPARA=x

Return EXPARA

