
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

!macro _InstallPackages LIST_FILE
	FileOpen $0 "$EXEDIR\${LIST_FILE}" "r"
	${Do}
		FileRead $0 $9
		${If} $9 == ""
			${ExitDo}
		${EndIf}
		${TrimNewLines} $9 $8
		DetailPrint "Installing $8"
		${StrCase} $7 $8 "L"
		nsExec::ExecToLog "miktex.exe --admin --verbose packages install $7"
	${Loop}
	FileClose $0
!macroend
!define InstallPackages "!insertmacro _InstallPackages"

Section /o "Use MPM" Sec_Use_MPM

	StrCpy $UseMPM "Yes"

SectionEnd

Section "Update packages" Sec_Update_packages

	DetailPrint "Update MiKTeX packages"
	${If} $UseMPM == ""
		nsExec::ExecToLog "miktex.exe --admin --verbose packages update"
	${Else}
		nsExec::ExecToLog "mpm.exe --admin --verbose --update"
	${EndIf}

SectionEnd

Section /o "Required packages" Sec_Required_packages

	DetailPrint "Install required packages"
	${InstallPackages} "required_packages.txt"

SectionEnd

Section /o "Full packages" Sec_Full_packages

	DetailPrint "Install full packages"
	FileOpen $0 "$EXEDIR\get_list.cmd" "w"
	FileWrite $0 'miktex.exe --admin --verbose packages list >"$EXEDIR\full_packages.txt"'
	FileClose $0
	nsExec::ExecToLog "$EXEDIR\get_list.cmd"
	${InstallPackages} "full_packages.txt"
	Delete "$EXEDIR\get_list.cmd"
	Delete "$EXEDIR\full_packages.txt"

SectionEnd

Section "Update databases" Sec_Update_databases

	DetailPrint "Update MiKTeX file name database"
	nsExec::ExecToLog "miktex.exe --admin --verbose fndb refresh"
	nsExec::ExecToLog "miktex.exe --verbose fndb refresh"

	DetailPrint "Update MiKTeX updmap database"
	nsExec::ExecToLog "miktex.exe --admin --verbose fontmaps configure"

SectionEnd

Function .onSelChange
	${If} $0 == ${Sec_Use_MPM}
		${If} ${SectionIsSelected} ${Sec_Use_MPM}
			!insertmacro UnselectSection ${Sec_Required_packages}
			!insertmacro UnselectSection ${Sec_Full_packages}
			!insertmacro UnselectSection ${Sec_Update_databases}
		${EndIf}
	${Else}
		${If} ${SectionIsSelected} ${Sec_Required_packages}
		${OrIf} ${SectionIsSelected} ${Sec_Full_packages}
		${OrIf} ${SectionIsSelected} ${Sec_Update_databases}
			!insertmacro UnselectSection ${Sec_Use_MPM}
		${EndIf}
	${EndIf}
FunctionEnd
