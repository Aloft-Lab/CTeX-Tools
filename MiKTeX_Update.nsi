
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

!macro _MiKTeXPackages ACTION INFO LIST_FILE
	FileOpen $0 "$EXEDIR\${LIST_FILE}" "r"
	${Do}
		FileRead $0 $9
		${If} $9 == ""
			${ExitDo}
		${EndIf}
		${TrimNewLines} $9 $8
		DetailPrint "${INFO} $8"
		${StrCase} $7 $8 "L"
		nsExec::ExecToLog "miktex.exe --admin --verbose packages ${ACTION} $7"
	${Loop}
	FileClose $0
!macroend
!define InstallPackages '!insertmacro _MiKTeXPackages "install" "Installing"'
!define RemovePackages '!insertmacro _MiKTeXPackages "remove" "Removing"'

Section /o "Update (MPM)" Sec_Update_MPM

	DetailPrint "Update MiKTeX packages"
	nsExec::ExecToLog "mpm.exe --admin --verbose --update"

SectionEnd

Section "Update packages" Sec_Update_packages

	DetailPrint "Update MiKTeX packages"
	nsExec::ExecToLog "miktex.exe --admin --verbose packages update"

SectionEnd

SectionGroup "Customize packages" Sec_Customize_packages

Section /o "Install required" Sec_Install_Required

	DetailPrint "Install required packages"
	repeat:
	nsExec::ExecToLog "miktex.exe --admin --verbose packages require --package-id-file required_packages.txt"
	Pop $0
	IntCmp $0 0 done repeat repeat
	done:

SectionEnd

Section /o "Install full" Sec_Install_full

	DetailPrint "Install full packages"
	repeat:
	nsExec::ExecToLog "miktex.exe --admin --verbose packages upgrade complete"
	Pop $0
	IntCmp $0 0 done repeat repeat
	done:

SectionEnd

Section /o "Remove inessential" Sec_Remove_inessential

	DetailPrint "Remove inessential packages"
	${RemovePackages} "inessential_packages.txt"

SectionEnd

SectionGroupEnd

Section "Update databases" Sec_Update_databases

	DetailPrint "Update MiKTeX file name database"
	nsExec::ExecToLog "miktex.exe --admin --verbose fndb refresh"
	nsExec::ExecToLog "miktex.exe --verbose fndb refresh"

	DetailPrint "Update MiKTeX updmap database"
	nsExec::ExecToLog "miktex.exe --admin --verbose fontmaps configure"

SectionEnd

Function .onSelChange
	${If} $0 == ${Sec_Update_MPM}
		${If} ${SectionIsSelected} ${Sec_Update_MPM}
			!insertmacro UnselectSection ${Sec_Update_packages}
			!insertmacro UnselectSection ${Sec_Customize_packages}
			!insertmacro UnselectSection ${Sec_Update_databases}
		${EndIf}
	${Else}
		${If} ${SectionIsSelected} ${Sec_Update_packages}
		${OrIf} ${SectionIsSelected} ${Sec_Customize_packages}
		${OrIf} ${SectionIsPartiallySelected} ${Sec_Customize_packages}
		${OrIf} ${SectionIsSelected} ${Sec_Update_databases}
			!insertmacro UnselectSection ${Sec_Update_MPM}
		${EndIf}
	${EndIf}
FunctionEnd
