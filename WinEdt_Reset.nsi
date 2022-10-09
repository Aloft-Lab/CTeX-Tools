
Name "WinEdt Reset"
OutFile "WinEdt_Reset.exe"

ShowInstDetails nevershow

!include "MUI2.nsh"

!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

!insertmacro MUI_RESERVEFILE_LANGDLL


Section
	ReadRegStr $R0 HKCU "Software\WinEdt 7" "Install Root"
	DeleteRegKey HKCU "Software\WinEdt 7"
	${If} $R0 == ""
		StrCpy $R0 "C:\CTEX\WinEdt"
	${EndIf}
	Delete "$R0\WinEdt.skd"

SectionEnd

