
!include "LogicLib.nsh"
!include "TextFunc.nsh"
!include "StrFunc.nsh"

${Using:StrFunc} StrCase

Name "MiKTeX Update"
OutFile "MiKTeX_Update.exe"

ShowInstDetails show

!include "MUI2.nsh"

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL

Var UseMPM

Section /o "Use MPM"

	StrCpy $UseMPM "Yes"

SectionEnd

Section "Update packages"

	DetailPrint "Update MiKTeX packages"
	${If} $UseMPM == ""
		nsExec::ExecToLog "miktex.exe --admin --verbose packages update"
	${Else}
		nsExec::ExecToLog "mpm.exe --admin --verbose --update"
	${EndIf}

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
		${StrCase} $7 $8 "L"
		${If} $UseMPM == ""
			nsExec::ExecToLog "miktex.exe --admin --verbose packages install $7"
		${Else}
			nsExec::ExecToLog "mpm.exe --admin --verbose --install=$7"
		${EndIf}
	${Loop}
	FileClose $0

SectionEnd

Section "Update databases"

	DetailPrint "Update MiKTeX file name database"
	${If} $UseMPM == ""
		nsExec::ExecToLog "miktex.exe --admin --verbose fndb refresh"
		nsExec::ExecToLog "miktex.exe --verbose fndb refresh"
	${Else}
		nsExec::ExecToLog "initexmf.exe --admin --verbose --update-fndb"
		nsExec::ExecToLog "initexmf.exe --verbose --update-fndb"
	${EndIf}

	DetailPrint "Update MiKTeX updmap database"
	${If} $UseMPM == ""
		nsExec::ExecToLog "miktex.exe --admin --verbose fontmaps configure"
	${Else}
		nsExec::ExecToLog "initexmf.exe --admin --verbose --mkmaps"
	${EndIf}

SectionEnd
