/*
List of GUI windows in use:
1: Output Window
2: Welcome Screen
3: Exit Confirmation
4: Settings Window
5: Semi-transparent background for Welcome Screen
6: Semi-transparent background for Output Window
7: Update Notifier


Requirements for adding a new game:
Add the requirements list for both percentage only and normal, including custom code if applicable.
Add the icons to the icons.icl and to the iconarray.
Add the game window name, game window class and the game running address to their respective arrays.
Add the game to SupportedGamesList


Syntax for adding new requirements:

Name =
[%Name%Type = Float] ; Defaults to integer
IconName =
[TotalRequired =]
Address{Index} :=
[Address{Index}Length = 1] ; Defaults to 4
[Address{Index}CustomCode = 1/0] ; Defaults to 0
gosub %CurrentLoopCode%

*/

; ######################################################################################################
; ########################################### HEADER SECTION ###########################################
; ######################################################################################################

/*
Subheadings:

	#AUTO-EXECUTE
	CreateArrays
	FileList
	DefaultSettings
	SetVariablesDependentOnSettings
	WriteSettingsFile
	ReadSettingsFile
	SupportedGamesList
*/
; Only one instance of the program can be running at a time.
#SingleInstance Force
; SetWinDelay, 0 is necessary to make the semi-transparent background window move without delay.
SetWinDelay, 0
; Tell the program what to do if it is closed.
OnExit, ExitSequence
; Change the name of the program in the tray menu, then remove the standard tray items
; and add the ones relevant to this program.
SplitPath, A_ScriptName,,,,ScriptNameNoExt
menu, tray, tip, %ScriptNameNoExt%
menu, tray, NoStandard
menu, tray, Add, Restart Script, RestartSequence
menu, tray, Add, Open Readme, OpenReadme
menu, tray, Add, Exit, ExitSequence
ScriptNameNoExtLength := StrLen(ScriptNameNoExt)
if ScriptNameNoExtLength >= 199
	gosub ErrorFilenameLength
; Enable debug functions if they exist and if the program is not compiled.
; This way normal users can't (accidentally) activate them.
If (IsLabel("DebugFunctions") AND A_IsCompiled != 1)
	gosub DebugFunctions
; Initialise the settings. To make sure all settings exist, first load the default settings.
; Then check if the settings file exist and read it if it does. In case of changing the settings
; file name, the program will look for the old file and copy the settings to the new one, so the user
; does not have to reconfigure everything. This support won't last forever so after a few updates
; (which is likely still a long time) you're out of luck.
gosub DefaultSettings
SettingsFileNameOld = %ScriptNameNoExt% FrankerZ`.dll
SettingsFileName = %ScriptNameNoExt% Config`.dll
ifExist,%SettingsFileNameOld%
{
	SettingsFileNameNew := SettingsFileName
	SettingsFileName := SettingsFileNameOld
	gosub ReadSettingsFile
	FileDelete, %SettingsFileNameOld%
	SettingsFileName := SettingsFileNameNew
	gosub WriteSettingsFile
}
ifExist,%SettingsFileName%
	gosub ReadSettingsFile
gosub SetVariablesDependentOnSettings
; Install and configure the icons.
Fileinstall, Icons.icl, Icons.icl, 1
ImageFilename = Icons.icl
menu, tray, icon, %ImageFilename%, 1, 1
; Configure the auto updater. The auto updater only triggers if the program is compiled, otherwise
; the program will go to the create arrays subroutine immediately, skipping the auto updater.
CurrentVersion = 1.55
VersionURL := "http://pastebin.com/download.php?i=pc9QbQCK"
ProgramName := "100% Checklist"
gosub FileList
If A_IsCompiled = 1
{
	gosub UpdateCheck
	loop
	{
		if UpdaterActive != 1
			break
		sleep 100
	}
}
goto CreateArrays

CreateArrays:
; Create the array with the icon indexes from the icons library. The icon names are used in the requirement lists and translated into the actual icons using this array.
IconArray := {Percentage:01, UniqueJump:02, HiddenPackageVC:03, RampageVC:04, Robbery:05, Safehouse:06, TopFun:07, VehicleChallenge:08, Vigilante:09, Firefighter:10, Paramedic:11, PizzaDelivery:12, TaxiDriver:13, ChopperCheckpoint:14, StadiumEvent:15, ShootingRange:16, StreetRace:17, Lawyer:18, KentPaul:19, Diaz:20, Vercetti:21, Avery:22, UmbertoRobina:23, AuntiePoulet:24, LoveFist:25, MitchBaker:26, PhilCassidy:27, ColonelCortez:28, PayphoneAssassination:29, InterglobalFilms:30, KaufmanCabs:31, PolePosition:32, CherryPoppers:33, SunshineAutos:34, Boatyard:35, Printworks:36, MalibuClub:37, Airstrip:38, BigSmoke:39, BikeSchool:40, BoatSchool:41, Camera:42, Casino:43, CatalinaSA:44, CesarVialpando:45, ChiliadChallenge:46, CJ:47, Crash:48, DrivingSchool:49, Dumbbell:50, FlightSchool:51, Heist:52, Horseshoe:53, ImportExport:54, Jizzy:55, MaddDogg:56, MotorcycleHelmet:57, OGLoc:58, Oyster:59, Pimping:60, Quarry:61, RedDragon:62, Ryder:63, ShoppingBasket:64, SprayPaint:65, Sweet:66, TheTruth:67, Toreno:68, Train:69, Trucking:70, Valet:71, Woozie:72, YellowDragon:73, Zero:74, AsukaKasen:75, CatalinaIII:76, DIce:77, DonaldLove:78, EightBall:79, ElBurro:80, HiddenPackageIII:81, JoeyLeone:82, KenjiKasen:83, KingCourtney:84, LuigiGoterelli:85, MartyChonks:86, RampageIII:87, RayMachowski:88, RCToyz:89, SalvatoreLeone:90, TonyCipriani:91, HARBonusMissions:92, HARCharacterClothing:93, HARCollectorCards:94, HARGags:95, HARMovies:96, HARVehicles:97, HARWaspCameras:98, HARPercent:99, HARStoryMissions:100, HARStreetRaces:101}
; Create some arrays needed to find the game and to see if it's still running. Both the window class and name are used for improved accuracy.
GameWindowClassArray := {GTAVC:"Grand theft auto 3", GTA3:"Grand theft auto 3", GTASA:"Grand theft auto San Andreas", GTA4:"Grand theft auto IV", Bully:"Gamebryo Application", SimpsonsHAR:"The Simpsons Hit & Run"}
GameWindowNameArray := {GTAVC:"GTA: Vice City", GTA3:"GTA3", GTASA:"GTA: San Andreas", GTA4:"GTAIV", Bully:"Bully", SimpsonsHAR:"The Simpsons Hit & Run"}
GameRunningAddressArray := {GTAVC:0x00400000, GTASA:0x00400000, GTA3:0x00400000, Bully:0x00400000, SimpsonsHAR:0x00400000}
; The requirements array is created later because it depends on settings chosen by the user.
goto WelcomeScreen

; List of names of the files the auto updater should download.
FileList:
File1 := "newversion100% Checklist.exe"
File2 := "100% Checklist Source.ahk"
File3 := "100% Checklist Readme.txt"
ExecutableFile := File1
return

; First define which file from the file list is the readme, then test if it exists
; and open it if it does. Otherwise, show an error message with the most likely issue.
OpenReadme:
ReadmeFile := File3
if FileExist(ReadmeFile)
	Run, edit %ReadmeFile%
else
	Msgbox,  The readme could not be found. `nPlease make sure it is located in the same folder as the executable.
return

; These default settings will be used if they haven't been configured otherwise in the settings file.
DefaultSettings:
TextColour = 000000
BackColour = F1F2F3
MaximumRowsText = 25
MaximumRowsIcons = 13
DecimalPlaces = 2
RefreshRate = 500
RefreshRateFileOutput = 10000
Transparency = 255
TextSmoothing = 0
OutputWindowBoldText = 0
ShowDoneIfDone = 0
ExitConfirmed = 0
AlwaysOnTop = 0
return

; Some of the settings have to be explicitly activated, or other variables depend on them.
SetVariablesDependentOnSettings:
IconListViewWidth := 85
TextListViewWidth := 225
If OutputWindowBoldText = 1
	CharacterWidth := 6
Else
	CharacterWidth := 5.6
IconListViewWidthWithFloat := IconListViewWidth+5*DecimalPlaces
; For text mode the list view width is determined more precisely while it is created
; so defining a width with float here is not necessary.
SetFormat, Float, 0.%DecimalPlaces%
return

; Save the settings to the settings file.
WriteSettingsFile:
IniWrite, %TextColour%, %SettingsFileName%, Options, Text colour
IniWrite, %BackColour%, %SettingsFileName%, Options, Background colour
IniWrite, %MaximumRowsText%, %SettingsFileName%, Options, Text mode maximum rows
IniWrite, %MaximumRowsIcons%, %SettingsFileName%, Options, Icon mode maximum rows
IniWrite, %DecimalPlaces%, %SettingsFileName%, Options, Decimal places
/*
IniWrite, %RefreshRate%, %SettingsFileName%, Options, Refresh rate (ms)
*/
RefreshRateFileOutput := Round(RefreshRateFileOutput/1000)
IniWrite, %RefreshRateFileOutput%, %SettingsFileName%, Options, Refresh rate file output (sec)
RefreshRateFileOutput := Round(RefreshRateFileOutput*1000)
Transparency := 100-Round(Transparency/2.55)
IniWrite, %Transparency%, %SettingsFileName%, Options, Transparency
Transparency := 255-Round(Transparency*2.55)
IniWrite, %TextSmoothing%, %SettingsFileName%, Options, Text Smoothing
IniWrite, %OutputWindowBoldText%, %SettingsFileName%, Options, Bold Output Text
IniWrite, %ShowDoneIfDone%, %SettingsFileName%, Options, Show Done If Done
IniWrite, %ExitConfirmed%, %SettingsFileName%, Options, Disable Exit Confirmation
IniWrite, %AlwaysOnTop%, %SettingsFileName%, Options, Always On Top
return

; Read the settings from the settings file.
ReadSettingsFile:
IniRead, TextColour, %SettingsFileName%, Options, Text colour
IniRead, BackColour, %SettingsFileName%, Options, Background colour
IniRead, MaximumRowsText, %SettingsFileName%, Options, Text mode maximum rows
IniRead, MaximumRowsIcons, %SettingsFileName%, Options, Icon mode maximum rows
IniRead, DecimalPlaces, %SettingsFileName%, Options, Decimal places
/*
IniRead, RefreshRate, %SettingsFileName%, Options, Refresh rate (ms)
*/
IniRead, RefreshRateFileOutput, %SettingsFileName%, Options, Refresh rate file output (sec)
RefreshRateFileOutput := Round(RefreshRateFileOutput*1000)
IniRead, Transparency, %SettingsFileName%, Options, Transparency
Transparency := 255-Round(Transparency*2.55)
IniRead, TextSmoothing, %SettingsFileName%, Options, Text Smoothing
IniRead, OutputWindowBoldText, %SettingsFileName%, Options, Bold Output Text
IniRead, ShowDoneIfDone, %SettingsFileName%, Options, Show Done If Done
IniRead, ExitConfirmed, %SettingsFileName%, Options, Disable Exit Confirmation
IniRead, AlwaysOnTop, %SettingsFileName%, Options, Always On Top
return

; These are the games that will show up in the welcome window and can be selected there.
; Also included is the name used internally by this program for the game.
SupportedGamesList:
GameName = GTA VC
GameNameNoSpace = GTAVC
gosub %CurrentLoopCode%
GameName = GTA SA
GameNameNoSpace = GTASA
gosub %CurrentLoopCode%
GameName = GTA 3
GameNameNoSpace = GTA3
gosub %CurrentLoopCode%
GameName = The Simpsons: Hit and Run
GameNameNoSpace = SimpsonsHAR
gosub %CurrentLoopCode%
;GameName = Bully
;GameNameNoSpace = Bully
;gosub %CurrentLoopCode%
return

ErrorFilenameLength:
Gui, FilenameError:Add, Text,, The filename of the 100`% Checklist is too long: `n`nThe program can still function but settings cannot `nbe saved and file output is unavailable. `nDo you still want to continue`?
Gui, FilenameError:Add, Text,h0 w0 Y+4,
Gui, FilenameError:Add, Button, section default, Continue
Gui, FilenameError:Add, Button, ys, Abort
Gui, FilenameError:Show
Pause, On
return



FilenameErrorButtonContinue:
FilenameErrorGuiClose:
FilenameErrorGuiEscape:
Pause, Off
Gui, FilenameError:Destroy
return

FilenameErrorButtonAbort:
ExitConfirmed = 1
ExitApp

; ######################################################################################################
; ########################################### UPDATE CHECKER ###########################################
; ######################################################################################################

/*
Subheadings:

	UpdateCheck
	7ButtonYes
	7GuiClose/7GuiEscape/7ButtonNo
*/

UpdateCheck:
; Avast stops the program from functioning correctly, presumably because it tries to connect to the internet for the
; update checker. So we will read the registry to see if Avast has been installed. The location of the registry key
; by which we determine if Avast is installed depends on whether the OS is 64 or 32 bit. If it is 64 bit, the key
; can be in one of two locations (one for the 32 bit version of Avast and one for the 64 bit version). The 32 bit
; OS only has one possible location.
if (A_Is64bitOS)
{
	SetRegView 64
	RegRead, AvastInstalled, HKLM, Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Avast, DisplayName
	if ErrorLevel = 1
		RegRead, AvastInstalled, HKLM, Software\Microsoft\Windows\CurrentVersion\Uninstall\Avast, DisplayName
}
else
	RegRead, AvastInstalled, HKLM, Software\Microsoft\Windows\CurrentVersion\Uninstall\Avast, DisplayName
; If there was no problem reading the registry the registry key exists, so Avast is installed. In this case
; let the user know the update checker has been disabled and skip it.
if ErrorLevel = 0
{
	outputdebug %AvastInstalled% detected
	MsgBox, Avast has been detected on your computer. `nThe auto-updater has been disabled.
	return
}
; Delete Updater.cmd to make sure the most recent version is always used.
FileDelete, Updater.cmd
UrlDownloadToFile, %VersionURL%, Version.ini
if ErrorLevel = 0 ; Check if the version file was downloaded successfully.
{
	; Check if a newer version is released. If this is the case, show the update screen with the current
	; version (stored internally), a description and the version it will update to (both read from the version file).
	IniRead, NewestVersion, Version.ini, Version, %ProgramName%
	if (NewestVersion != "Error" AND NewestVersion > CurrentVersion)
	{
		UpdaterActive = 1
		Gui 7:-MinimizeBox -MaximizeBox +LastFound
		Gui, 7:Font, Q3
		Gui, 7:Add, Text,, An update is available. Current version`: v%CurrentVersion%. `nNew version`: v%NewestVersion%. Would you like to update now`?
		IniRead, DescriptionText, Version.ini, %ProgramName% Files, Description
		if (DescriptionText != "Error" AND DescriptionText != "")
		{
			Gui, 7:Font, w700 Q3 ; Bold
			Gui, 7:Add, Text,, Update description`:
			Gui, 7:Font, w400 Q3 ; Normal
			Gui, 7:Add, Text,h0 w0 Y+4,
			StringSplit, DescriptionTextArray, DescriptionText, `|
			Loop %DescriptionTextArray0%
				Gui, 7:Add, Text,Y+1, % DescriptionTextArray%A_Index%
		}
		Gui, 7:Add, Text,h0 w0 Y+4,
		Gui, 7:Add, Button, section default, Yes
		Gui, 7:Add, Button, ys, No
		Gui, 7:Show
		return
	}
}
; If the version file failed to download or there is no new version, delete the version file and continue running the program.
FileDelete, Version.ini
return

; If the user accepts, show a splash text that the new version is being downloaded.
7ButtonYes:
Gui, 7:Hide
SplashTextOn , 350 , , Downloading the new version. This might take some time...
; Download all the files from the file list defined earlier, from the locations specified in the version file.
Loop
{
	If File%A_Index% =
		break
	File := File%A_Index%
	IniRead, FileLink, Version.ini, %ProgramName% Files, %File%
	UrlDownloadToFile, %FileLink%, %File%
}
; We don't need the version file anymore, so delete it.
FileDelete, Version.ini
; Once that's done, run the updater.cmd included in the executable of the running version. This is necessary because
; in order to update, the executable has to be replaced. Since that can't be done while the program is still running,
; it has to be done from a different process, in this case the updater.cmd, a Windows Command Script. From command-line,
; it will first close this program, then copy the new version of the executable over the old, then automatically start
; the new version. In all cases the version.ini file is deleted as to not clutter the computer. Since the updater.cmd
; is deleted every time the auto-updater checks for new updates, it will be deleted right after it has started the new version.
UpdateVar1 = `"%A_ScriptDir%\%ExecutableFile%`" ; Location of the newversion exe.
UpdateVar2 = `"%A_ScriptFullPath%`" ; Location of the old (currently running) exe which will be overwritten.
UpdateVar3 := DllCall("GetCurrentProcessId") ; Script PID so it can be closed.
FileInstall, Updater.cmd, Updater.cmd, 1
Run, Updater.cmd %UpdateVar1% %UpdateVar2% %UpdateVar3%, ,
sleep 5000 ; Give the updater some time to close this program.
ExitConfirmed = 1
exitapp

;If the user declines the update, delete the version file and continue running the program.
7GuiClose:
7GuiEscape:
7ButtonNo:
Gui, 7:Destroy
FileDelete, Version.ini
UpdaterActive = 0
return


; ######################################################################################################
; ########################################### WELCOME WINDOW ###########################################
; ######################################################################################################

/*
Subheadings:

	WelcomeScreen
	2GuiClose/2GuiEscape/2ButtonClose
	2GuiContextMenu
	2ButtonConfirm
	SelectGameCode
	SetCurrentGameCode
*/

; Create the welcome window. First the minimize and maximize buttons are removed, and LastFound is set so
; functions affecting the window later will automatically act on this one without having to specify.
; Next the background colour is set and then, dependent on the settings, the font options are set.
; If the window is even slightly transparent, the font gets maximum boldness, and if text smoothing
; is off or if the window is again even slightly transparent, text smoothing is turned off (having
; it turned on with a transparent background creates ugly borders). It proceeds to add the text and
; other controls to the window, some of which have somewhat specific placement settings, such as
; width or position relative to the previous control. Some empty text controls are also created to
; create some space between the controls above and below it. If any level of transparency is in play,
; the background window is made entirely transparent and some preparations are made for faking a
; semi-transparent background. After the gui is rendered, a second window is created which is locked
; to the first. It consists of just a background which is semi-transparent. (Within one window, it is
; possible to make either the background completely transparent, or the entire window, including controls,
; semi-transparent. This is the only decent solution I have found. It does have some issues (see readme)
; but nothing major.) The background window is set to be the owner of the real window, to avoid it being
; selectable which would push the background over the other window. Even if the background is completely
; transparent, the background window is still created, because otherwise clicks would fall through (this
; only happens if a specific colour is made transparent as is the case for the real window, it doesn't
; happen if the entire window is made completely transparent as is the case for the background window.)
WelcomeScreen:
gui 2:-MinimizeBox -MaximizeBox +LastFound
gui, 2:Color, %BackColour%, %BackColour%
if AlwaysOnTop = 1
	Winset, AlwaysOnTop, On
if Transparency < 255
{
	gui, 2:Font, w1000
	WelcomeWindowWidth := 300
}
else
	WelcomeWindowWidth := 250
if (Transparency < 255 or TextSmoothing = 0)
	gui, 2:Font, Q3
gui, 2:Add, Text,c%TextColour% center w%WelcomeWindowWidth%, Welcome to the 100`% Checklist v%CurrentVersion%!
gui, 2:Add, Text,c%TextColour% y+5 center w%WelcomeWindowWidth%, Created by`: Lighnat0r
if Transparency < 255
	gui, 2:Add, Text,c%TextColour% w100 section, Select the game:
else
	gui, 2:Add, Text,c%TextColour% w80 section, Select the game:
gui, 2:Add, Text,ys h0 w0,
CurrentLoopCode = SelectGameCode
gosub SupportedGamesList
gui, 2:Add, Checkbox,c%TextColour% vPercentageOnlyMode xs, Show percentage only
gui, 2:Add, Text,,
if Transparency < 255
	gui, 2:Add, Text,c%TextColour% w110 xs section, Select output type:
else
	gui, 2:Add, Text,c%TextColour% w90 xs section, Select output type:
gui, 2:Add, Radio,c%TextColour% ys vOutputTypeText checked gHideOutputFileLocation, Text
gui, 2:Add, Radio,c%TextColour% ys vOutputTypeIcons gHideOutputFileLocation, Icons
gui, 2:Add, Radio,c%TextColour% ys vOutputTypeFile gShowOutputFileLocation, File
OutputFileString = Output stored in `"%ScriptNameNoExt% Output`.txt`"
OutputFileStringLength := StrLen(OutputFileString)
OutputFileTextRows := Ceil(OutputFileStringLength*6/WelcomeWindowWidth) ; We need 6 pixels per character.
gui, 2:Add, Text,c%TextColour% w%WelcomeWindowWidth% r%OutputFileTextRows% xs vOutputFileText,
gui, 2:Add, Button, xs section, Confirm
gui, 2:Add, Button, ys, Close
gui, 2:Add, Button, ys, Settings
if Transparency < 255
{
	WinSet, TransColor, %BackColour%
	WelcomeWindowID := WinExist()
	OnMessage(0x0047, "WM_WELCOMEWINDOWPOSCHANGED")
	gui 2: -Border
}
gui, 2:Show,
if Transparency < 255
{
	WinGetPos,,,WelcomeWindowNoBorderWidth,WelcomeWindowNoBorderHeight
	gui 2: +Border
	gui, 2:Show, Autosize
	WinGetPos,WelcomeWindowX,WelcomeWindowY,WelcomeWindowWidth,WelcomeWindowHeight
	BackgroundX := WelcomeWindowX+WelcomeWindowWidth-WelcomeWindowNoBorderWidth
	BackgroundY := WelcomeWindowY+WelcomeWindowHeight-WelcomeWindowNoBorderHeight
	gui 5: +LastFound
	gui, 5:Color, %BackColour%, %BackColour%
	Winset, Transparent, %Transparency%
	gui 5: -Caption
	Gui, 5: Show, x%BackgroundX% y%BackgroundY% w%WelcomeWindowNoBorderWidth% h%WelcomeWindowNoBorderHeight% NoActivate
	gui 2: +Owner5
}
return

ShowOutputFileLocation:
GuiControlGet, OutputFileTextContents, , OutputFileText
if (OutputFileTextContents != OutputFileString)
	GuiControl, , OutputFileText, %OutputFileString%
return

HideOutputFileLocation:
GuiControlGet, OutputFileTextContents, , OutputFileText
if (OutputFileTextContents != "")
	GuiControl, , OutputFileText,
return

; What happens if the user tries to close the window.
2GuiClose:
2GuiEscape:
2ButtonClose:
CurrentGUI = 2
exitapp
return

; Create a context menu if the user right clicks on the window.
2GuiContextMenu:
Menu, OutputRightClick, Add, Restart Script, RestartSequence
Menu, OutputRightClick, Add, Open Readme, OpenReadme
Menu, OutputRightClick, Add, Exit, 2GuiClose
Menu, OutputRightClick, Show
return

; This function is set to trigger as soon as the real window is moved and moves the
; background window with it.
WM_WELCOMEWINDOWPOSCHANGED()
{
	global
	gui 2: +LastFound
	WinGetPos,WelcomeWindowX,WelcomeWindowY,
	gui 5: +LastFound
	BackgroundX := WelcomeWindowX+(WelcomeWindowWidth-WelcomeWindowNoBorderWidth)
	BackgroundY := WelcomeWindowY+(WelcomeWindowHeight-WelcomeWindowNoBorderHeight)
	WinMove, BackgroundX, BackgroundY
}

; If the user presses the confirm button, first check if all the options have been
; selected correctly. If not, show an error message and restore the window. The
; program tries to restore the background window without checking if it exists, but
; this doesn't seem to cause any issues. If the options are selected correctly,
; configure the right options internally. Proceed to the output window after that.
2ButtonConfirm:
gui, 5:submit
gui, 2:submit
CurrentLoopCode = SetCurrentGameCode
gosub SupportedGamesList
if CurrentGame = 
{
	Msgbox,  Please select a game.
	Gui, 5:Restore
	Gui, 2:Restore
	return
}
if OutputTypeText = 1
	OutputType = Text
else if OutputTypeIcons = 1
	OutputType = Icons
else if OutputTypeFile = 1
	OutputType = File
if PercentageOnlyMode = 1
	SpecialMode = PercentageOnly
; Now that the options are selected, we can create the requirements array.
CurrentLoopCode = CreateRequirementsArray
gosub %CurrentGame%%SpecialMode%Requirements
If (OutputType = "File")
	Goto FileOutput
Else
	Goto OutputWindow

; Code adding a control to the welcome screen for every game in the supported games list.
SelectGameCode:
gui, 2:Add, Radio, c%TextColour% vSelectGame%GameNameNoSpace%, %GameName%
return

; Code setting the current game name based on the option selected in the welcome window.
; For every game in the supported games list, it checks if the option was selected and
; sets the CurrentGame variable to it if so. If no option was selected, the CurrentGame
; variable will simply remain blank (which will generate an error in the code belonging
; to the confirm button.) If it would be possible to return to the welcome window from
; the output window it would be necessary to blank the CurrentGame variable to avoid
; missing this error.
SetCurrentGameCode:
if SelectGame%GameNameNoSpace% = 1
	CurrentGame = %GameNameNoSpace%
return

; If the settings button is pressed, hide the welcome window and start the subroutine
; which creates the settings window.
2ButtonSettings:
gui 2:Hide
gui 5:Hide
gosub CreateSettingsWindow
return

; Create the requirements array. It is initialised the first time this subroutine is
; called, then it can be populated.
CreateRequirementsArray:
if %CurrentGame%%SpecialMode%RequirementsArrayCreated != 1
{
	%CurrentGame%%SpecialMode%RequirementsArrayIndex = 1
	%CurrentGame%%SpecialMode%RequirementsArray := {}
	%CurrentGame%%SpecialMode%RequirementsArrayCreated = 1
}
else
	%CurrentGame%%SpecialMode%RequirementsArrayIndex += 1

; The following shouldn't be necessary since values in an array can be empty.
/*
if Type = 
	Type = Null
if TotalRequired = 
	TotalRequired = Null
if Address%A_Index%Length = 
	Address%A_Index%Length = Null
if Address%A_Index%CustomCode = 
	Address%A_Index%CustomCode = Null
*/

; Create the array with all the requirements. Each name signifies an object created below
; which contains all the properties belonging to it. The name of the array
; is unique for each game/special mode even though currently only one of them
; can exist at a time. This way hotswitching can be added later without the
; the program breaking here. It might also avoid issues caused by multiple
; games using the same icon. The IconName is used instead of the Name because it does not
; contain any spaces which would can't be used in an object name.
%CurrentGame%%SpecialMode%RequirementsArray.Insert(IconName)
; Now create the object with its properties. Store the type and icon name,
; then loop to store all the addresses defined with the corresponding
; length and custom code flags. Again add the name of the game and the special
; mode to avoid issues.
%CurrentGame%%SpecialMode%%IconName% := {} ; Create the object
%CurrentGame%%SpecialMode%%IconName%.Insert("Name", Name)
%CurrentGame%%SpecialMode%%IconName%.Insert("Type", Type)
%CurrentGame%%SpecialMode%%IconName%.Insert("TotalRequired", TotalRequired)
; Loop through all the defined addresses, adding them to the object if they are defined.
; Immediately after adding them, clear the address and its length and custom code flags
; in preparation of adding the next requirement once this subroutine is called again.
Loop
{
	if Address%A_Index% = 
		break
	%CurrentGame%%SpecialMode%%IconName%.Insert("Address"A_Index, Address%A_Index%)
	if Address%A_Index%Length =
		Address%A_Index%Length = 4 ; Default length
	%CurrentGame%%SpecialMode%%IconName%.Insert("AddressLength"A_Index, Address%A_Index%Length)
	%CurrentGame%%SpecialMode%%IconName%.Insert("AddressCustomCode"A_Index, Address%A_Index%CustomCode)
	Address%A_Index% = 
	Address%A_Index%Length = 
	Address%A_Index%CustomCode = 
}
; Also reset all the other variables. Only the optional variables need to be reset,
; but resetting all variables makes sure they doesn't cause any issues.
Name =
Type = 
IconName = 
TotalRequired =
return

; ######################################################################################################
; ########################################### SETTINGS WINDOW ##########################################
; ######################################################################################################

/*
Subheadings:

	2ButtonSettings
	4ButtonSave
	4ButtonDiscard/4GuiEscape
	4ButtonRestoreDefault
	4GuiClose
	4GuiContextMenu
	ChangeTextColour
	ChangeBackColour
	ChooseColour
	MaximumRowsText
	MaximumRowsIcons
	RefreshRateUpDown
*/


CreateSettingsWindow:
SettingsTextWidth := 180
gui 4:-MinimizeBox -MaximizeBox +LastFound
; Store the original values in case the settings window is discarded.
TextColourOriginal := TextColour
BackColourOriginal := BackColour
MaximumRowsTextOriginal := MaximumRowsText
MaximumRowsIconsOriginal := MaximumRowsIcons
DecimalPlacesOriginal := DecimalPlaces
/*
RefreshRateOriginal := RefreshRate
*/
RefreshRateFileOutputOriginal := RefreshRateFileOutput
TransparencyOriginal := Transparency
TextSmoothingOriginal := TextSmoothing
OutputWindowBoldTextOriginal := OutputWindowBoldText
ShowDoneIfDoneOriginal := ShowDoneIfDone
ExitConfirmedOriginal := ExitConfirmed
AlwaysOnTopOriginal := AlwaysOnTop

; Add the controls for changing text colour
Gui, 4:Add, Text, y+10 w%SettingsTextWidth% section, Text colour`:
Gui, 4:Add, Button, ys vTextColour gChangeTextColour w60, %TextColour%
; Add the controls for changing background colour
Gui, 4:Add, Text,xs w%SettingsTextWidth% section, Background colour`:
Gui, 4:Add, Button, ys vBackColour gChangeBackColour w60, %BackColour%
/*
; Create the structure which contains the custom colours in the colour dialog
; if it doesn't exist already. The custom colours in it need to be saved in the
; settings file.
if CustomColoursStructureExists != 1
{
	VarSetCapacity(CustomColoursStructure, 64, 0)
	CustomColoursStructureExists = 1
}
*/
/*
; Add the controls for changing font
Gui, 4:Add, Text, xs w%SettingsTextWidth% section, Font`:
Gui, 4:Add, Button, ys vFont gChangeFont w60, %Font%
*/
; Add the controls for changing maximum rows text
Gui, 4:Add, Text,xs w%SettingsTextWidth% section vMaximumRowsTextDescription, Text mode maximum rows `(4`-65`)`:
Gui, 4:Add, Slider, ys vMaximumRowsText gMaximumRowsText Range4-65 w120 Tooltip Center Noticks , %MaximumRowsText%
Gui, 4:Add, Text,x+0 vMaximumRowsTextTextControl w12, %MaximumRowsText%
GuiControl, +Buddy2MaximumRowsTextTextControl, MaximumRowsText
; Add the controls for changing maximum rows icons
Gui, 4:Add, Text,xs w%SettingsTextWidth% section vMaximumRowsIconsDescription, Icon mode maximum rows `(3`-30`)`:
Gui, 4:Add, Slider, ys vMaximumRowsIcons gMaximumRowsIcons Range3-30 w120 Tooltip Center Noticks , %MaximumRowsIcons%
Gui, 4:Add, Text,x+0 vMaximumRowsIconsTextControl w12, %MaximumRowsIcons%
GuiControl, +Buddy2MaximumRowsIconsTextControl, MaximumRowsIcons
; Add the controls for changing decimal places
Gui, 4:Add, Text,xs w%SettingsTextWidth% section, Decimal places `(0`-5`)`:
Gui, 4:Add, Slider, ys vDecimalPlaces gDecimalPlaces Range0-5 w120 Tooltip Center Noticks , %DecimalPlaces%
Gui, 4:Add, Text,x+0 vDecimalPlacesTextControl w6, %DecimalPlaces%
GuiControl, +Buddy2DecimalPlacesTextControl, DecimalPlaces
/*
; Add the controls for changing refresh rate.
Gui, 4:Add, Text,xs w%SettingsTextWidth% section, Refresh rate `(100`-10`,000 ms`)`:
Gui, 4:Add, Slider, ys vRefreshRate gRefreshRate Range100-10000 w120 Tooltip Center Noticks, %RefreshRate%
Gui, 4:Add, Text,x+0 vRefreshRateTextControl w30, %RefreshRate%
GuiControl, +Buddy2RefreshRateTextControl, RefreshRate
*/
; Add the controls for changing refresh rate for file output.
RefreshRateFileOutput := Round(RefreshRateFileOutput/1000)
Gui, 4:Add, Text, xs w%SettingsTextWidth% section, Refresh rate file output `(0`-20 sec`)`:
Gui, 4:Add, Slider, ys vRefreshRateFileOutput gRefreshRateFileOutput Range0-20 w120 Tooltip Center Noticks, %RefreshRateFileOutput%
Gui, 4:Add, Text, x+0 vRefreshRateFileOutputTextControl w30, %RefreshRateFileOutput%
GuiControl, +Buddy2RefreshRateFileOutputTextControl, RefreshRateFileOutput
; Add the controls for changing transparency
Transparency := 100-Round(Transparency/2.55)
Gui, 4:Add, Text,xs w%SettingsTextWidth% section, Transparency `(0`-100`%`)`:
Gui, 4:Add, Slider, ys vTransparency gTransparency Range0-100 w120 Tooltip Center Noticks , %Transparency%
Gui, 4:Add, Text,x+0 vTransparencyTextControl w28, %Transparency%`%
GuiControl, +Buddy2TransparencyTextControl, Transparency
; Add the controls for changing text smoothing
Gui, 4:Add, Text,xs w%SettingsTextWidth% section, Text smoothing`:
Gui, 4:Add, Checkbox, vTextSmoothing ys Checked%TextSmoothing%,
; Add the controls for changing output window bold text
Gui, 4:Add, Text,xs w%SettingsTextWidth% section, Output window bold text`:
Gui, 4:Add, Checkbox, vOutputWindowBoldText ys Checked%OutputWindowBoldText%,
; Add the controls for changing show done if done
Gui, 4:Add, Text,xs w%SettingsTextWidth% section, Show "DONE" when an item is done`:
Gui, 4:Add, Checkbox, vShowDoneIfDone ys Checked%ShowDoneIfDone%,
; Add the controls for changing exit confirmed
Gui, 4:Add, Text,xs w%SettingsTextWidth% section, Skip exit confirmation`:
Gui, 4:Add, Checkbox, vExitConfirmed ys Checked%ExitConfirmed%,
; Add the controls for changing always on top
Gui, 4:Add, Text,xs w%SettingsTextWidth% section, Show checklist always on top`:
Gui, 4:Add, Checkbox, vAlwaysOnTop ys Checked%AlwaysOnTop%,
; Add the buttons for saving, discarding and restoring default settings.
; After all these controls are added, show the window.
gui, 4:Add, Text,xs,
Gui, 4:Add, Button,xs section, Save
Gui, 4:Add, Button,ys, Discard
Gui, 4:Add, Button,ys, Restore Default
gui, 4: Show
return

4ButtonSave:
gui, 4:Submit
; Since everything with the same colour as the background is made transparent
; with transparency on, 'protect' some standard colours.
if (Backcolour = 000000 and Transparency < 255)
	BackColour = 000001
if (Backcolour = F0F0F0 and Transparency < 255)
	BackColour = F1F1F1
/*
if (BackColour = TextColour and Transparency < 255)
{
	BackColour += 1
	BackColour2 := SubStr("00000" . BackColour, -5)
}
*/
; Translate transparency to something the program understands.
Transparency := 255-Round(Transparency*2.55)
; Translate refresh rate from sec to ms for the program.
RefreshRateFileOutput := Round(RefreshRateFileOutput*1000)
; Destroy the settings screen and the welcome screen, save the new settings
; to a file and set the right variables. Then redraw the welcome screen.
gui, 4:Destroy
gui 2:Destroy
gui 5:Destroy
gosub WriteSettingsFile
gosub SetVariablesDependentOnSettings
goto WelcomeScreen
return

; If the settings menu is canceled, undo all the changes made and restore the
; variables to what was saved at the start of initialising the settings window.
; Also destroy the settings window. Since no settings are changed, there is no
; need to destroy and redraw the welcome screen so we just restore it.
4ButtonDiscard:
4GuiEscape:
gui, 4:Destroy
TextColour := TextColourOriginal
BackColour := BackColourOriginal
MaximumRowsText := MaximumRowsTextOriginal
MaximumRowsIcons := MaximumRowsIconsOriginal
DecimalPlaces := DecimalPlacesOriginal
/*
RefreshRate := RefreshRateOriginal
*/
RefreshRateFileOutput := RefreshRateFileOutputOriginal
Transparency := TransparencyOriginal
TextSmoothing := TextSmoothingOriginal
OutputWindowBoldText := OutputWindowBoldTextOriginal
ShowDoneIfDone := ShowDoneIfDoneOriginal
ExitConfirmed := ExitConfirmedOriginal
AlwaysOnTop := AlwaysOnTopOriginal

gui 5:Restore
gui 2:Restore
return

; Restore all the settings to default as defined in the DefaultSettings subroutine.
4ButtonRestoreDefault:
gosub DefaultSettings
Guicontrol,,TextColour,%TextColour%
Guicontrol,,BackColour,%BackColour%
Guicontrol,,MaximumRowsText,%MaximumRowsText%
Guicontrol,,MaximumRowsTextTextControl,%MaximumRowsText%
Guicontrol,,MaximumRowsIcons,%MaximumRowsIcons%
Guicontrol,,MaximumRowsIconsTextControl,%MaximumRowsIcons%
Guicontrol,,DecimalPlaces,%DecimalPlaces%
Guicontrol,,DecimalPlacesTextControl,%DecimalPlaces%
/*
Guicontrol,,RefreshRate,%RefreshRate%
Guicontrol,,RefreshRateTextControl,%RefreshRate%
*/
RefreshRateFileOutput := Round(RefreshRateFileOutput/1000)
Guicontrol,,RefreshRateFileOutput,%RefreshRateFileOutput%
Guicontrol,,RefreshRateFileOutputTextControl,%RefreshRateFileOutput%
Transparency := 100-Round(Transparency/2.55)
Guicontrol,,Transparency,%Transparency%
Guicontrol,,TransparencyTextControl,%Transparency%`%
Guicontrol,,TextSmoothing,%TextSmoothing%
Guicontrol,,OutputWindowBoldText,%OutputWindowBoldText%
Guicontrol,,ShowDoneIfDone,%ShowDoneIfDone%
Guicontrol,,ExitConfirmed,%ExitConfirmed%
Guicontrol,,AlwaysOnTop,%AlwaysOnTop%
return

; Close the window.
4GuiClose:
CurrentGUI = 4
exitapp
return

; Add a right click context menu.
4GuiContextMenu:
Menu, OutputRightClick, Add, Restart Script, RestartSequence
Menu, OutputRightClick, Add, Open Readme, OpenReadme
Menu, OutputRightClick, Add, Exit, 4GuiClose
Menu, OutputRightClick, Show
return

; Set the colour to change to text colour and start the colour dialog.
ChangeTextColour:
ColourType = Text
gosub ChooseColour
return

; Set the colour to change to background colour and start the colour dialog.
ChangeBackColour:
ColourType = Back
gosub ChooseColour
return

; Initialise the colour dialog, which requires a structure to be set up but
; is otherwise mostly a built-in function.
ChooseColour:
GuiHandle := WinExist()
%ColourType%ColourNew := ChooseColourDialog(%ColourType%Colour, GuiHandle, CustomColoursStructure)
If (%ColourType%ColourNew != "Error")
{
	%ColourType%Colour := %ColourType%ColourNew
	Guicontrol,,%ColourType%Colour,% %ColourType%Colour
}
return

/*
; Call the subroutine which will initialise the font dialog.
ChangeFont:
gosub ChooseFont
return

; Initialise the font dialog, which requires a structure to be set up but
; is otherwise mostly a built-in function.
ChooseFont:
if FontStructureExists = 0
{
	VarSetCapacity(FontStructure, 0x60, 0)
	FontStructureExists = 1
}
GuiHandle := WinExist()
VarSetCapacity(FontDialogStructure, 0x3C, 0)
	NumPut(0x3C, FontDialogStructure, 0x0, "Uint")
	NumPut(GuiHandle, FontDialogStructure, 0x4) ; Will make the font dialog owned by the gui window
;	0x8 is unused
	NumPut(&FontStructure, FontDialogStructure, 0xC) Input/Output structure containing the font attributes
;	0x10 is the output for the font size
;	0x14 contains flags to set for creating the font dialog
;	0x18 contains a RGB macro if that flag is set in 0x14
;	0x1C is lCustData, not sure what this does
;	0x20 is a handle to some thing that handles messages if that flag is set in 0x14
;	0x24 is the name of the custom template for the font dialog in 0x28
; 	0x28 is the handle to the custom template if that flag is set in 0x14
;	0x2C is the input/output for a font style combo box if that flag is set in 0x14
;	0x30 is the output for the font type (e.g. bold, italic, etc)
;	0x34 is the minimum font size if that flag is set in 0x14
;	0x38 is the maximum font size if that flag is set in 0x14
ChooseFontErrorLevel := DllCall("Comdlg32\ChooseFont", "Ptr", &FontDialogStructure)
if ChooseFontErrorLevel != 0
{
	FontSize := NumGet(FontDialogStructure, 0x10, "Int") / 10
	FontType := NumGet(FontDialogStructure, 0x30, "Int")
	msgbox ok %FontSize% %FontType%
}
return
*/

; Update the text next to the maximum text rows slider.
MaximumRowsText:
Guicontrol,,MaximumRowsTextTextControl,%MaximumRowsText%
return

; Update the text next to the maximum icons rows slider.
MaximumRowsIcons:
Guicontrol,,MaximumRowsIconsTextControl,%MaximumRowsIcons%
return

; Update the text next to the decimal places slider.
DecimalPlaces:
Guicontrol,,DecimalPlacesTextControl,%DecimalPlaces%
return

/*
; Update the text next to the refresh rate slider.
RefreshRate:
Guicontrol,,RefreshRateTextControl,%RefreshRate%
return
*/

; Update the text next to the refresh rate for file output slider.
RefreshRateFileOutput:
Guicontrol,,RefreshRateFileOutputTextControl,%RefreshRateFileOutput%
return

; Update the text next to the transparency slider.
Transparency:
Guicontrol,,TransparencyTextControl,%Transparency%`%
return



; ######################################################################################################
; ########################################### OUTPUT WINDOW ############################################
; ######################################################################################################

/*
Subheadings:

	OutputWindow
	GuiClose/GuiEscape
	GuiContextMenu
	MoveWindow
	WM_LBUTTONDOWN
	TextPopulateListView
	IconsPopulateListView
	ButtonChangeOutputType
*/

OutputWindow:
Gui 1:-MinimizeBox -MaximizeBox +LastFound
Gui, 1:Default
if AlwaysOnTop = 1
	Winset, AlwaysOnTop, On
If (Transparency < 255 or OutputWindowBoldText = 1)
	Gui, 1:Font, w1000
If (Transparency < 255 or TextSmoothing = 0)
	Gui, 1:Font, Q3
Gui, 1:Add, Button, , Change Output Type
ListViewNumber = 1
RowAmount = 0
MaximumRows := MaximumRows%OutputType%
MaxValueLengthInPixels%ListViewNumber% = 0
If (OutputType = "Text")
	Gui, 1:Add, ListView, c%TextColour% vRequirementsListView%ListViewNumber% Background%BackColour% gMoveWindow w%TextListViewWidth% Count20 -Multi -E0x200 section -Hdr, Name|Value|Required
Else If (OutputType = "Icons")
{
	Gui, 1:Add, ListView, c%TextColour% vRequirementsListView%ListViewNumber% Background%BackColour% gMoveWindow w%IconListViewWidth% Count15 -Multi -E0x200 section +Tile -LV0x20 +LV0x1 +0x2000 -0x8, Value
	ImageListID := IL_Create(20, 1, 1)
	LV_SetImageList(ImageListID, 0) ; 0 specifies large icons
}
Else
{
	msgbox, Error`: Unknown output type`.
	ExitConfirmed = 1
	exitapp
}
; For each requirement in the requirements array, add it to the list view.
; At the start of every requirement, check if the list view exceeds the maximum
; length and create a new one in necessary.
For Index, IconName in %CurrentGame%%SpecialMode%RequirementsArray
{
	Name := %CurrentGame%%SpecialMode%%IconName%.Name
	Type := %CurrentGame%%SpecialMode%%IconName%.Type
	TotalRequired := %CurrentGame%%SpecialMode%%IconName%.TotalRequired
	RowAmount += 1
	If RowAmount > %MaximumRows%
	{
		RowAmount = 1
		TotalRows := LV_GetCount()
		; For icons mode: each icon is 32x32 pixels with 4 pixels vertical padding between icons.
		; For text mode: each text has a height of 11 pixels with 4 pixels vertical padding at the top, 2 pixels at the bottom.
		ListViewHeight := TotalRows*((OutputType = "Text") ? 17 : 36)
		Guicontrol, Move, RequirementsListView%ListViewNumber%, h%ListViewHeight%
		; Update the column width and then update the list view width based on the column width.
		; The reason the column width needs to be updated is because of the variable length of
		; the requirement name, so this is only necessary in text mode (which is good because the
		; code wouldn't work for icons since it doesn't take the icon size into account).
		If (OutputType = "Text")
		{
			LV_ModifyCol() ; Set the width for the columns
			; We want 24 padding with the current layout of the listview. This padding is the area between the
			; list views but also the padding between the columns.
			ListViewTargetWidth = 24
			If FloatInListView%ListViewNumber% = 1
				ListViewTargetWidth += Round(5.6*DecimalPlaces)
			Loop % LV_GetCount("Column")
			{
				SendMessage, 4125, A_Index-1, 0, SysListView32%ListViewNumber%  ; 4125 is LVM_GETCOLUMNWIDTH.
				ListViewTargetWidth += %ErrorLevel%
			}
			GuiControl, Move, RequirementsListView%ListViewNumber%, w%ListViewTargetWidth%
		}
		; We need to determine the X for the new list view manually, since we potentially changed
		; its size. The gui add function doesn't keep track of that by itself so it would put the
		; new listview based on the old width and the two list views would overlap or have too much padding.
		ControlGetPos,PreviousListViewX,,PreviousListViewWidth,,SysListView32%ListViewNumber%,,,
		NewX := PreviousListViewX+PreviousListViewWidth
		ListViewNumber += 1
		MaxValueLengthInPixels%ListViewNumber% = 0
		If (OutputType = "Text")
		{
			Gui, 1:Add, ListView, c%TextColour% vRequirementsListView%ListViewNumber% Background%BackColour% gMoveWindow w%TextListViewWidth% Count20 -Multi -E0x200 x%NewX% ys -Hdr,Name|Value|Required
		}
		Else If (OutputType = "Icons")
		{
			Gui, 1:Add, ListView, c%TextColour% vRequirementsListView%ListViewNumber% Background%BackColour% gMoveWindow w%IconListViewWidth% Count15 -Multi -E0x200 x%NewX% ys +Tile -LV0x20 +LV0x1 +0x2000 -0x8,Value
			LV_SetImageList(ImageListID, 0) ; 0 specifies large icons
		}
	}
	If (OutputType = "Text")
	{
		; Create the entry in the listview. Check if TotalRequired is defined, if not leave it out.
		LV_Add("", Name, 0, ((TotalRequired != "") ? ("`/"TotalRequired) : "" ))
		If Type = Float
			FloatInListView%ListViewNumber% = 1
	}
	Else If (OutputType = "Icons")
	{
		IconNumber := IconArray[IconName]
		IconIndex := IL_Add(ImageListID, ImageFilename, IconNumber)
		; Create the entry in the listview. Check if TotalRequired is defined, if not leave it out.
		LV_Add("Icon" . IconIndex, ((TotalRequired != "") ? ("0`/"TotalRequired) : 0 ))
		If Type = Float
			GuiControl, Move, RequirementsListView%ListViewNumber%, w%IconListViewWidthWithFloat%
	}

}
TotalRows := LV_GetCount()
gui, 1:Color, %BackColour%, %BackColour%
if Transparency < 255
{
	WinSet, TransColor, %BackColour%
	OutputWindowID := WinExist()
	OnMessage(0x0047, "WM_OUTPUTWINDOWPOSCHANGED")
}
else
{
	gui 1:-Caption
	OnMessage(0x201, "WM_LBUTTONDOWN")
}
If (OutputType = "Text")
{
	LV_ModifyCol() ; Set the width for the columns
	; We want 24 padding with the current layout of the listview. This padding is the area between the
	; list views but also the padding between the columns.
	If FloatInListView%ListViewNumber% = 1
		ListViewTargetWidth += Round(5.6*DecimalPlaces)
	ListViewTargetWidth = 24
	Loop % LV_GetCount("Column")
	{
		SendMessage, 4125, A_Index-1, 0, SysListView32%ListViewNumber%  ; 4125 is LVM_GETCOLUMNWIDTH.
		ListViewTargetWidth += %ErrorLevel%
	}
	GuiControl, Move, RequirementsListView%ListViewNumber%, w%ListViewTargetWidth%
}
; For text mode: each text has a height of 11 pixels with 4 pixels vertical padding at the top, 2 pixels at the bottom, for a total of 17.
; For icons mode: each icon is 32x32 pixels with 4 pixels vertical padding between icons, for a total of 36.
ListViewHeight := TotalRows*((OutputType = "Text") ? 17 : 36)
Guicontrol, Move, RequirementsListView%ListViewNumber%, h%ListViewHeight%
; Set the height of the window in pixels. We can describe the window in three parts:
; From the top of the window (so including the button) to the list view, which is 35 pixels.
; The height of the list view (the first list view is always the longest so use that one).
; Padding at the bottom, which can be chosen as whatever. We will use 5 here.
ControlGetPos,,,,RequirementsListViewHeight,SysListView321,,,
GuiHeight := 35+RequirementsListViewHeight+5
; When dealing with lengthy requirements (such as Sunshine Autos Import Garage), the TextListViewWidth default is not enough for bolded output with only one column.
; Therefore we base the gui width on the listview width if dealing with only one column and with text output.
if (ListViewNumber = 1 AND OutputType = "Text")
{
	ControlGetPos,,,RequirementsListViewWidth,,SysListView321,,,
	GuiWidth := RequirementsListViewWidth+16
	; Check if this is the first time the window is shown or if it is redrawn after changing the output type.
	; If it is being redrawn, use the saved position of the original window to draw it at the same position.
	If OutputChanged = 1
		gui, 1:Show, h%GuiHeight% x%OutputWindowX% y%OutputWindowY% w%GuiWidth%
	else
		gui, 1:Show, h%GuiHeight% w%GuiWidth%
}
Else
{
	; Check if this is the first time the window is shown or if it is redrawn after changing the output type.
	; If it is being redrawn, use the saved position of the original window to draw it at the same position.
	If OutputChanged = 1
		gui, 1:Show, h%GuiHeight% x%OutputWindowX% y%OutputWindowY% ; w%GuiWidth%
	else
		gui, 1:Show, h%GuiHeight% ; w%GuiWidth%
}
; If any level of transparency is in play, the background window is made entirely transparent and some
; preparations are made for faking a semi-transparent background. After the gui is rendered, a second
; window is created which is locked to the first. It consists of just a background which is semi-
; transparent. (Within one window, it is possible to make either the background completely transparent,
; or the entire window, including controls, semi-transparent. This is the only decent solution I have
; found. It does have some issues (see readme) but nothing major.) The background window is set to be
; the owner of the real window, to avoid it being selectable which would push the background over the
; other window. Even if the background is completely transparent, the background window is still created,
; because otherwise clicks would fall through (this only happens if a specific colour is made transparent
; as is the case for the real window, it doesn't happen if the entire window is made completely transparent
; as is the case for the background window.)
If Transparency < 255
{
	WinGetPos,,, OutputWindowNoCaptionWidth, OutputWindowNoCaptionHeight
	gui, 1:Show, Autosize
	WinGetPos, OutputWindowX, OutputWindowY, OutputWindowWidth, OutputWindowHeight
	BackgroundX := OutputWindowX+OutputWindowWidth-OutputWindowNoCaptionWidth
	BackgroundY := OutputWindowY+OutputWindowHeight-OutputWindowNoCaptionHeight
	gui 6: +LastFound
	gui, 6:Color, %BackColour%, %BackColour%
	Winset, Transparent, %Transparency%
	gui 6: -Caption
	Gui, 6: Show, x%BackgroundX% y%BackgroundY% w%OutputWindowNoCaptionWidth% h%OutputWindowNoCaptionHeight% NoActivate
	gui 1: +Owner6
}
; Proceed to the MainScript, which is where the output is updated. Since we don't want to start the
; MainScript after changing the output (since it will be running already), we check for that. If the
; MainScript would be launched every time, we would quickly reach the maximum number of simultaneous
; threads causing the whole program to become unresponsive. Not to mention the memory leaking from having
; a lot of threads running.
if OutputChanged != 1
	goto MainScript
else
	exit


GuiClose:
GuiEscape:
CurrentGUI = 1
exitapp
return

; The following items are added to the right click menu.
GuiContextMenu:
Menu, OutputRightClick, Add, Restart Script, RestartSequence
Menu, OutputRightClick, Add, Open Readme, OpenReadme
Menu, OutputRightClick, Add, Exit, GuiClose
Menu, OutputRightClick, Show
return

; This function is triggered if the output window is moved, in order to move the 'fake' semi-transparent background with it.
WM_OUTPUTWINDOWPOSCHANGED()
{
	global
	gui 1: +LastFound
	WinGetPos,OutputWindowX, OutputWindowY,
	gui 6: +LastFound
	BackgroundX := OutputWindowX+(OutputWindowWidth-OutputWindowNoCaptionWidth)
	BackgroundY := OutputWindowY+(OutputWindowHeight-OutputWindowNoCaptionHeight)
	WinMove, BackgroundX, BackgroundY
}

; When the user clicks on any of the controls and moves the mouse, this will drag the window with it.
MoveWindow: ; For clicking on controls
if Transparency = 255
	PostMessage, 0xA1, 2,,, A     ; Drag window on click
return

; When the user clicks in the window (but not on the controls) and moves the mouse, this will drag the window with it.
WM_LBUTTONDOWN(wParam, lParam) ; For clicking anywhere else in the window
{
	PostMessage, 0xA1, 2,,, A     ; Drag window on click
}

; Pressing the "Change output type" button will alternate the output between text and icons.
; To accomplish this, it changes the OutputType and then destroys and recreates the output window.
; The position of the window is also saved to be able to draw the recreated output window at the
; same position. Since the image list is potentially shared between multiple list views, it won't
; be destroyed automatically so this is done explicitly.
ButtonChangeOutputType:
If (OutputType = "Text")
	OutputType = Icons
Else If (OutputType = "Icons")
	OutputType = Text
WinGetPos,OutputWindowX, OutputWindowY,
gui 1:Destroy
gui 6:Destroy
IL_Destroy(ImageListID)
OutputChanged = 1
OutputChangedDup = 1
goto OutputWindow
return


; ######################################################################################################
; ############################################ FILE OUTPUT #############################################
; ######################################################################################################

FileOutput:
; MaximumRows := MaximumRows%OutputType% Not supported for now.
FileOutputName := ScriptNameNoExt A_Space "Output.txt"
FileOutputNameTemp := "Temp" A_Space FileOutputName ; Used to reduce the downtime when updating the file as far as possible.
if FileExist(FileOutputName)
	FileDelete, %FileOutputName%
For Index, IconName in %CurrentGame%%SpecialMode%RequirementsArray
{
	Name := %CurrentGame%%SpecialMode%%IconName%.Name
	TotalRequired := %CurrentGame%%SpecialMode%%IconName%.TotalRequired
	; Create the entry in the listview. Check if TotalRequired is defined, if not leave it out.
	TextEntry := Name A_Space "0" ((TotalRequired != "") ? ("`/"TotalRequired) : "" ) "`n"
	FileAppend, %TextEntry%, %FileOutputName%
}
goto MainScript

; ######################################################################################################
; ########################################### UPDATE OUTPUT ############################################
; ######################################################################################################

/*
Subheadings:

	MainScript
	UpdateOutputCode
	ResetOutputCode
*/


MainScript:

; Get the window class and name of the selected game from the array.
WindowClass := GameWindowClassArray[CurrentGame]
WindowName := GameWindowNameArray[CurrentGame]
; Wait until the game window is started. Check both the window class and window title to avoid false positives.
WinWait ahk_class %WindowClass%
WinGetTitle, CurrentWindowName
If (CurrentWindowName != WindowName)
	goto MainScript
; Get the Process Handle of the game for use in memory functions.
; If the process handle cannot be retrieved, try to restart the program
; with admin privileges to see if that fixes the problem.
; If it can still not be retrieved with admin privileges, the program
; cannot function properly so it will shut itself down.
WinGet, PID, PID
ErrorLevel := Memory(1, PID)
If ErrorLevel != 0
{
	If A_IsAdmin = 0
	{
		msgbox Error accessing the game. `nThe program will now try to restart with admin privileges.
		Run *RunAs "%A_ScriptFullPath%"
	}
	Else
	{
		msgbox Error accessing the game. `nThe program cannot continue operating.`n%Error%.
		Error := GetLastErrorMessage()
	}
	ExitConfirmed = 1
	ExitApp
}
; Check if the game is started (which will set the ErrorLevel to !=0),
; then check which version of the current game is used and which offset to use for memory addresses.
Process, Exist, %PID%
If ErrorLevel != 0
	VersionOffset := GameVersionCheck(CurrentGame)
else
	goto MainScript
; Show a tray tip to the user explaining what the program will do next.
Traytip, %ScriptNameNoExt%, The program is now running in the background and will update automatically,20,
; Get which address to check if the game is still running.
GameRunningAddress := GameRunningAddressArray[CurrentGame]
; Reset all the values of the requirements to be sure to start with a clean slate.
; (Why is this necessary?)
ListViewNumber = 1
RowNumber = 0
gosub ResetOutput
; This While-loop will remain active as long as the game is running. The code in it updates the output.
; The loop checks if the output type is changed because it needs to realize that in order to keep
; updating the output.
While Memory(3, GameRunningAddress, 1) != "Fail"
{
	If (OutputType = "File")
		gosub UpdateOutputFile
	Else
	{
		ListViewNumber = 1
		Gui, 1:ListView, RequirementsListView%ListViewNumber%
		RowNumber = 0
		gosub UpdateOutput
	}
	if OutputChangedDup = 1
	{
		OutputChangedDup = 0
		break
	}
	sleep %RefreshRate%
}
; If the while-loop breaks (meaning the game is no longer running), reset the
; output for each requirement. After that return to the start of the 'main script'
; where the program will once again wait until the game is started.
If (OutputType = "File")
	gosub ResetOutputFile
Else
{
	ListViewNumber = 1
	Gui, 1:ListView, RequirementsListView%ListViewNumber%
	RowNumber = 0
	gosub ResetOutput
}
goto MainScript


; Code which updates the output.
UpdateOutput:
For Index, IconName in %CurrentGame%%SpecialMode%RequirementsArray
{
	TotalRequired := %CurrentGame%%SpecialMode%%IconName%.TotalRequired
	Type := %CurrentGame%%SpecialMode%%IconName%.Type
	; The decimal places setting is enforced
	; (Why is this necessary?)
	SetFormat, Float, 0.%DecimalPlaces%
	; sleep 100
	; The current value is reset to stop information from carrying over from the previous requirement.
	CurrentValue = 0
	; Then the row (and listview if required) which will be updated is selected.
	RowNumber += 1
	if RowNumber > %MaximumRows%
	{
		RowNumber = 1
		ListViewNumber += 1
		Gui, 1:ListView, RequirementsListView%ListViewNumber%
	}
	; Loop to read all the memory addresses belonging to the current requirement.
	; Get the address, length and customcode flags from the requirements array.
	; If type is set, the read value can be converted to a float and custom code
	; located in the requirement list can be executed. At the end of the loop,
	; The variable 'CurrentValue' contains the finalized value of the requirement.
	Loop
	{
		ReadAddress := %CurrentGame%%SpecialMode%%IconName%["Address"A_Index]
		if ReadAddress = 
			break
		ReadLength := %CurrentGame%%SpecialMode%%IconName%["AddressLength"A_Index]
		MemoryValue := Memory(3, ReadAddress+VersionOffset, ReadLength)
		if Type = Float
			MemoryValue := HexToFloat(MemoryValue)
		if (%CurrentGame%%SpecialMode%%IconName%["AddressCustomCode"A_Index] = 1)
			gosub %IconName%Address%A_Index%CustomCode
		CurrentValue += %MemoryValue%
	}
	; Only update the output if the value found in this cycle is not the same as
	; the value found in the last cycle.
	if (CurrentValue != %IconName%ValueOld)
	{
		/*
		; Test to remove each item once it's done.
		; Issues atm:
		; No way to re-add items when reloading a save/starting a new game.
		; Items after a deleted entry are no longer updated.
		if (CurrentValue >= TotalRequired AND TotalRequired != "")
		{
			LV_Delete(RowNumber)
			RequirementsArrayClone := %CurrentGame%%SpecialMode%RequirementsArray.Clone()
			%CurrentGame%%SpecialMode%RequirementsArray.Remove(Index)
			ItemsRemoved = 1
			continue
		}
		*/
		; Store the value found this cycle to compare the next cycle against.
		%IconName%ValueOld := CurrentValue
		; When the requirement is done and the 'show DONE if done' option is selected,
		; write 'DONE' to the requirement and skip the rest of this cycle.
		if (CurrentValue >= TotalRequired AND TotalRequired != "" AND ShowDoneIfDone = 1)
		{
			if (OutputType = "Icons")
				LV_Modify(RowNumber,"Col1", "DONE")
			Else If (OutputType = "Text")
			{
				LV_Modify(RowNumber,"Col2", "DONE")
				LV_Modify(RowNumber,"Col3", "")
				LV_ModifyCol()
			}
			continue
		}
		; If a total required is defined, check if the value is higher and
		; enforce it as a maximum in necessary.
		if (CurrentValue > TotalRequired AND TotalRequired != "")
			CurrentValue := TotalRequired
		; Update the output, with slightly different code depending on the
		; output type and if a total required has been defined.
		If (OutputType = "Icons")
		{
			UpdatedColumnContents := ((TotalRequired != "") ? (CurrentValue "`/" TotalRequired) : (CurrentValue) )
			LV_Modify(RowNumber,"Col1", UpdatedColumnContents)
			UpdatedValueLengthChar := StrLen(UpdatedColumnContents)
		}
		Else If (OutputType = "Text")
		{
			LV_Modify(RowNumber,"Col2", CurrentValue)
			UpdatedValueLengthChar := StrLen(CurrentValue)
		}
		; Check the length of the new value and make the output wider if it's too small.
		UpdatedValueLengthInPixels := UpdatedValueLengthChar*7+12
		if (UpdatedValueLengthInPixels > MaxValueLengthInPixels%ListViewNumber%)
		{
			If (OutputType = "Text")
				LV_ModifyCol(2,UpdatedValueLengthInPixels)
			/*
			Else If (OutputType = "Icons")
			{
				UpdatedValueLengthInPixels := UpdatedValueLengthInPixels+32
				GuiControlGet, RequirementsListView%ListViewNumber%Pos, Pos, RequirementsListView%ListViewNumber%
				Guicontrol, Move, RequirementsListView%ListViewNumber%, w%UpdatedValueLengthInPixels%
				LV_ModifyCol(1,UpdatedValueLengthInPixels)
				UpdatedValueLengthInPixels := UpdatedValueLengthInPixels-32
			}
			*/
			MaxValueLengthInPixels%ListViewNumber% := UpdatedValueLengthInPixels
		}
	}
}
return

; For each requirement in the requirements array, set the value in the listview(s) back to
; 0 or 0/TotalRequired, whichever applies. At the start of every requirement, check if the
; current row exceeds the maximum length and jump to the next list view in necessary.
ResetOutput:
For Index, IconName in %CurrentGame%%SpecialMode%RequirementsArray
{
	TotalRequired := %CurrentGame%%SpecialMode%%IconName%.TotalRequired
	RowNumber += 1
	%IconName%ValueOld = 0
	If RowNumber > %MaximumRows%
	{
		RowNumber = 1
		ListViewNumber += 1
		Gui, 1:ListView, RequirementsListView%ListViewNumber%
	}
	If (OutputType = "Icons")
		LV_Modify(RowNumber,"Col1", ((TotalRequired != "") ? ("0`/"TotalRequired) : 0 ))
	Else If (OutputType = "Text")
		LV_Modify(RowNumber,"Col2", 0)
}
return

UpdateOutputFile:
if FileExist(FileOutputNameTemp)
	FileDelete, %FileOutputNameTemp%
For Index, IconName in %CurrentGame%%SpecialMode%RequirementsArray
{
	Name := %CurrentGame%%SpecialMode%%IconName%.Name
	TotalRequired := %CurrentGame%%SpecialMode%%IconName%.TotalRequired
	Type := %CurrentGame%%SpecialMode%%IconName%.Type
	; The current value is reset to stop information from carrying over from the previous requirement.
	CurrentValue = 0
	; Loop to read all the memory addresses belonging to the current requirement.
	; Get the address, length and customcode flags from the requirements array.
	; If type is set, the read value can be converted to a float and custom code
	; located in the requirement list can be executed. At the end of the loop,
	; The variable 'CurrentValue' contains the finalized value of the requirement.
	Loop
	{
		ReadAddress := %CurrentGame%%SpecialMode%%IconName%["Address"A_Index]
		if ReadAddress = 
			break
		ReadLength := %CurrentGame%%SpecialMode%%IconName%["AddressLength"A_Index]
		MemoryValue := Memory(3, ReadAddress+VersionOffset, ReadLength)
		if Type = Float
			MemoryValue := HexToFloat(MemoryValue)
		if (%CurrentGame%%SpecialMode%%IconName%["AddressCustomCode"A_Index] = 1)
			gosub %IconName%Address%A_Index%CustomCode
		CurrentValue += %MemoryValue%
	}
	; When the requirement is done and the 'show DONE if done' option is selected,
	; write 'DONE' to the requirement. Else, enforce the TotalRequired as a maximum for CurrentValue
	if (CurrentValue >= TotalRequired AND TotalRequired != "")
	{
		if (ShowDoneIfDone = 1)
			TextEntry := Name A_Space "DONE" "`n"
		Else
			TextEntry := Name A_Space TotalRequired "`/" TotalRequired "`n"
	}
	Else
		TextEntry := Name A_Space CurrentValue  ((TotalRequired != "") ? ("`/"TotalRequired) : "" ) "`n"
	FileAppend, %TextEntry%, %FileOutputNameTemp%
}
if FileExist(FileOutputNameTemp)
	FileMove, %FileOutputNameTemp%, %FileOutputName%, 1 ; Move the temp file to the original file output, overwriting the old file.
Else
	msgbox Error`: Updated output file unavailable`.
sleep %RefreshRateFileOutput% ; Updating the file is quite a resource hog, so we don't want to do it too often.
return


ResetOutputFile:
if FileExist(FileOutputName)
	FileDelete, %FileOutputName%
if FileExist(FileOutputNameTemp)
	FileDelete, %FileOutputNameTemp%
For Index, IconName in %CurrentGame%%SpecialMode%RequirementsArray
{
	Name := %CurrentGame%%SpecialMode%%IconName%.Name
	TotalRequired := %CurrentGame%%SpecialMode%%IconName%.TotalRequired
	; Create the entry in the listview. Check if TotalRequired is defined, if not leave it out.
	TextEntry := Name " 0" ((TotalRequired != "") ? ("`/"TotalRequired) : "" )
	FileAppend, %TextEntry%, %FileOutputName%
}
return


; ######################################################################################################
; ########################################### RESTART/EXIT SEQUENCE ####################################
; ######################################################################################################

/*
Subheadings:

	RestartSequence
	ExitSequence
	3ButtonYes
	3ButtonNo/3GuiClose/3GuiEscape
*/

; Restart the program.
RestartSequence:
ReloadingScript = 1
reload
sleep 100
return


; If the exit is already confirmed or the script is being reloaded, do that immediately.
; If not, disable the currently active window (which prevents it from being activated)
; and instead create a window asking the user to confirm the exit. This window does not
; follow the settings to make sure it is always readable, even if the user screwed up the
; settings. The only setting which is used here is the text smoothing, since it can't
; mess up the window so far that it is no longer readable.
ExitSequence:
If (ExitConfirmed = 1 or ReloadingScript = 1)
{
	; Delete the icons library if the program is compiled to keep things neat.
	if A_IsCompiled = 1
		FileDelete, Icons.icl
	; If the program is exited mid update loop in file mode, we need to remove the temp file here.
	if FileExist(FileOutputNameTemp)
		FileDelete, %FileOutputNameTemp%
	Exitapp
}
else
{
	if CurrentGUI != 
		gui %CurrentGUI%:+disabled
	gui 3:-MinimizeBox -MaximizeBox +owner%CurrentGUI% +LastFound
	Winset, AlwaysOnTop, On
	if TextSmoothing = 0
		gui, 3:Font, Q3
	Gui, 3:Add, Text,, Are you sure you want to exit the program?
	Gui, 3:Add, Button, Default section, Yes
	Gui, 3:Add, Button, ys, No
	gui, 3:show,,
	return
}

; If the user confirms the exit, exit.
3ButtonYes:
ExitConfirmed = 1
ExitApp

; If the user cancels the exit, restore the previous window and destroy the exit confirmation window.
3ButtonNo:
3GuiClose:
3GuiEscape:
if CurrentGUI != 
	gui %CurrentGUI%:-disabled
gui, 3:destroy
return



; ######################################################################################################
; ########################################### REQUIREMENT LISTS ########################################
; ######################################################################################################

/*
Supported games list:

GTA: Vice City
GTA: San Andreas
GTA 3

*/


; ######################################################################################################
; ########################################### GTA: Vice City ###########################################
; ######################################################################################################

/*
Subheadings:

	GTAVCPercentageOnly
	GTAVCRequirements
*/
/*

*/

GTAVCPercentageOnlyRequirements:
Name = Percentage Completed
Type = Float
IconName = Percentage
Address1 := 0x00821418 ; Float, so needs conversion
gosub %CurrentLoopCode%
return

GTAVCRequirements:
Name = Percentage Completed
Type = Float
IconName = Percentage
Address1 := 0x00821418 ; Float, so needs conversion
gosub %CurrentLoopCode%
Name = Unique Jumps
IconName = UniqueJump
TotalRequired = 36
Address1 := 0x00821EDC
gosub %CurrentLoopCode%
Name = Hidden Packages
IconName = HiddenPackageVC
TotalRequired = 100
Address1 := 0x008226E8
gosub %CurrentLoopCode%
Name = Rampages
IconName = RampageVC
TotalRequired = 35
Address1 := 0x0082286C
gosub %CurrentLoopCode%
Name = Robberies
IconName = Robbery
TotalRequired = 15
Address1 := 0x00822A6C
gosub %CurrentLoopCode%
Name = Safehouses
IconName = Safehouse
TotalRequired = 7
Address1 := 0x008226CC ; Skumole Shack
Address2 := 0x008226D0 ; Hyman Condo
Address3 := 0x008226D4 ; Washington Street
Address4 := 0x008226D8 ; Vice Point
Address5 := 0x008226DC ; El Swanko Casa
Address6 := 0x008226E0 ; Links View
Address7 := 0x008226E4 ; Ocean Heights
gosub %CurrentLoopCode%
Name = Top Fun Missions
IconName = TopFun
TotalRequired = 3
Address1CustomCode = 1
Address2CustomCode = 1
Address3CustomCode = 1
Address1 := 0x008291F0 ; RC Raider
Address2 := 0x00829344 ; RC Bandit
Address3 := 0x00829714 ; RC Baron
gosub %CurrentLoopCode%
Name = Vehicle Challenges
IconName = VehicleChallenge
TotalRequired = 4
Address1 := 0x008217CC ; PCJ Playground
Address2 := 0x008217FC ; Cone Crazy
Address3 := 0x0082182C ; Trial By Dirt
Address4 := 0x00821830 ; Test Track
gosub %CurrentLoopCode%
Name = Vigilante
IconName = Vigilante
TotalRequired = 1
Address1 := 0x00822B38
gosub %CurrentLoopCode%
Name = Firefighter
IconName = Firefighter
TotalRequired = 1
Address1 := 0x00822B3C
gosub %CurrentLoopCode%
Name = Paramedic
IconName = Paramedic
TotalRequired = 1
Address1 := 0x00822B34
gosub %CurrentLoopCode%
Name = Pizza Delivery
IconName = PizzaDelivery
TotalRequired = 1
Address1 := 0x00821894
gosub %CurrentLoopCode%
Name = Taxi Fares
IconName = TaxiDriver
TotalRequired = 100
Address1 := 0x00821844
gosub %CurrentLoopCode%
Name = Chopper Checkpoints
IconName = ChopperCheckpoint
TotalRequired = 4
Address1 := 0x00822B40 ; Downtown
Address2 := 0x00822B44 ; Ocean Beach
Address3 := 0x00822B48 ; Vice Point
Address4 := 0x00822B4C ; Little Haiti
gosub %CurrentLoopCode%
Name = Stadium Events
IconName = StadiumEvent
TotalRequired = 3
Address1 := 0x00822B74 ; Hotring
Address2 := 0x00822B78 ; Bloodring
Address3 := 0x0082135C ; Dirtring
gosub %CurrentLoopCode%
Name = Shooting Range
IconName = ShootingRange
TotalRequired = 1
Address1 := 0x00821430
gosub %CurrentLoopCode%
Name = Street Races
IconName = StreetRace
TotalRequired = 6
Address1 := 0x00822B50 ; Terminal Velocity
Address2 := 0x00822B54 ; Ocean Drive
Address3 := 0x00822B58 ; Border Run
Address4 := 0x00822B5C ; Capital Cruise
Address5 := 0x00822B60 ; Tour
Address6 := 0x00822B64 ; VC Endurance
gosub %CurrentLoopCode%
Name = Lawyer
IconName = Lawyer
TotalRequired = 4
Address1 := 0x00821600 ; The Party
Address2 := 0x00821604 ; Back Alley Brawl
Address3 := 0x00821608 ; Jury Fury
Address4 := 0x0082160C ; Riot
gosub %CurrentLoopCode%
Name = Kent Paul
IconName = KentPaul
TotalRequired = 1
Address1 := 0x00821648 ; Death Row
gosub %CurrentLoopCode%
Name = Diaz
IconName = Diaz
TotalRequired = 5
Address1 := 0x0082162C ; The Chase
Address2 := 0x00821630 ; Phnom Penh '86
Address3 := 0x00821634 ; The Fastest Boat
Address4 := 0x00821638 ; Supply And Demand
Address5 := 0x0082163C ; Rub Out
gosub %CurrentLoopCode%
Name = Vercetti
IconName = Vercetti
TotalRequired = 5
Address1 := 0x008216A8 ; Shakedown
Address2 := 0x008216AC ; Bar Brawl
Address3 := 0x008216B0 ; Cop Land
Address4 := 0x008216B4 ; Cap The Collector
Address5 := 0x008216B8 ; Keep Your Friends Close
gosub %CurrentLoopCode%
Name = Avery
IconName = Avery
TotalRequired = 3
Address1 := 0x00821650 ; Four Iron
Address2 := 0x00821654 ; Demolition Man
Address3 := 0x00821658 ; Two Bit Hit
gosub %CurrentLoopCode%
Name = Umberto Robina
IconName = UmbertoRobina
TotalRequired = 4
Address1 := 0x008216DC ; Stunt Boat Challenge
Address2 := 0x008216E0 ; Cannon Fodder
Address3 := 0x008216E4 ; Naval Engagement
Address4 := 0x008216E8 ; Trojan Voodoo
gosub %CurrentLoopCode%
Name = Auntie Poulet
IconName = AuntiePoulet
TotalRequired = 3
Address1 := 0x008216F0 ; Juju Scramble
Address2 := 0x008216F4 ; Bombs Away
Address3 := 0x008216F8 ; Dirty Lickin's
gosub %CurrentLoopCode%
Name = Love Fist
IconName = LoveFist
TotalRequired = 3
Address1 := 0x00821700 ; Love Juice
Address2 := 0x00821704 ; Psycho Killer
Address3 := 0x00821708 ; Publicity Tour
gosub %CurrentLoopCode%
Name = Mitch Baker
IconName = MitchBaker
TotalRequired = 3
Address1 := 0x008216CC ; Alloy Wheels Of Steel
Address2 := 0x008216D0 ; Messing With The Man
Address3 := 0x008216D4 ; Hog Tied
gosub %CurrentLoopCode%
Name = Phil Cassidy
IconName = PhilCassidy
TotalRequired = 2
Address1 := 0x00821678 ; Gun Runner
Address2 := 0x0082167C ; Boomshine Saigon
gosub %CurrentLoopCode%
Name = Colonel Cortez
IconName = ColonelCortez
TotalRequired = 5
Address1 := 0x00821614 ; Treacherous Swine
Address2 := 0x00821618 ; Mall Shootout
Address3 := 0x0082161C ; Guardian Angels
Address4 := 0x00821620 ; Sir Yes Sir
Address5 := 0x00821624 ; All Hands On Deck
gosub %CurrentLoopCode%
Name = Payphone Assassinations
IconName = PayphoneAssassination
TotalRequired = 5
Address1 := 0x00821728 ; Road Kill
Address2 := 0x0082172C ; Waste The Wife
Address3 := 0x00821730 ; Autocide
Address4 := 0x00821734 ; Check Out At The Check In
Address5 := 0x00821738 ; Loose Ends
gosub %CurrentLoopCode%
Name = Interglobal Films
IconName = InterglobalFilms
TotalRequired = 4
Address1 := 0x00821684 ; Recruitment Drive
Address2 := 0x00821688 ; Dildo Dodo
Address3 := 0x0082168C ; Martha's Mug Shot
Address4 := 0x00821690 ; G-Spotlight
gosub %CurrentLoopCode%
Name = Kaufman Cabs
IconName = KaufmanCabs
TotalRequired = 3
Address1 := 0x00821750 ; VIP
Address2 := 0x00821754 ; Friendly Rivalry
Address3 := 0x00821758 ; Cabmaggedon
gosub %CurrentLoopCode%
Name = Pole Position
IconName = PolePosition
TotalRequired = 1
Address1 := 0x008223A0
gosub %CurrentLoopCode%
Name = Cherry Poppers
IconName = CherryPoppers
TotalRequired = 1
Address1 := 0x00821C10
gosub %CurrentLoopCode%
Name = Sunshine Autos Import Garage
IconName = SunshineAutos
TotalRequired = 4
Address1 := 0x00822414 ; List 1
Address2 := 0x00822418 ; List 2
Address3 := 0x0082241C ; List 3
Address4 := 0x00822420 ; List 4
gosub %CurrentLoopCode%
Name = Boatyard
IconName = Boatyard
TotalRequired = 1
Address1 := 0x00821BFC
gosub %CurrentLoopCode%
Name = Printworks
IconName = Printworks
TotalRequired = 2
Address1 := 0x008216C0 ; Spilling The Beans
Address2 := 0x008216C4 ; Hit The Courier
gosub %CurrentLoopCode%
Name = Malibu Club
IconName = MalibuClub
TotalRequired = 4
Address1 := 0x00821660 ; No Escape
Address2 := 0x00821664 ; The Shootist
Address3 := 0x00821668 ; The Driver
Address4 := 0x0082166C ; The Job
gosub %CurrentLoopCode%
return


TopFunAddress1CustomCode:
TopFunAddress2CustomCode:
TopFunAddress3CustomCode:
if VersionOffset = -0x2FF8 ; Game is version JP
{
	; This fixes the offset for the JP version for these addresses.
	MemoryValue := Memory(3, ReadAddress+VersionOffset + 8, ReadLength)
}
return


; ######################################################################################################
; ########################################### GTA: San Andreas #########################################
; ######################################################################################################

/*
Subheadings:

	GTASAPercentageOnly
	GTASARequirements
	Custom Codes:
		CesarVialpandoAddress3CustomCode
		RyderAddress2CustomCode/CrashAddress3CustomCode
		SweetAddress4CustomCode
		CJAddress1CustomCode/CJAddress3CustomCode/CJAddress5CustomCode/YellowDragonAddress2CustomCode
		YellowDragonAddress1CustomCode
		DrivingSchoolAddress1-12CustomCode/FlightSchoolAddress1-10CustomCode
		RedDragonAddress1CustomCode
		CJAddress4CustomCode
		JizzyAddress1CustomCode
		CasinoAddress1CustomCode/AirstripAddress1CustomCode
		ImportExportAddress1CustomCode
		QuarryAddress1CustomCode
		ChiliadChallengeAddress1CustomCode
		SafehouseAddress1CustomCode
		SafehouseAddress32CustomCode
*/


GTASAPercentageOnlyRequirements:
Name = Percentage Completed
Type = Float
Address1 := 0x00A4A61C ; Float, so needs conversion
gosub %CurrentLoopCode%
return

GTASARequirements:
Name = Percentage Completed
Type = Float
IconName = Percentage
Address1 := 0x00A4A61C ; Float, so needs conversion
gosub %CurrentLoopCode%
Name = Tags
IconName = SprayPaint
TotalRequired = 100
Address1 := 0x00A4A5E4
gosub %CurrentLoopCode%
Name = Photo Ops
IconName = Camera
TotalRequired = 50
Address1 := 0x00A4A5E0
gosub %CurrentLoopCode%
Name = Horseshoes
IconName = Horseshoe
TotalRequired = 50
Address1 := 0x00A4A5DC
gosub %CurrentLoopCode%
Name = Oysters
IconName = Oyster
TotalRequired = 50
Address1 := 0x00A4A5D8
gosub %CurrentLoopCode%
Name = Properties
IconName = Safehouse
TotalRequired = 32
Address1 := 0x00A49A6A ; Wang Cars
Address1Length = 1
Address1CustomCode = 1
Address2 := 0x00A4B2B0 ; Zero's RC Shop
Address3 := 0x00A4A4CC ; Santa Maria Beach
Address4 := 0x00A4A4D0 ; Rockshore West
Address5 := 0x00A4A4D4 ; Fort Carson
Address6 := 0x00A4A4D8 ; Prickle Pine
Address7 := 0x00A4A4DC ; Whitewood Estate
Address8 := 0x00A4A4E0 ; Palomino Creek
Address9 := 0x00A4A4E4 ; Redsands West
Address10 := 0x00A4A4E8 ; El Corona
Address11 := 0x00A4A4EC ; Calton Heights
Address12 := 0x00A4A4F0 ; Mulholland
Address13 := 0x00A4A4F4 ; Paradiso
Address14 := 0x00A4A4F8 ; Hashbury
Address15 := 0x00A4A4FC ; Verona Beach
Address16 := 0x00A4A500 ; Pirates In Men's Pants
Address17 := 0x00A4A504 ; The Camel's Toe
Address18 := 0x00A4A508 ; Chinatown
Address19 := 0x00A4A50C ; Whetstone
Address20 := 0x00A4A510 ; Doherty
Address21 := 0x00A4A514 ; Queens
Address22 := 0x00A4A518 ; Angel Pine
Address23 := 0x00A4A51C ; El Quebrados
Address24 := 0x00A4A520 ; Tierra Robada
Address25 := 0x00A4A524 ; Dillimore
Address26 := 0x00A4A528 ; Jefferson
Address27 := 0x00A4A52C ; Old Venturas Strip
Address28 := 0x00A4A530 ; The Clown's Pocket
Address29 := 0x00A4A534 ; Creek
Address30 := 0x00A4A538 ; Willowfield
Address31 := 0x00A4A53C ; Blueberry
Address32 := 0x00A4A2A4 ; Toreno Missions Completed: (Monster included but not counted) (| Highjack included but not counted) (| Interdiction included but not counted)| Verdant Meadows (| Learning To Fly included but not counted) (| N.O.E. included but not counted) (| Stowaway included but not counted) (| Black Project included but not counted) (| Green Goo included but not counted)
Address32CustomCode = 1
gosub %CurrentLoopCode%
Name = Chiliad Challenge
IconName = ChiliadChallenge
TotalRequired = 3
Address1 := 0x00A4B584
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Stunt Challenges
IconName = MotorcycleHelmet
TotalRequired = 2
Address1 := 0x00A4C50C ; BMX
Address2 := 0x00A4C510 ; NRG-500
gosub %CurrentLoopCode%
Name = Taxi Driver
IconName = TaxiDriver
TotalRequired = 50
Address1 := 0x00A49C30
gosub %CurrentLoopCode%
Name = Paramedic
IconName = Paramedic
TotalRequired = 1
Address1 := 0x00A4B09C
gosub %CurrentLoopCode%
Name = Firefighter
IconName = Firefighter
TotalRequired = 1
Address1 := 0x00A4B0A4
gosub %CurrentLoopCode%
Name = Vigilante
IconName = Vigilante
TotalRequired = 1
Address1 := 0x00A4B0A0
gosub %CurrentLoopCode%
Name = Freight Train
IconName = Train
TotalRequired = 2
Address1 := 0x00A51A20 ; Level 1 completed
Address2 := 0x00A51A1C ; Level 2 completed
gosub %CurrentLoopCode%
Name = Courier
IconName = ShoppingBasket
TotalRequired = 3
Address1 := 0x00A4B884 ; Los Santos
Address2 := 0x00A4B888 ; San Fierro
Address3 := 0x00A4B880 ; Las Venturas
gosub %CurrentLoopCode%
Name = Pimping
IconName = Pimping
TotalRequired = 1
Address1 := 0x00A4B87C
gosub %CurrentLoopCode%
Name = Valet
IconName = Valet
TotalRequired = 1
Address1 := 0x00A4B710
gosub %CurrentLoopCode%
Name = Trucking
IconName = Trucking
TotalRequired = 8
Address1 := 0x00A518DC
gosub %CurrentLoopCode%
Name = Quarry
IconName = Quarry
TotalRequired = 7
Address1 := 0x00A5190C
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Export
IconName = ImportExport
TotalRequired = 30
Address1 := 0x00A4A9C4 ; Amount of lists completed, doesn't count the last list.
Address1CustomCode = 1
Address2 := 0x00A4A9F0 ; Car 1 of current list delivered
Address3 := 0x00A4A9F4 ; Car 2 of current list delivered
Address4 := 0x00A4A9F8 ; Car 3 of current list delivered
Address5 := 0x00A4A9FC ; Car 4 of current list delivered
Address6 := 0x00A4AA00 ; Car 5 of current list delivered
Address7 := 0x00A4AA04 ; Car 6 of current list delivered
Address8 := 0x00A4AA08 ; Car 7 of current list delivered
Address9 := 0x00A4AA0C ; Car 8 of current list delivered
Address10 := 0x00A4AA10 ; Car 9 of current list delivered
Address11 := 0x00A4AA14 ; Car 10 of current list delivered
gosub %CurrentLoopCode%
Name = Stadium Events
IconName = StadiumEvent
TotalRequired = 4
Address1 := 0x00A4B7B4 ; Blood Ring
Address2 := 0x00A49AC8 ; Kickstart
Address3 := 0x00A4BDB4 ; 8-Track
Address4 := 0x00A4BDB8 ; Dirt Track
gosub %CurrentLoopCode%
Name = Gym Moves
IconName = Dumbbell
TotalRequired = 3
Address1 := 0x00A518C4 ; Los Santos Gym
Address2 := 0x00A518C8 ; San Fierro Gym
Address3 := 0x00A518D8 ; Las Venturas Gym
gosub %CurrentLoopCode%
Name = Shooting Range
IconName = ShootingRange
TotalRequired = 1
Address1 := 0x00A4EBC0
gosub %CurrentLoopCode%
Name = Driving School
IconName = DrivingSchool
TotalRequired = 12
Address1 := 0x00A49B0C ; The '360' score
Address1CustomCode = 1
Address2 := 0x00A49B04 ; The '180' score
Address2CustomCode = 1
Address3 := 0x00A49AE8 ; Whip and Terminate score
Address3CustomCode = 1
Address4 := 0x00A49AE0 ; Pop and Control score
Address4CustomCode = 1
Address5 := 0x00A49AD8 ; Burn and Lap score
Address5CustomCode = 1
Address6 := 0x00A49AFC ; Cone Coil score
Address6CustomCode = 1
Address7 := 0x00A49ACC ; The '90' score
Address7CustomCode = 1
Address8 := 0x00A49AF4 ; Wheelie Weave score
Address8CustomCode = 1
Address9 := 0x00A49AD0 ; Spin and Go score
Address9CustomCode = 1
Address10 := 0x00A49AF8 ; P.I.T. Maneuver score
Address10CustomCode = 1
Address11 := 0x00A49AF0 ; Alley Oop score
Address11CustomCode = 1
Address12 := 0x00A49AE4 ; City Slicking score
Address12CustomCode = 1
gosub %CurrentLoopCode%
Name = Flight School
IconName = FlightSchool
TotalRequired = 10
Address1 := 0x00A4B7B8 ; Takeoff score
Address1CustomCode = 1
Address2 := 0x00A4B7BC ; Land plane score
Address2CustomCode = 1
Address3 := 0x00A4B7C0 ; Circle airstrip score
Address3CustomCode = 1
Address4 := 0x00A4B7C4 ; Circle airstrip and land score
Address4CustomCode = 1
Address5 := 0x00A4B7C8 ; Helicopter takeoff score
Address5CustomCode = 1
Address6 := 0x00A4B7CC ; Land helicopter score
Address6CustomCode = 1
Address7 := 0x00A4B7D0 ; Destroy targets score
Address7CustomCode = 1
Address8 := 0x00A4B7D4 ; Loop-the-loop score
Address8CustomCode = 1
Address9 := 0x00A4B7D8 ; Barrel roll score
Address9CustomCode = 1
Address10 := 0x00A4B7DC ; Parachute onto target score
Address10CustomCode = 1
gosub %CurrentLoopCode%
Name = Boat School
IconName = BoatSchool
TotalRequired = 5
Address1 := 0x00A4B828 ; Basic Seamanship >=bronze
Address2 := 0x00A4B834 ; Plot a Course >=bronze
Address3 := 0x00A4B840 ; Fresh Slalom >=bronze
Address4 := 0x00A4B84C ; Flying Fish >=bronze
Address5 := 0x00A4B858 ; Land, Sea and Air >=bronze
gosub %CurrentLoopCode%
Name = Bike School
IconName = BikeSchool
TotalRequired = 6
Address1 := 0x00A4BB4C ; The 360 >=bronze
Address2 := 0x00A4BB58 ; The 180 >=bronze
Address3 := 0x00A4BB64 ; The Wheelie >=bronze
Address4 := 0x00A4BB70 ; Jump and Stop >=bronze
Address5 := 0x00A4BB7C ; The Stoppie >=bronze
Address6 := 0x00A4BB88 ; Jump & Stoppie >=bronze
gosub %CurrentLoopCode%
Name = Races
IconName = StreetRace
TotalRequired = 22
Address1 := 0x00A4BD54 ; Little Loop
Address2 := 0x00A4BD58 ; Backroad Wanderer
Address3 := 0x00A4BD5C ; City Circuit
Address4 := 0x00A4BD60 ; Vinewood
Address5 := 0x00A4BD64 ; Freeway
Address6 := 0x00A4BD68 ; Into the Country
Address7 := 0x00A4BD74 ; Dirtbike Danger
Address8 := 0x00A4BD78 ; Bandito County
Address9 := 0x00A4BD7C ; Go-Go Karting
Address10 := 0x00A4BD80 ; San Fierro Fastlane
Address11 := 0x00A4BD84 ; San Fierro Hills
Address12 := 0x00A4BD88 ; Country Endurance
Address13 := 0x00A4BD8C ; SF to LV
Address14 := 0x00A4BD90 ; Dam Rider
Address15 := 0x00A4BD94 ; Desert Tricks
Address16 := 0x00A4BD98 ; LV Ringroad
Address17 := 0x00A4BD9C ; World War Ace
Address18 := 0x00A4BDA0 ; Barnstorming
Address19 := 0x00A4BDA4 ; Military Service
Address20 := 0x00A4BDA8 ; Chopper Checkpoint
Address21 := 0x00A4BDAC ; Whirly Bird Waypoint
Address22 := 0x00A4BDB0 ; Heli Hell
gosub %CurrentLoopCode%
Name = CJ
IconName = CJ
TotalRequired = 8
Address1 := 0x00A4A060 ; Intro Missions Completed: Big Smoke (| Ryder included but not counted)
Address1CustomCode = 1
Address2 := 0x00A4A1D4 ; Garage Missions Completed: Wear Flowers in your Hair | Deconstruction
Address3 := 0x00A4A1E8 ; CRASH SF Missions Completed: 555 WE TIP (| Snail Trail included but not counted)
Address3CustomCode = 1
Address4 := 0x00A4A328 ; Mansion Missions Completed: (A Home In The Hills included but not counted) | Vertical Bird | Home Coming | Cut Throat Business
Address4CustomCode = 1
Address5 := 0x00A4A334 ; Riot Missions Completed: Riot (| Los Desperados included but not counted) (| End Of The Line (1) included but not counted) (| End Of The Line (2) included but not counted) (| End Of The Line (3) included but not counted)
Address5CustomCode = 1
gosub %CurrentLoopCode%
Name = Sweet
IconName = Sweet
TotalRequired = 15
Address1 := 0x00A4A070 ; Sweet Missions Completed: Tagging up Turf | Cleaning the Hood | Drive-thru | Nines and AK's | Drive-By | Sweet's Girl | Cesar Vialpando | Doberman | Los Sepulcros
Address2 := 0x00A4A088 ; LS FINAL Missions Completed: Reuniting The Families | The Green Sabre
Address3 := 0x00A4A32C ; Grove Missions Completed: Beat Down on B Dup | Grove 4 Life
Address4 := 0x00A4A334 ; Riot Missions Completed: (Riot included but not counted) | Los Desperados (| End Of The Line (1) included but not counted) (| End Of The Line (2) included but not counted) | End Of The Line (3)
Address4CustomCode = 1
gosub %CurrentLoopCode%
Name = Ryder
IconName = Ryder
TotalRequired = 4
Address1 := 0x00A4A074 ; Ryder Missions Completed: Home Invasion | Catalyst | Robbing Uncle Sam
Address2 := 0x00A4A060 ; Intro Missions Completed: (Big Smoke included but not counted) | Ryder
Address2CustomCode = 1
gosub %CurrentLoopCode%
Name = Big Smoke
IconName = BigSmoke
TotalRequired = 4
Address1 := 0x00A4A078 ; Smoke Missions Completed: OG Loc | Running Dog | Wrong Side of the Tracks | Just Business
gosub %CurrentLoopCode%
Name = OG Loc
IconName = OGLoc
TotalRequired = 5
Address1 := 0x00A4A07C ; OG Loc Missions Completed: Life's a Beach | Madd Dogg's Rhymes | Management Issues | House Party (cutscene) | House Party
gosub %CurrentLoopCode%
Name = C.R.A.S.H.
IconName = Crash
TotalRequired = 6
Address1 := 0x00A4A080 ; CRASH LS Missions Completed: Burning Desire | Gray Imports
Address2 := 0x00A4A114 ; CRASH Countryside Missions Completed: Badlands
Address3 := 0x00A4A1E8 ; CRASH SF Missions Completed: (555 WE TIP included but not counted) | Snail Trail
Address4 := 0x00A4A2B8 ; CRASH LV Missions Completed: Misappropriation | High Noon
Address3CustomCode = 1
gosub %CurrentLoopCode%
Name = Cesar Vialpando
IconName = CesarVialpando
TotalRequired = 8
Address1 := 0x00A4A084 ; Cesar Missions Completed: Lowrider (High Stakes)
Address2 := 0x00A4BB2C ; King In Exile
Address3 := 0x00A4A110 ; Something to do with Wu Zi Mu and Farewell My Love
Address3CustomCode = 1
Address4 := 0x00A4A1E0 ; Steal Missions Completed: Zeroing In | Test Drive | Customs Fast Track | Puncture Wounds
gosub %CurrentLoopCode%
Name = Catalina
IconName = CatalinaSA
TotalRequired = 4
Address1 := 0x00A49A60 ; Catalina Missions Completed: First Date | First Base | Gone Courting | Made In Heaven (| Wu Zi Mu included but not counted)
gosub %CurrentLoopCode%
Name = The Truth
IconName = TheTruth
TotalRequired = 2
Address1 := 0x00A4A10C ; Truth Missions Completed: Body Harvest | Are you going to San Fierro?
gosub %CurrentLoopCode%
Name = Zero
IconName = Zero
TotalRequired = 3
Address1 := 0x00A4A1D8 ; Zero Missions Completed: Air Raid | Supply Lines... | New Model Army
gosub %CurrentLoopCode%
Name = Wu Zi Mu
IconName = Woozie
TotalRequired = 5
Address1 := 0x00A4A1DC ; Wu Zi Mu Missions Completed: Mountain Boys | Ran Fa Li | Lure | Amphibious Assault | The Da Nang Thang
gosub %CurrentLoopCode%
Name = Syndicate
IconName = RedDragon
TotalRequired = 7
Address1 := 0x00A4A1E4 ; Syndicate Missions Completed: Photo Opportunity | Jizzy (cutscene) (| Jizzy included but not counted) (| T-Bone Mendez included but not counted) (| Mike Toreno included but not counted) | Outrider | Ice Cold Killa | Pier 69 | Toreno's Last Flight | Yay Ka-Boom-Boom
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Jizzy
IconName = Jizzy
TotalRequired = 3
Address1 := 0x00A4A1E4 ; Syndicate Missions Completed: (Photo Opportunity included but not counted) (| Jizzy (cutscene) included but not counted) | Jizzy | T-Bone Mendez | Mike Toreno (| Outrider included but not counted) (| Ice Cold Killa included but not counted) (| Pier 69 included but not counted) (| Toreno's Last Flight included but not counted) (| Yay Ka-Boom-Boom included but not counted)
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Toreno
IconName = Toreno
TotalRequired = 4
Address1 := 0x00A4A2A4 ; Toreno Missions Completed: Monster | Highjack | Interdiction | Verdant Meadows (| Learning To Fly included but not counted) (| N.O.E. included but not counted) (| Stowaway included but not counted) (| Black Project included but not counted) (| Green Goo included but not counted)
gosub %CurrentLoopCode%
Name = Airstrip
IconName = Airstrip
TotalRequired = 4
Address1 := 0x00A4A2A4 ; Toreno Missions Completed: (Monster included but not counted) (| Highjack included but not counted) (| Interdiction included but not counted) (| Verdant Meadows included but not counted) (| Learning To Fly included but not counted) | N.O.E. | Stowaway | Black Project | Green Goo
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Four Dragons Casino
IconName = YellowDragon
TotalRequired = 6
Address1 := 0x00A4A2B4 ; Casino Missions Completed: Fender Ketchup | Explosive Situation | You've had your Chips | Fish in a Barrel | Don Peyote (| Intensive Care included but not counted) (| The Meat Business included but not counted) (| Freefall included but not counted) (| Saint Mark's Bistro included but not counted)
Address1CustomCode = 1
Address2 := 0x00A4A328 ; Mansion Missions Completed: A Home In The Hills (| Vertical Bird included but not counted) (| Home Coming included but not counted) (| Cut Throat Business included but not counted)
Address2CustomCode = 1
gosub %CurrentLoopCode%
Name = Caligula's Palace
IconName = Casino
TotalRequired = 4
Address1 := 0x00A4A2B4 ; Casino Missions Completed: (Fender Ketchup included but not counted) (| Explosive Situation included but not counted) (| You've had your Chips included but not counted) (| Fish in a Barrel included but not counted) (| Don Peyote included but not counted) | Intensive Care | The Meat Business | Freefall | Saint Mark's Bistro
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Madd Dogg
IconName = MaddDogg
TotalRequired = 1
Address1 := 0x00A4A2BC ; Madd Dogg Missions Completed: Madd Dogg
gosub %CurrentLoopCode%
Name = Heist
IconName = Heist
TotalRequired = 6
Address1 := 0x00A4A2C0 ; Heist Missions Completed: Architectural Espionage | Key to her Heart | Dam and Blast | Cop Wheels | Up, Up and Away! | Breaking the Bank at Caligula's
gosub %CurrentLoopCode%
return

CesarVialpandoAddress3CustomCode:
If (MemoryValue = 5)
{
	MemoryValue = 1
	return
}
If MemoryValue = 10
{
	MemoryValue = 2
	return
}
MemoryValue = 0
return

RyderAddress2CustomCode:
CrashAddress3CustomCode:
MemoryValue := ((MemoryValue = 2) ? 1 : 0 )
return

SweetAddress4CustomCode:
if (MemoryValue = 2 or MemoryValue = 3 or MemoryValue = 4)
	MemoryValue = 1
if MemoryValue = 5
	MemoryValue = 2
return

CJAddress1CustomCode:
CJAddress3CustomCode:
CJAddress5CustomCode:
YellowDragonAddress2CustomCode:
if MemoryValue >= 1
	MemoryValue = 1
return

YellowDragonAddress1CustomCode:
if MemoryValue >= 5
	MemoryValue = 5
return

DrivingSchoolAddress1CustomCode:
DrivingSchoolAddress2CustomCode:
DrivingSchoolAddress3CustomCode:
DrivingSchoolAddress4CustomCode:
DrivingSchoolAddress5CustomCode:
DrivingSchoolAddress6CustomCode:
DrivingSchoolAddress7CustomCode:
DrivingSchoolAddress8CustomCode:
DrivingSchoolAddress9CustomCode:
DrivingSchoolAddress10CustomCode:
DrivingSchoolAddress11CustomCode:
DrivingSchoolAddress12CustomCode:
FlightSchoolAddress1CustomCode:
FlightSchoolAddress2CustomCode:
FlightSchoolAddress3CustomCode:
FlightSchoolAddress4CustomCode:
FlightSchoolAddress5CustomCode:
FlightSchoolAddress6CustomCode:
FlightSchoolAddress7CustomCode:
FlightSchoolAddress8CustomCode:
FlightSchoolAddress9CustomCode:
FlightSchoolAddress10CustomCode:
MemoryValue := ((MemoryValue >= 70) ? 1 : 0 )
return

RedDragonAddress1CustomCode:
if (MemoryValue = 3 or MemoryValue = 4 or MemoryValue = 5)
	MemoryValue = 2
if MemoryValue >= 6
	MemoryValue -= 3
return

CJAddress4CustomCode:
MemoryValue := ((MemoryValue <= 1) ? 0 : (MemoryValue - 1) )
return

JizzyAddress1CustomCode:
MemoryValue := ((MemoryValue <= 2) ? 0 : (MemoryValue - 2) )
return

CasinoAddress1CustomCode:
AirstripAddress1CustomCode:
MemoryValue := ((MemoryValue <= 5) ? 0 : (MemoryValue - 5) )
return

ImportExportAddress1CustomCode:
MemoryValue := MemoryValue*10
return

QuarryAddress1CustomCode:
if (MemoryValue = 0) and (Memory(3, 0x00A4B0B4+VersionOffset, 4) = 1)
	MemoryValue = 7
return

ChiliadChallengeAddress1CustomCode:
if MemoryValue = 1
	MemoryValue = 3
else
{
	MemoryValue := Memory(3, 0x00A4B57C+VersionOffset, 4)
	MemoryValue -= 1
	if MemoryValue = -1
		MemoryValue = 0
}
return

SafehouseAddress1CustomCode:
MemoryValue := ((MemoryValue >= 3) ? 1 : 0 )
return

SafehouseAddress32CustomCode:
MemoryValue := ((MemoryValue >= 4) ? 1 : 0 )
return



; ######################################################################################################
; ############################################# GTA 3 ##################################################
; ######################################################################################################

/*
Subheadings:

	GTA3PercentageOnly
	GTA3Requirements
	Custom Codes:
		PercentageAddress1CustomCode
		VigilanteAddress1-3CustomCode/FirefighterAddress1-3CustomCode
		ParamedicAddress1CustomCode
		KingCourtneyAddress1CustomCode
*/


GTA3PercentageOnlyRequirements:
Name = Percentage Completed
IconName = Percentage
Address1 := 0x0090651C
Address1CustomCode = 1
gosub %CurrentLoopCode%
return

GTA3Requirements:
Name = Percentage Completed
IconName = Percentage
Address1 := 0x0090651C
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Unique Jumps
IconName = UniqueJump
TotalRequired = 20
Address1 := 0x0075BFB0
gosub %CurrentLoopCode%
Name = Hidden Packages
IconName = HiddenPackageIII
TotalRequired = 100
Address1 := 0x0075C3D4
gosub %CurrentLoopCode%
Name = Rampages
IconName = RampageIII
TotalRequired = 20
Address1 := 0x0075C0AC
gosub %CurrentLoopCode%
Name = RC Missions
IconName = RCToyz
TotalRequired = 4
Address1 := 0x0075B9EC ; RC Diablo Destruction
Address2 := 0x0075B9F0 ; RC Mafia Massacre
Address3 := 0x0075B9F4 ; RC Rumpo Rampage
Address4 := 0x0075B9F8 ; RC Casino Calamity
gosub %CurrentLoopCode%
Name = Offroad Vehicle Challenges
IconName = VehicleChallenge
TotalRequired = 4
Address1 := 0x0075B970 ; Patriot Playground
Address2 := 0x0075B974 ; A Ride In The Park
Address3 := 0x0075B978 ; Gripped!
Address4 := 0x0075B97C ; Multistorey Mayhem
gosub %CurrentLoopCode%
Name = Vigilante
IconName = Vigilante
TotalRequired = 3
Address1 := 0x0075C454 ; Portland kills
Address1CustomCode = 1
Address2 := 0x0075C458 ; Staunton Island kills
Address2CustomCode = 1
Address3 := 0x0075C45C ; Shoreside Vale kills
Address3CustomCode = 1
gosub %CurrentLoopCode%
Name = Firefighter
IconName = Firefighter
TotalRequired = 3
Address1 := 0x0075C474 ; Portland fires
Address1CustomCode = 1
Address2 := 0x0075C478 ; Staunton Island fires
Address2CustomCode = 1
Address3 := 0x0075C47C ; Shoreside Vale fires
Address3CustomCode = 1
gosub %CurrentLoopCode%
Name = Paramedic
IconName = Paramedic
TotalRequired = 1
Address1 := 0x00902BF8 ; Highest level completed
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Taxi Fares
IconName = TaxiDriver
TotalRequired = 100
Address1 := 0x0075B9B4 ; Fares completed
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Export
IconName = ImportExport
TotalRequired = 3
Address1 := 0x0075C210 ; Portland completed
Address2 := 0x0075C2DC ; Shoreside Vale completed
Address3 := 0x0075C3B4 ; Crane completed
gosub %CurrentLoopCode%
Name = Luigi Goterelli
IconName = LuigiGoterelli
TotalRequired = 5
Address1 := 0x0075B75C ; Give Me Liberty and Luigi's Girls
Address2 := 0x0075B76C ; Don't Spank Ma Bitch Up
Address3 := 0x0075B770 ; Drive Misty For Me
Address4 := 0x0075B774 ; Pump-Action Pimp
Address5 := 0x0075B778 ; The Fuzz Ball
gosub %CurrentLoopCode%
Name = Joey Leone
IconName = JoeyLeone
TotalRequired = 6
Address1 := 0x0075B780 ; Mike Lips Last Lunch
Address2 := 0x0075B784 ; Farewell 'Chunky' Lee Chong
Address3 := 0x0075B788 ; Van Heist
Address4 := 0x0075B78C ; Cipriani's Chauffeur
Address5 := 0x0075B790 ; Dead Skunk in the Trunk
Address6 := 0x0075B794 ; The Getaway
gosub %CurrentLoopCode%
Name = Toni Cipriani
IconName = TonyCipriani
TotalRequired = 5
Address1 := 0x0075B79C ; Taking Out the Laundry
Address2 := 0x0075B7A0 ; The Pick-Up
Address3 := 0x0075B7A4 ; Salvatore's Called a Meeting
Address4 := 0x0075B7A8 ; Triads and Tribulations
Address5 := 0x0075B7AC ; Blow Fish
gosub %CurrentLoopCode%
Name = Salvatore Leone
IconName = SalvatoreLeone
TotalRequired = 4
Address1 := 0x0075B7B4 ; Chaperone
Address2 := 0x0075B7B8 ; Cutting the Grass
Address3 := 0x0075B7BC ; Bomb Da Base: Act I
Address4 := 0x0075B7C4 ; Last Requests
gosub %CurrentLoopCode%
Name = 8`-Ball
IconName = EightBall
TotalRequired = 1
Address1 := 0x0075B7C0 ; Bomb Da Base: Act II
gosub %CurrentLoopCode%
Name = Asuka Kasen
IconName = AsukaKasen
TotalRequired = 8
Address1 := 0x0075B878 ; Sayonara Salvatore
Address2 := 0x0075B87C ; Under Surveillance
Address3 := 0x0075B880 ; Paparazzi Purge
Address4 := 0x0075B884 ; Payday For Ray
Address5 := 0x0075B888 ; Two-Faced Tanner
Address6 := 0x0075B910 ; Bait
Address7 := 0x0075B914 ; Espresso-2-Go!
Address8 := 0x0075B918 ; S.A.M. + Ransom
gosub %CurrentLoopCode%
Name = Kenji Kasen
IconName = KenjiKasen
TotalRequired = 5
Address1 := 0x0075B8AC ; Kanbu Bust Out
Address2 := 0x0075B8B0 ; Grand Theft Auto
Address3 := 0x0075B8B4 ; Deal Steal
Address4 := 0x0075B8B8 ; Shima
Address5 := 0x0075B8BC ; Smack Down
gosub %CurrentLoopCode%
Name = Ray Machowski
IconName = RayMachowski
TotalRequired = 6
Address1 := 0x0075B890 ; Silence The Sneak
Address2 := 0x0075B894 ; Arms Shortage
Address3 := 0x0075B898 ; Evidence Dash
Address4 := 0x0075B89C ; Gone Fishing
Address5 := 0x0075B8A0 ; Plaster Blaster
Address6 := 0x0075B8A4 ; Marked Man
gosub %CurrentLoopCode%
Name = Donald Love
IconName = DonaldLove
TotalRequired = 7
Address1 := 0x0075B8C4 ; Liberator
Address2 := 0x0075B8C8 ; Waka-Gashira Wipeout
Address3 := 0x0075B8CC ; A Drop In The Ocean
Address4 := 0x0075B8FC ; Grand Theft Aero
Address5 := 0x0075B900 ; Escort Service
Address6 := 0x0075B904 ; Decoy
Address7 := 0x0075B908 ; Love's Disappearance
gosub %CurrentLoopCode%
Name = Catalina
IconName = CatalinaIII
TotalRequired = 1
Address1 := 0x0075B948 ; The Exchange
gosub %CurrentLoopCode%
Name = Marty Chonks
IconName = MartyChonks
TotalRequired = 4
Address1 := 0x0075B80C ; The Crook
Address2 := 0x0075B810 ; The Thieves
Address3 := 0x0075B814 ; The Wife
Address4 := 0x0075B818 ; Her Lover
gosub %CurrentLoopCode%
Name = El Burro
IconName = ElBurro
TotalRequired = 4
Address1 := 0x0075B838 ; Turismo
Address2 := 0x0075B7E4 ; I Scream, You Scream
Address3 := 0x0075B7E8 ; Trial By Fire
Address4 := 0x0075B7EC ; Big 'N' Veiny
gosub %CurrentLoopCode%
Name = King Courtney
IconName = KingCourtney
TotalRequired = 4
Address1 := 0x0075B8D4 ; Bling-Bling Scramble
Address1CustomCode = 1
Address2 := 0x0075B8D8 ; Uzi Rider
Address3 := 0x0075B8DC ; Gangcar Round-Up
Address4 := 0x0075B8E0 ; Kingdom Come
gosub %CurrentLoopCode%
Name = D`-Ice
IconName = DIce
TotalRequired = 5
Address1 := 0x0075B924 ; Uzi Money
Address2 := 0x0075B928 ; Toyminator
Address3 := 0x0075B92C ; Rigged to Blow
Address4 := 0x0075B930 ; Bullion Run
Address5 := 0x0075B934 ; Rumble
gosub %CurrentLoopCode%
return


PercentageAddress1CustomCode:
if Memory(3, 0x005C1E70, 4) = 0x53E58955 ; Game is version 1.0
	MemoryValue := Memory(3, 0x008F6224, 4)
MemoryValue /= 1.54
return

VigilanteAddress1CustomCode:
VigilanteAddress2CustomCode:
VigilanteAddress3CustomCode:
FirefighterAddress1CustomCode:
FirefighterAddress2CustomCode:
FirefighterAddress3CustomCode:
MemoryValue := ((MemoryValue >= 20) ? 1 : 0 )
return

ParamedicAddress1CustomCode:
if Memory(3, 0x005C1E70, 4) = 0x53E58955 ; Game is version 1.0
	MemoryValue := Memory(3, 0x008F2A04, 4)
MemoryValue := ((MemoryValue >= 12) ? 1 : 0 )
return

TaxiDriverAddress1CustomCode:
if Memory(3, 0x0075B9C4+VersionOffset, 4) = 1 ; Taxi driver completed
{
	TotalRequired := 1
	MemoryValue := 1
}
return

KingCourtneyAddress1CustomCode:
if MemoryValue = 0
	MemoryValue := Memory(3, 0x0075B8E0+VersionOffset, 4)
return

; ######################################################################################################
; ##################################### BULLY SCHOLARSHIP EDITION ######################################
; ######################################################################################################

/*
Subheadings:

	BullyPercentageOnly
	BullyRequirements
	Custom Codes:

*/

BullyPercentageOnlyRequirements:
Name = Percentage Completed
Type = Float
IconName = Percentage
Address1 := 0x020C3304
gosub %CurrentLoopCode%
return

BullyRequirements:
Name = Percentage Completed
Type = Float
IconName = Percentage
Address1 := 0x020C3304
gosub %CurrentLoopCode%
return

; ######################################################################################################
; ###################################### The Simpsons: Hit & Run #######################################
; ######################################################################################################

/*
Subheadings:

	SimpsonsHARPercentageOnly
	SimpsonsHARRequirements
	Custom Codes:
		HARPercentAddress1CustomCode
		HARStoryMissionsAddress1CustomCode
		HARBonusMissionsAddress1CustomCode
		HARStreetRacesAddress1CustomCode
		HARCollectorCardsAddress1CustomCode
		HARCharacterClothingAddress1CustomCode
		HARVehiclesAddress1CustomCode
		HARWaspCamerasAddress1CustomCode
		HARGagsAddress1CustomCode
		HARMoviesAddress1CustomCode
*/

SimpsonsHARPercentageOnlyRequirements:
Name = Points Completed
IconName = HARPercent
TotalRequired = 413
Address1 := 0x6C8984
Address1CustomCode = 1
gosub %CurrentLoopCode%
return

SimpsonsHARRequirements:
Name = Points Completed
IconName = HARPercent
TotalRequired = 413
Address1 := 0x6C8984
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Story Missions
IconName = HARStoryMissions
TotalRequired = 49
Address1 := 0x6C8984
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Bonus Missions
IconName = HARBonusMissions
TotalRequired = 7
Address1 := 0x6C8984
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Street Races
IconName = HARStreetRaces
TotalRequired = 21
Address1 := 0x6C8984
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Collector Cards
IconName = HARCollectorCards
TotalRequired = 49
Address1 := 0x6C8984
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Character Clothing
IconName = HARCharacterClothing
TotalRequired = 21
Address1 := 0x6C8984
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Vehicles
IconName = HARVehicles
TotalRequired = 35
Address1 := 0x6C8984
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Wasp Cameras
IconName = HARWaspCameras
TotalRequired = 140
Address1 := 0x6C8984
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Gags
IconName = HARGags
TotalRequired = 84
Address1 := 0x6C8984
Address1CustomCode = 1
gosub %CurrentLoopCode%
Name = Movies
IconName = HARMovies
TotalRequired = 7
Address1 := 0x6C8984
Address1CustomCode = 1
gosub %CurrentLoopCode%
return

; As you may be able to tell, this is where all of the memory information is stored.
HARPercentAddress1CustomCode:
L1CollectorCards := Memory(3, Memory(5, 0x6C8984, -0x1D8), 4)
L1Wasps := Memory(3, Memory(5, 0x6C8984, 0x238), 4)
L1Gags := Memory(3, Memory(5, 0x6C8984, 0x24C), 4)
L1CharacterClothing := Memory(3, Memory(5, 0x6C8984, 0x234), 4)
L1Vehicles := Memory(3, Memory(5, 0x6C8984, 0x230), 4)
L1TimeTrial := Memory(3, Memory(5, 0x6C8984, 0x19C), 4)
L1CircuitRace := Memory(3, Memory(5, 0x6C8984, 0x1BC), 4)
L1CheckpointRace := Memory(3, Memory(5, 0x6C8984, 0x1DC), 4)
L1M1 := Memory(3, Memory(5, 0x6C8984, 0xBC), 4)
L1M2 := Memory(3, Memory(5, 0x6C8984, 0xDC), 4)
L1M3 := Memory(3, Memory(5, 0x6C8984, 0xFC), 4)
L1M4 := Memory(3, Memory(5, 0x6C8984, 0x11C), 4)
L1M5 := Memory(3, Memory(5, 0x6C8984, 0x13C), 4)
L1M6 := Memory(3, Memory(5, 0x6C8984, 0x15C), 4)
L1M7 := Memory(3, Memory(5, 0x6C8984, 0x17C), 4)
L1BM := Memory(3, Memory(5, 0x6C8984, 0x1FC), 4)
L2CollectorCards := Memory(3, Memory(5, 0x6C8984, -0x1B8), 4)
L2Wasps := Memory(3, Memory(5, 0x6C8984, 0x4A4), 4)
L2Gags := Memory(3, Memory(5, 0x6C8984, 0x4B8), 4)
L2CharacterClothing := Memory(3, Memory(5, 0x6C8984, 0x4A0), 4)
L2Vehicles := Memory(3, Memory(5, 0x6C8984, 0x49C), 4)
L2TimeTrial := Memory(3, Memory(5, 0x6C8984, 0x408), 4)
L2CircuitRace := Memory(3, Memory(5, 0x6C8984, 0x428), 4)
L2CheckpointRace := Memory(3, Memory(5, 0x6C8984, 0x448), 4)
L2M1 := Memory(3, Memory(5, 0x6C8984, 0x308), 4)
L2M2 := Memory(3, Memory(5, 0x6C8984, 0x328), 4)
L2M3 := Memory(3, Memory(5, 0x6C8984, 0x348), 4)
L2M4 := Memory(3, Memory(5, 0x6C8984, 0x368), 4)
L2M5 := Memory(3, Memory(5, 0x6C8984, 0x388), 4)
L2M6 := Memory(3, Memory(5, 0x6C8984, 0x3A8), 4)
L2M7 := Memory(3, Memory(5, 0x6C8984, 0x3C8), 4)
L2BM := Memory(3, Memory(5, 0x6C8984, 0x468), 4)
L3CollectorCards := Memory(3, Memory(5, 0x6C8984, -0x198), 4)
L3Wasps := Memory(3, Memory(5, 0x6C8984, 0x710), 4)
L3Gags := Memory(3, Memory(5, 0x6C8984, 0x724), 4)
L3CharacterClothing := Memory(3, Memory(5, 0x6C8984, 0x70C), 4)
L3Vehicles := Memory(3, Memory(5, 0x6C8984, 0x708), 4)
L3TimeTrial := Memory(3, Memory(5, 0x6C8984, 0x674), 4)
L3CircuitRace := Memory(3, Memory(5, 0x6C8984, 0x694), 4)
L3CheckpointRace := Memory(3, Memory(5, 0x6C8984, 0x6B4), 4)
L3M1 := Memory(3, Memory(5, 0x6C8984, 0x574), 4)
L3M2 := Memory(3, Memory(5, 0x6C8984, 0x594), 4)
L3M3 := Memory(3, Memory(5, 0x6C8984, 0x5B4), 4)
L3M4 := Memory(3, Memory(5, 0x6C8984, 0x5D4), 4)
L3M5 := Memory(3, Memory(5, 0x6C8984, 0x5F4), 4)
L3M6 := Memory(3, Memory(5, 0x6C8984, 0x614), 4)
L3M7 := Memory(3, Memory(5, 0x6C8984, 0x634), 4)
L3BM := Memory(3, Memory(5, 0x6C8984, 0x6D4), 4)
L4CollectorCards := Memory(3, Memory(5, 0x6C8984, -0x178), 4)
L4Wasps := Memory(3, Memory(5, 0x6C8984, 0x97C), 4)
L4Gags := Memory(3, Memory(5, 0x6C8984, 0x990), 4)
L4CharacterClothing := Memory(3, Memory(5, 0x6C8984, 0x978), 4)
L4Vehicles := Memory(3, Memory(5, 0x6C8984, 0x974), 4)
L4TimeTrial := Memory(3, Memory(5, 0x6C8984, 0x8E0), 4)
L4CircuitRace := Memory(3, Memory(5, 0x6C8984, 0x900), 4)
L4CheckpointRace := Memory(3, Memory(5, 0x6C8984, 0x920), 4)
L4M1 := Memory(3, Memory(5, 0x6C8984, 0x7E0), 4)
L4M2 := Memory(3, Memory(5, 0x6C8984, 0x800), 4)
L4M3 := Memory(3, Memory(5, 0x6C8984, 0x820), 4)
L4M4 := Memory(3, Memory(5, 0x6C8984, 0x840), 4)
L4M5 := Memory(3, Memory(5, 0x6C8984, 0x860), 4)
L4M6 := Memory(3, Memory(5, 0x6C8984, 0x880), 4)
L4M7 := Memory(3, Memory(5, 0x6C8984, 0x8A0), 4)
L4BM := Memory(3, Memory(5, 0x6C8984, 0x940), 4)
L5CollectorCards := Memory(3, Memory(5, 0x6C8984, -0x158), 4)
L5Wasps := Memory(3, Memory(5, 0x6C8984, 0xBE8), 4)
L5Gags := Memory(3, Memory(5, 0x6C8984, 0xBFC), 4)
L5CharacterClothing := Memory(3, Memory(5, 0x6C8984, 0xBE4), 4)
L5Vehicles := Memory(3, Memory(5, 0x6C8984, 0xBE0), 4)
L5TimeTrial := Memory(3, Memory(5, 0x6C8984, 0xB4C), 4)
L5CircuitRace := Memory(3, Memory(5, 0x6C8984, 0xB6C), 4)
L5CheckpointRace := Memory(3, Memory(5, 0x6C8984, 0xB8C), 4)
L5M1 := Memory(3, Memory(5, 0x6C8984, 0xA4C), 4)
L5M2 := Memory(3, Memory(5, 0x6C8984, 0xA6C), 4)
L5M3 := Memory(3, Memory(5, 0x6C8984, 0xA8C), 4)
L5M4 := Memory(3, Memory(5, 0x6C8984, 0xAAC), 4)
L5M5 := Memory(3, Memory(5, 0x6C8984, 0xACC), 4)
L5M6 := Memory(3, Memory(5, 0x6C8984, 0xAEC), 4)
L5M7 := Memory(3, Memory(5, 0x6C8984, 0xB0C), 4)
L5BM := Memory(3, Memory(5, 0x6C8984, 0xBAC), 4)
L6CollectorCards := Memory(3, Memory(5, 0x6C8984, -0x138), 4)
L6Wasps := Memory(3, Memory(5, 0x6C8984, 0xE54), 4)
L6Gags := Memory(3, Memory(5, 0x6C8984, 0xE68), 4)
L6CharacterClothing := Memory(3, Memory(5, 0x6C8984, 0xE50), 4)
L6Vehicles := Memory(3, Memory(5, 0x6C8984, 0xE4C), 4)
L6TimeTrial := Memory(3, Memory(5, 0x6C8984, 0xDB8), 4)
L6CircuitRace := Memory(3, Memory(5, 0x6C8984, 0xDD8), 4)
L6CheckpointRace := Memory(3, Memory(5, 0x6C8984, 0xDF8), 4)
L6M1 := Memory(3, Memory(5, 0x6C8984, 0xCB8), 4)
L6M2 := Memory(3, Memory(5, 0x6C8984, 0xCD8), 4)
L6M3 := Memory(3, Memory(5, 0x6C8984, 0xCF8), 4)
L6M4 := Memory(3, Memory(5, 0x6C8984, 0xD18), 4)
L6M5 := Memory(3, Memory(5, 0x6C8984, 0xD38), 4)
L6M6 := Memory(3, Memory(5, 0x6C8984, 0xD58), 4)
L6M7 := Memory(3, Memory(5, 0x6C8984, 0xD78), 4)
L6BM := Memory(3, Memory(5, 0x6C8984, 0xE18), 4)
L7CollectorCards := Memory(3, Memory(5, 0x6C8984, -0x118), 4)
L7Wasps := Memory(3, Memory(5, 0x6C8984, 0x10C0), 4)
L7Gags := Memory(3, Memory(5, 0x6C8984, 0x10D4), 4)
L7CharacterClothing := Memory(3, Memory(5, 0x6C8984, 0x10BC), 4)
L7Vehicles := Memory(3, Memory(5, 0x6C8984, 0x10B8), 4)
L7TimeTrial := Memory(3, Memory(5, 0x6C8984, 0x1024), 4)
L7CircuitRace := Memory(3, Memory(5, 0x6C8984, 0x1044), 4)
L7CheckpointRace := Memory(3, Memory(5, 0x6C8984, 0x1064), 4)
L7M1 := Memory(3, Memory(5, 0x6C8984, 0xF24), 4)
L7M2 := Memory(3, Memory(5, 0x6C8984, 0xF44), 4)
L7M3 := Memory(3, Memory(5, 0x6C8984, 0xF64), 4)
L7M4 := Memory(3, Memory(5, 0x6C8984, 0xF84), 4)
L7M5 := Memory(3, Memory(5, 0x6C8984, 0xFA4), 4)
L7M6 := Memory(3, Memory(5, 0x6C8984, 0xFC4), 4)
L7M7 := Memory(3, Memory(5, 0x6C8984, 0xFE4), 4)
L7BM := Memory(3, Memory(5, 0x6C8984, 0x1084), 4)
Level1Movie := Memory(3, Memory(5, 0x6C8984, 0x22C), 4)
Level2Movie := Memory(3, Memory(5, 0x6C8984, 0x498), 4)
Level4Movie := Memory(3, Memory(5, 0x6C8984, 0x970), 4)
Level5Movie := Memory(3, Memory(5, 0x6C8984, 0xBDC), 4)
Level6Movie := Memory(3, Memory(5, 0x6C8984, 0xE48), 4)
Level7Movie := Memory(3, Memory(5, 0x6C8984, 0x10B4), 4)
BonusMovie := Memory(3, Memory(5, 0x6C8984, 0x704), 4)
MemoryValue := L1CollectorCards + L1Wasps + L1Gags + L1CharacterClothing + L1Vehicles + L1TimeTrial + L1CircuitRace + L1CheckpointRace + L1M1 + L1M2 + L1M3 + L1M4 + L1M5 + L1M6 + L1M7 + L1BM + L2CollectorCards + L2Wasps + L2Gags + L2CharacterClothing + L2Vehicles + L2TimeTrial + L2CircuitRace + L2CheckpointRace + L2M1 + L2M2 + L2M3 + L2M4 + L2M5 + L2M6 + L2M7 + L2BM + L3CollectorCards + L3Wasps + L3Gags + L3CharacterClothing + L3Vehicles + L3TimeTrial + L3CircuitRace + L3CheckpointRace + L3M1 + L3M2 + L3M3 + L3M4 + L3M5 + L3M6 + L3M7 + L3BM + L4CollectorCards + L4Wasps + L4Gags + L4CharacterClothing + L4Vehicles + L4TimeTrial + L4CircuitRace + L4CheckpointRace + L4M1 + L4M2 + L4M3 + L4M4 + L4M5 + L4M6 + L4M7 + L4BM + L5CollectorCards + L5Wasps + L5Gags + L5CharacterClothing + L5Vehicles + L5TimeTrial + L5CircuitRace + L5CheckpointRace + L5M1 + L5M2 + L5M3 + L5M4 + L5M5 + L5M6 + L5M7 + L5BM + L6CollectorCards + L6Wasps + L6Gags + L6CharacterClothing + L6Vehicles + L6TimeTrial + L6CircuitRace + L6CheckpointRace + L6M1 + L6M2 + L6M3 + L6M4 + L6M5 + L6M6 + L6M7 + L6BM + L7CollectorCards + L7Wasps + L7Gags + L7CharacterClothing + L7Vehicles + L7TimeTrial + L7CircuitRace + L7CheckpointRace + L7M1 + L7M2 + L7M3 + L7M4 + L7M5 + L7M6 + L7M7 + L7BM + Level1Movie + Level2Movie + Level4Movie + Level5Movie + Level6Movie + Level7Movie + BonusMovie + L1BM + L2BM + L3BM + L4BM + L5BM + L6BM + L7BM
if (L1TimeTrial = 1) and (L1CircuitRace = 1) and (L1CheckpointRace = 1)
	MemoryValue++
if (L2TimeTrial = 1) and (L2CircuitRace = 1) and (L2CheckpointRace = 1)
	MemoryValue++
if (L3TimeTrial = 1) and (L3CircuitRace = 1) and (L3CheckpointRace = 1)
	MemoryValue++
if (L4TimeTrial = 1) and (L4CircuitRace = 1) and (L4CheckpointRace = 1)
	MemoryValue++
if (L5TimeTrial = 1) and (L5CircuitRace = 1) and (L5CheckpointRace = 1)
	MemoryValue++
if (L6TimeTrial = 1) and (L6CircuitRace = 1) and (L6CheckpointRace = 1)
	MemoryValue++
if (L7TimeTrial = 1) and (L7CircuitRace = 1) and (L7CheckpointRace = 1)
	MemoryValue++
return

HARStoryMissionsAddress1CustomCode:
MemoryValue := L1M1 + L1M2 + L1M3 + L1M4 + L1M5 + L1M6 + L1M7 + L2M1 + L2M2 + L2M3 + L2M4 + L2M5 + L2M6 + L2M7 + L3M1 + L3M2 + L3M3 + L3M4 + L3M5 + L3M6 + L3M7 + L4M1 + L4M2 + L4M3 + L4M4 + L4M5 + L4M6 + L4M7 + L5M1 + L5M2 + L5M3 + L5M4 + L5M5 + L5M6 + L5M7 + L6M1 + L6M2 + L6M3 + L6M4 + L6M5 + L6M6 + L6M7 + L7M1 + L7M2 + L7M3 + L7M4 + L7M5 + L7M6 + L7M7
return

HARBonusMissionsAddress1CustomCode:
MemoryValue := L1BM + L2BM + L3BM + L4BM + L5BM + L6BM + L7BM
return

HARStreetRacesAddress1CustomCode:
MemoryValue := L1TimeTrial + L1CircuitRace + L1CheckpointRace + L2TimeTrial + L2CircuitRace + L2CheckpointRace + L3TimeTrial + L3CircuitRace + L3CheckpointRace + L4TimeTrial + L4CircuitRace + L4CheckpointRace + L5TimeTrial + L5CircuitRace + L5CheckpointRace + L6TimeTrial + L6CircuitRace + L6CheckpointRace + L7TimeTrial + L7CircuitRace + L7CheckpointRace
return

HARCollectorCardsAddress1CustomCode:
MemoryValue := L1CollectorCards + L2CollectorCards + L3CollectorCards + L4CollectorCards + L5CollectorCards + L6CollectorCards + L7CollectorCards
return

HARCharacterClothingAddress1CustomCode:
MemoryValue := L1CharacterClothing + L2CharacterClothing + L3CharacterClothing + L4CharacterClothing + L5CharacterClothing + L6CharacterClothing + L7CharacterClothing
return

HARVehiclesAddress1CustomCode:
MemoryValue := L1Vehicles + L2Vehicles + L3Vehicles + L4Vehicles + L5Vehicles + L6Vehicles + L7Vehicles + L1BM + L2BM + L3BM + L4BM + L5BM + L6BM + L7BM
if (L1TimeTrial = 1) and (L1CircuitRace = 1) and (L1CheckpointRace = 1)
	MemoryValue++
if (L2TimeTrial = 1) and (L2CircuitRace = 1) and (L2CheckpointRace = 1)
	MemoryValue++
if (L3TimeTrial = 1) and (L3CircuitRace = 1) and (L3CheckpointRace = 1)
	MemoryValue++
if (L4TimeTrial = 1) and (L4CircuitRace = 1) and (L4CheckpointRace = 1)
	MemoryValue++
if (L5TimeTrial = 1) and (L5CircuitRace = 1) and (L5CheckpointRace = 1)
	MemoryValue++
if (L6TimeTrial = 1) and (L6CircuitRace = 1) and (L6CheckpointRace = 1)
	MemoryValue++
if (L7TimeTrial = 1) and (L7CircuitRace = 1) and (L7CheckpointRace = 1)
	MemoryValue++
return

HARWaspCamerasAddress1CustomCode:
MemoryValue := L1Wasps + L2Wasps + L3Wasps + L4Wasps + L5Wasps + L6Wasps + L7Wasps
return

HARGagsAddress1CustomCode:
MemoryValue := L1Gags + L2Gags + L3Gags + L4Gags + L5Gags + L6Gags + L7Gags
return

HARMoviesAddress1CustomCode:
MemoryValue := Level1Movie + Level2Movie + Level4Movie + Level5Movie + Level6Movie + Level7Movie + BonusMovie
return

; ######################################################################################################
; ########################################### DEBUG STUFF ##############################################
; ######################################################################################################

DebugFunctions:
Hotkey, F7, DebugListvars, On
return

DebugListvars:
listvars
return
;*/
