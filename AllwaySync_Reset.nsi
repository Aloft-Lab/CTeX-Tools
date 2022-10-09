
Name "AllwaySync Reset"
OutFile "AllwaySync.exe"

RequestExecutionLevel admin

ShowInstDetails nevershow
AutoCloseWindow true

!include "MUI2.nsh"

!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL

Section
	SetRegView 64
	DeleteRegKey HKCR "CLSID\{6232211d-bf20-eec9-31fb-ff90e69218c7}"
	DeleteRegKey HKCU "Software\SyncApp"
	SetRegView 32
	DeleteRegKey HKCR "CLSID\{6232211d-bf20-eec9-31fb-ff90e69218c7}"
	DeleteRegKey HKCU "Software\SyncApp"

	SetShellVarContext all
	Delete "$APPDATA\Sync App Settings\_SYNCAPP\4B5F4749464E4F436554534E495F5945"
	Delete "$APPDATA\Sync App Settings\_SYNCAPP\73556C6C41435F435374617453656761"
	
	Exec "$EXEDIR\syncappw.exe"
SectionEnd

