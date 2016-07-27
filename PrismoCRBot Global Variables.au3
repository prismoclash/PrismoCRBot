; #FUNCTION# ====================================================================================================================
; Name ..........: PrismoCRBot Global Variables
; Description ...: This file includes several files in the current script and all declared variables, constant, or create an array.
; Syntax ........: #include, Global
; Parameters ....: None
; Return values .: None
; Author ........: prismoclash (2016)
; Modified ......:
; Remarks .......: This file is part of PrismoCRBot. No Copyright yet
;                  It will hopefully be distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/prismoclash/PrismoCRBot
; Example .......: No
; ===============================================================================================================================

Global $AndroidAdbScreencapEnabled = True ; Use Android ADB to capture screenshots in RGBA raw format

Global $AndroidAdbInputEnabled = True ; Enable Android ADB swipe and send text (CR requests)
Global $AndroidAdbClickEnabled = True ; Enable Android ADB mouse click

Global $AndroidAdbInstanceEnabled = True ; Enable Android steady ADB shell instance when available





;   0            |1               |2                       |3                                 |4            |5                  |6                   |7                  |8                   |9             |10               |11                    |12                 |13
;   $Android     |$AndroidInstance|$Title                  |$AppClassInstance                 |$AppPaneName |$AndroidClientWidth|$AndroidClientHeight|$AndroidWindowWidth|$AndroidWindowHeight|$ClientOffsetY|$AndroidAdbDevice|$AndroidSupportFeature|$AndroidShellPrompt|$AndroidMouseDevice
;                |                |                        |                                  |             |                   |                    |                   |                    |              |                 |1 = Normal background mode                |
;                |                |                        |                                  |             |                   |                    |                   |                    |              |                 |2 = ADB screencap mode|                   |
;                |                |                        |                                  |             |                   |                    |                   |                    |              |                 |4 = ADB mouse click   |                   |
;                |                |                        |                                  |             |                   |                    |                   |                    |              |                 |8 = ADB input text and swipe              |
Global $AndroidAppConfig[5][14] = [ _ ;                    |                                  |             |                   |                    |                   |                    |              |                 |16 = ADB shell is steady                  |
   ["BlueStacks", "",              "BlueStacks App Player","[CLASS:BlueStacksApp; INSTANCE:1]","_ctl.Window",$DEFAULT_WIDTH,     $DEFAULT_HEIGHT - 48,$DEFAULT_WIDTH,     $DEFAULT_HEIGHT - 48,0,             "emulator-5554",  1    +8               ,'$ ',               'BlueStacks Virtual Touch'], _
   ["BlueStacks2","",              "BlueStacks ",          "[CLASS:BlueStacksApp; INSTANCE:1]","_ctl.Window",$DEFAULT_WIDTH,     $DEFAULT_HEIGHT - 48,$DEFAULT_WIDTH,     $DEFAULT_HEIGHT - 48,0,             "emulator-5554",  1    +8               ,'$ ',               'BlueStacks Virtual Touch'], _
   ["Droid4X",    "droid4x",       "Droid4X 0.",           "[CLASS:subWin; INSTANCE:1]",       "",           $DEFAULT_WIDTH,     $DEFAULT_HEIGHT - 48,$DEFAULT_WIDTH + 10,$DEFAULT_HEIGHT + 50,0,             "127.0.0.1:26944",0+2+4+8+16            ,'# ',               'droid4x Virtual Input'], _
   ["MEmu",       "MEmu",          "MEmu 2.",              "[CLASS:subWin; INSTANCE:1]",       "",           $DEFAULT_WIDTH,     $DEFAULT_HEIGHT - 12,$DEFAULT_WIDTH + 51,$DEFAULT_HEIGHT + 24,0,             "127.0.0.1:21503",0+2+4+8+16            ,'# ',               'Microvirt Virtual Input'], _
   ["Nox",        "nox",           "No",                   "[CLASS:subWin; INSTANCE:1]",       "",           $DEFAULT_WIDTH,     $DEFAULT_HEIGHT - 48,$DEFAULT_WIDTH +  4,$DEFAULT_HEIGHT - 10,0,             "127.0.0.1:62001",0+2+4+8+16            ,'# ',               'nox Virtual Input'] _
]


Global $FoundRunningAndroid = False


Global $AndroidConfig = 0 ; Default selected Android Config of $AndroidAppConfig array

Func InitAndroidConfig($bRestart = False)

	Global $Android = $AndroidAppConfig[$AndroidConfig][0] ; Emulator used (BS, BS2, Droid4X, MEmu or Nox)
	Global $AndroidInstance ; Clone or instance of emulator or "" if not supported
	Global $Title ; Emulator Window Title
	If $bRestart = False Then
	   $AndroidInstance = $AndroidAppConfig[$AndroidConfig][1]
	   $Title = $AndroidAppConfig[$AndroidConfig][2]
	EndIf
	Global $AppClassInstance = $AndroidAppConfig[$AndroidConfig][3] ; Control Class and instance of android rendering
	Global $AppPaneName = $AndroidAppConfig[$AndroidConfig][4] ; Control name of android rendering TODO check is still required
	Global $AndroidClientWidth = $AndroidAppConfig[$AndroidConfig][5] ; Expected width of android rendering control
	Global $AndroidClientHeight = $AndroidAppConfig[$AndroidConfig][6] ; Expected height of android rendering control
	Global $AndroidWindowWidth = $AndroidAppConfig[$AndroidConfig][7] ; Expected Width of android window
	Global $AndroidWindowHeight = $AndroidAppConfig[$AndroidConfig][8] ; Expected height of android window
	Global $ClientOffsetY = $AndroidAppConfig[$AndroidConfig][9] ; not used/required anymore
	Global $AndroidAdbPath = "" ; Path to executable HD-Adb.exe or adb.exe
	Global $AndroidAdbDevice = $AndroidAppConfig[$AndroidConfig][10] ; full device name ADB connects to
	Global $AndroidSupportFeature = $AndroidAppConfig[$AndroidConfig][11] ; 0 = Not available, 1 = Available, 2 = Available using ADB (experimental!)
	Global $AndroidShellPrompt = $AndroidAppConfig[$AndroidConfig][12] ; empty string not available, '# ' for rooted and '$ ' for not rooted android
	Global $AndroidMouseDevice = $AndroidAppConfig[$AndroidConfig][13] ; empty string not available, can be direct device '/dev/input/event2' or name by getevent -p
	Global $AndroidAdbScreencap = $AndroidAdbScreencapEnabled = True And BitAND($AndroidSupportFeature, 2) = 2 ; Use Android ADB to capture screenshots in RGBA raw format
	Global $AndroidAdbClick = $AndroidAdbClickEnabled = True And BitAND($AndroidSupportFeature, 4) = 4 ; Enable Android ADB mouse click
	Global $AndroidAdbInput = $AndroidAdbInputEnabled = True And BitAND($AndroidSupportFeature, 8) = 8 ; Enable Android ADB swipe and send text (CC requests)
	Global $AndroidAdbInstance = $AndroidAdbInstanceEnabled = True And BitAND($AndroidSupportFeature, 16) = 16 ; Enable Android steady ADB shell instance when available

EndFunc
InitAndroidConfig()


Global $InitAndroid = True ; Used to cache android config, is set to False once initialized, new emulator window handle resets it to True