; NSIS Installer File for Cmder
;   Written by Mike Centola (http://github.com/mikecentola)
;
;   Intended for NSIS 3.0

; The MIT License (MIT)
;
; Copyright (c) 2016 Mike Centola
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
; THE SOFTWARE.

;--------------------------------
; Includes

    !include "MUI2.nsh"
    !include "FileFunc.nsh"
    !include "x64.nsh"


;--------------------------------
; UAC

    ; Request application privileges
    RequestExecutionLevel admin
 

;--------------------------------
; General

    !define INSTALLER_VERSION "0.0.1-alpha"
    !define APP_NAME "Cmder"
    !define CMDER_DLURL "http://github.com/cmderdev/cmder/releases/download/${CMDER_VERSION}/cmder_mini.zip"
    !define CMDER_URL "http://cmder.net"

    !define APP_INSTALLER_TEXT "${APP_NAME} Installer Ver. ${INSTALLER_VERSION}"
    BrandingText "${APP_INSTALLER_TEXT}"

    ; Name / File
    Name "${APP_NAME} v${CMDER_VERSION}"
    OutFile "cmder_inst_${CMDER_VERSION}.exe"
        
    ; Default Installation Folder
    InstallDir $PROGRAMFILES\${APP_NAME}

    ; Registry Set Up
    !define REGLOC "Software\${APP_NAME}"
    !define REGROOT "HKLM"
    InstallDirRegKey ${REGROOT} "${REGLOC}" "InstallPath"

    ; Uninstall Info
    !define ARP "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

    ; Additional Options
    ShowInstDetails show
    ShowUninstDetails show
    SpaceTexts none


;--------------------------------
; Interface Configuration

    !define MUI_WELCOMEFINISHPAGE_BITMAP "img\cmder-side.bmp"
    !define MUI_ICON "img\cmder.ico"
    !define MUI_UNICON "img\cmder.ico"

    !define MUI_WELCOMEPAGE_TITLE "Welcome to the ${APP_NAME} v${CMDER_VERSION} Installation Tool for Windows."
    !define MUI_WELCOMEPAGE_TITLE_3LINES
    !define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation the latest version of Cmder \
    for Windows.$\r$\n$\r$\nClick Next to continue."

    !define MUI_LICENSEPAGE_TEXT_TOP "Press Page Down to see the rest of the agreement"
    !define MUI_LICENSEPAGE_TEXT_BOTTOM "Cmder is released under the MIT license. The license is provided here for \
    information purposes only. Click Next to continue."

    !define MUI_COMPONENTSPAGE_NODESC

    !define MUI_FINISHPAGE_NOAUTOCLOSE
    !define MUI_FINISHPAGE_TITLE "Congratulations! You have installed Cmder."
    !define MUI_FINISHPAGE_TITLE_3LINES
    !define MUI_FINISHPAGE_TEXT "You can now use Cmder. Start menu and/or desktop shortcuts have been created \
        if you chose to do so.$\r$\n$\r$\nPLEASE NOTE THAT YOU MUST EITHER RUN CMDER WITH THE CHECKBOX BELOW, \ 
        OR RUN AS ADMINISTRATOR FOR THE FIRST TIME."
    !define MUI_FINISHPAGE_RUN_TEXT "Run ${APP_NAME} v${CMDER_VERSION}"
    !define MUI_FINISHPAGE_RUN "$INSTDIR\${APP_NAME}.exe"

    !define MUI_FINISHPAGE_NOREBOOTSUPPORT

    !define MUI_ABORTWARNING
    !define MUI_ABORTWARNING_TEXT "Are you sure you want to cancel the installation of ${APP_NAME} v${CMDER_VERSION}?"
    !define MUI_ABORTWARNING_CANCEL_DEFAULT

    !define MUI_UNCONFIRMPAGE_TEXT_TOP "This wizard will guide you through the uninstallation of ${APP_NAME} \
        v${CMDER_VERSION}.$\r$\n$\r$\nBefore starting the uninstallation, please make sure that ${APP_NAME} \
        is not running.$\r$\n$\r$\nClick Next to continue."
    !define MUI_UNFINISHPAGE_NOAUTOCLOSE

;--------------------------------
; Pages

    ; Installer Pages
    !define MUI_PAGE_CUSTOMFUNCTION_PRE wel_pre
    !insertmacro MUI_PAGE_WELCOME
    !insertmacro MUI_PAGE_LICENSE LICENSE
    !define MUI_PAGE_CUSTOMFUNCTION_PRE dir_pre
    !insertmacro MUI_PAGE_DIRECTORY
    !insertmacro MUI_PAGE_COMPONENTS
    !insertmacro MUI_PAGE_INSTFILES
    !insertmacro MUI_PAGE_FINISH

    ; Uninstaller Pages
    !insertmacro MUI_UNPAGE_CONFIRM
    !define MUI_PAGE_CUSTOMFUNCTION_PRE un.dir_pre
    !insertmacro MUI_UNPAGE_INSTFILES
    !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; Languages

    !insertmacro MUI_LANGUAGE "English"

;--------------------------------
; ZIP Handling
    !include "ZipDLL.nsh"

;--------------------------------
; Installer Sections

    Section "!Cmder ${CMDER_VERSION}" CmderInst
        SectionIn 1 RO

        SetOutPath  "$INSTDIR"
        DetailPrint "Setting InstallDir: $INSTDIR"

        ; ADD FILES
        DetailPrint "Downloading latest Cmder (mini) from ${CMDER_DLURL}"
        inetc::get ${CMDER_DLURL} $TEMP/cmder_mini.zip
        Pop $0
        StrCmp "$0" "OK" dlok
        DetailPrint "Download Failed $0"
        Abort

        dlok:
        DetailPrint "Download OK"
        !insertmacro ZIPDLL_EXTRACT "$TEMP/cmder_mini.zip" "$INSTDIR" "<ALL>"
        Pop $0
        DetailPrint "Unzipping Files"
        StrCmp "$0" "success" unzipok
        DetailPrint "Failed to Unzip Cmder Files"
        Abort 
        

        unzipok:
        DetailPrint "Unzip OK"
        ; Delete Zip
        DetailPrint "Removing Temp File"
        delete $TEMP/cmder_mini.zip

        DetailPrint "Writing Registry Keys"
        ; Store Installation Folder
        WriteRegStr ${REGROOT} "${REGLOC}" "InstallPath" $INSTDIR
        WriteRegStr ${REGROOT} "${REGLOC}" "Version" ${CMDER_VERSION}

        ; Create Uninstaller
        WriteUninstaller "$INSTDIR\Uninstall.exe"

        ; Write Uninstaller Registry Keys
        WriteRegStr ${REGROOT} "${ARP}" "DisplayName" "Cmder"
        WriteRegExpandStr ${REGROOT} "${ARP}" "UninstallString" "$INSTDIR\uninstall.exe"
        WriteRegExpandStr ${REGROOT} "${ARP}" "QuietUninstallString" "$INSTDIR\uninstall.exe /S"
        WriteRegExpandStr ${REGROOT} "${ARP}" "InstallLocation" "$INSTDIR"
        WriteRegStr ${REGROOT} "${ARP}" "DisplayIcon" "$INSTDIR\icons\${APP_NAME}.ico"
        WriteRegStr ${REGROOT} "${ARP}" "DisplayVersion" "${CMDER_VERSION}"
        WriteRegStr ${REGROOT} "${ARP}" "URLInfoAbout" "${CMDER_URL}"
        WriteRegStr ${REGROOT} "${ARP}" "NoModify" 1
        WriteRegStr ${REGROOT} "${ARP}" "NoRepair" 1

        ; Get Size
        ${GetSize} "$INSTDIR" "/S=OK" $0 $1 $2
        IntFmt $0 "0x%08X" $0
        WriteRegDWORD ${REGROOT} "${ARP}" "EstimatedSize" "$0"

    SectionEnd

    ; Shortcuts
    SectionGroup /e "Shortcuts"
        Section "Start Menu"
            DetailPrint "Writing StartMenu Shortcut"
            ; Start Menu item
            CreateShortCut "$SMPROGRAMS\${APP_NAME}.lnk" "$INSTDIR\${APP_NAME}.exe" "" "$INSTDIR\icons\${APP_NAME}.ico" 0

        SectionEnd

        Section /o "Create Desktop Icon"
            ;Create Desktop Shortcut
            DetailPrint "Writing Desktop Shorcut"
            SetOutPath $INSTDIR
            SetShellVarContext all
            SetOverwrite on
               CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_NAME}.exe" "" "$INSTDIR\icons\${APP_NAME}.ico" 0
            SetOverwrite off
        SectionEnd
    SectionGroupEnd

    ; Windows Explorer Integration Section
    SectionGroup /e "Windows Explorer Integration"
        
        ; Open Cmder Here
        Section 'Add "Open Cmder Here"'
            DetailPrint "Adding Explorer Integrations"
            WriteRegStr HKCR "Directory\Background\shell\${APP_NAME}" "" "Open Cmder Here"
            WriteRegStr HKCR "Directory\Background\shell\${APP_NAME}" "Icon" "$INSTDIR\icons\cmder.ico"
            WriteRegStr HKCR "Directory\Background\shell\${APP_NAME}\command" "" '"$INSTDIR\${APP_NAME}.exe" "%V"'

            WriteRegStr HKCR "Directory\shell\${APP_NAME}" "" "Open Cmder Here"
            WriteRegStr HKCR "Directory\shell\${APP_NAME}" "Icon" "$INSTDIR\icons\cmder.ico"
            WriteRegStr HKCR "Directory\shell\${APP_NAME}\command" "" '"$INSTDIR\${APP_NAME}.exe" "%1"'
        
        SectionEnd
    SectionGroupEnd

    


;--------------------------------
; Uninstaller Section

    Section "Uninstall"
    
        ; Remove Start Menu Items
        SetShellVarContext all
        DetailPrint "Removing StartMenu Item"
        delete "$SMPROGRAMS\${APP_NAME}.lnk"
           
        ; Remove Desktop Link
        DetailPrint "Removing Desktop Shortcut"
        delete $DESKTOP\${APP_NAME}.lnk

        ; Remove Files
        DetailPrint "Removing Files"
        rmDir /r "$INSTDIR\bin"
        rmDir /r "$INSTDIR\config"
        rmDir /r "$INSTDIR\icons"
        rmDir /r "$INSTDIR\vendor"
        delete "$INSTDIR\${APP_NAME}.exe"
        delete "$INSTDIR\CHANGELOG.md"
        delete "$INSTDIR\CONTRIBUTING.md"
        delete "$INSTDIR\README.md"
        delete "$INSTDIR\Version v${CMDER_VERSION}"
        delete "$INSTDIR\Uninstall.exe"

        ; Try to Remove Install Dir
        rmDir $INSTDIR

        ; Remove Registry Keys
        DetailPrint "Removing Registry Keys"
        DeleteRegKey ${REGROOT} "${REGLOC}"
        DeleteRegKey HKCR "Directory\Background\shell\${APP_NAME}"
        DeleteRegKey HKCR "Directory\shell\${APP_NAME}"
        DeleteRegKey ${REGROOT} "${ARP}" 

    SectionEnd


;--------------------------------
; Extra Functions

    Function .onInit
        InitPluginsDir
        File "/oname=$PluginsDir\spltmp.bmp" "img\cmder-splash.bmp"

        advsplash::show 1000 600 400 -1 $PluginsDir\spltmp

        Pop $0

        

    FunctionEnd


    Function wel_pre
        messagebox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST|MB_SETFOREGROUND "NOTE: Please remember to run Cmder \
        from the final installation page OR run as administrator the first time."
    FunctionEnd


    Function dir_pre
        ; x64 Setup
        ${If} ${RunningX64}
            DetailPrint "Installer running on 64-bit host"

            ; Disable registry redirection
            SetRegView 64

            ; Set Install Dir Root
            StrCpy $INSTDIR "$PROGRAMFILES64\${APP_NAME}"
        ${EndIf}
    FunctionEnd

    Function un.dir_pre
        ; x64 Setup
        ${If} ${RunningX64}
            DetailPrint "Installer running on 64-bit host"

            ; Disable registry redirection
            SetRegView 64

            ; Set Install Dir Root
            StrCpy $INSTDIR "$PROGRAMFILES64\${APP_NAME}"
        ${EndIf}
    FunctionEnd


; END NSIS Script
