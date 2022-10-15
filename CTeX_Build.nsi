
!include "LogicLib.nsh"
!include "Sections.nsh"
!include "FileFunc.nsh"

Name "CTeX Build"
OutFile "CTeX_Build.exe"

ShowInstDetails show

!include "MUI2.nsh"

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL


!define Make "$PROGRAMFILES\NSIS\makensis.exe"
!define INI_File "$EXEDIR\CTeX_Build.ini"
!define INI_Sec "CTeX"
!define INI_Key "BuildNumber"

!macro _Build NAME OPTIONS
	nsExec::ExecToLog '"${Make}" /INPUTCHARSET UTF8 ${OPTIONS} ${NAME}'
	Pop $0
	${If} $0 != 0
		Abort
	${EndIf}
!macroend
!define Build "!insertmacro _Build"

Var Build_Number
Var BUILD_ALL

Section
	Call ReadBuildNumber
	Call WriteBuildNumber
SectionEnd

Section "Build Repair" Sec_Repair
	${Build} "$EXEDIR\CTeX_Setup.nsi" "/DBUILD_REPAIR"
SectionEnd

Section /o "Build Update" Sec_Update
	${Build} "$EXEDIR\CTeX_Update.nsi" ""
SectionEnd

SectionGroup "Build Basic Version" Sec_Basic_Group
Section "Basic" Sec_Basic
	${Build} "$EXEDIR\CTeX_Setup.nsi" ""
SectionEnd

Section "Basic (x64)" Sec_Basic_x64
	${Build} "$EXEDIR\CTeX_Setup.nsi" "/DBUILD_X64_ONLY"
SectionEnd

Section "Basic (x86)" Sec_Basic_x86
	${Build} "$EXEDIR\CTeX_Setup.nsi" "/DBUILD_X86_ONLY"
SectionEnd
SectionGroupEnd

SectionGroup "Build Full Version" Sec_Full_Group
Section /o "Full" Sec_Full
	${Build} "$EXEDIR\CTeX_Setup.nsi" "/DBUILD_FULL"
SectionEnd

Section /o "Full (x64)" Sec_Full_x64
	${Build} "$EXEDIR\CTeX_Setup.nsi" "/DBUILD_FULL /DBUILD_X64_ONLY"
SectionEnd

Section /o "Full (x86)" Sec_Full_x86
	${Build} "$EXEDIR\CTeX_Setup.nsi" "/DBUILD_FULL /DBUILD_X86_ONLY"
SectionEnd
SectionGroupEnd

Section "Increment build number"
	${IfNot} ${Errors}
		Call ReadBuildNumber
		Call UpdateBuildNumber
		Call WriteBuildNumber
	${EndIf}
SectionEnd

Function .onInit
	${GetParameters} $R0
	${GetOptions} $R0 "/BUILD_ALL=" $BUILD_ALL
	
	${If} $BUILD_ALL != ""
		!insertmacro SelectSection ${Sec_Repair}
		!insertmacro SelectSection ${Sec_Update}
		!insertmacro SelectSection ${Sec_Basic_Group}
		!insertmacro SelectSection ${Sec_Full_Group}
	${EndIf}
FunctionEnd

Function .onSelChange
	${If} ${SectionIsSelected} ${Sec_Update}
	${OrIf} ${SectionIsPartiallySelected} ${Sec_Basic_Group}
	${OrIf} ${SectionIsPartiallySelected} ${Sec_Full_Group}
		!insertmacro SelectSection ${Sec_Repair}
	${EndIf}
FunctionEnd

Function ReadBuildNumber
	ReadINIStr $Build_Number "${INI_File}" "${INI_Sec}" "${INI_Key}"
	${If} $Build_Number == ""
		StrCpy $Build_Number "0"
	${EndIf}
FunctionEnd

Function UpdateBuildNumber
	IntOp $Build_Number $Build_Number + 1
	WriteINIStr "${INI_File}" "${INI_Sec}" "${INI_Key}" $Build_Number
FunctionEnd

Function WriteBuildNumber
	FileOpen $0 "$EXEDIR\CTeX_Build.nsh" "w"
	FileWrite $0 '!define BUILD_NUMBER "$Build_Number"$\r$\n'
	FileClose $0
FunctionEnd
