
!include "LogicLib.nsh"
!include "TextFunc.nsh"

Name "MiKTeX Update"
OutFile "MiKTeX_Update.exe"

ShowInstDetails show

!include "MUI2.nsh"

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL

Section "Update packages"

	DetailPrint "Update MiKTeX packages"
	nsExec::ExecToLog "miktex.exe --admin --disable-installer --verbose packages update"

SectionEnd

Section /o "Install packages"

	DetailPrint "Install required packages"
	FileOpen $0 "$EXEDIR\required_packages.txt" "r"
	${Do}
		FileRead $0 $9
		${If} $9 == ""
			${ExitDo}
		${EndIf}
		${TrimNewLines} $9 $8
		DetailPrint "Installing $8"
		nsExec::ExecToLog "miktex.exe --admin --disable-installer --verbose packages install $8"
	${Loop}
	FileClose $0

SectionEnd

Section "Update databases"

	DetailPrint "Update MiKTeX file name database"
	nsExec::ExecToLog "miktex.exe --admin --disable-installer --verbose fndb refresh"
	nsExec::ExecToLog "miktex.exe --disable-installer --verbose fndb refresh"
	DetailPrint "Update MiKTeX updmap database"
	nsExec::ExecToLog "miktex.exe --admin --disable-installer --verbose fontmaps configure"

SectionEnd
