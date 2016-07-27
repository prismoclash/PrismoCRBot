; #FUNCTION# ====================================================================================================================
; Name ..........: Functions to interact with Android Window
; Description ...: This file contains the detection fucntions for the emulator and Android version used.
; Syntax ........:
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

Func UpdateAndroidConfig($instance = Default)

	If $instance = "" Then $instance = Default
	If $instance = Default Then $instance = $AndroidAppConfig[$AndroidConfig][1]

	InitAndroidConfig()
	$AndroidInstance = $instance ; Clone or instance of emulator or "" if not supported/default instance

	; validate install and initialize Android variables
    Local $Result = InitAndroid()

	Return $Result

EndFunc   ;==>UpdateAndroidConfig

Func DetectRunningAndroid()

	$FoundRunningAndroid = False

	Local $i, $CurrentConfig = $AndroidConfig

	For $i = 0 To UBound($AndroidAppConfig) - 1

		$AndroidConfig = $i

		$InitAndroid = True

		If UpdateAndroidConfig() = True Then



		EndIf

	Next

EndFunc   ;==>DetectRunningAndroid

Func InitAndroid($bCheckOnly = False)

	If $bCheckOnly = False And $InitAndroid = False Then

		Return True ; already initialized

	EndIf

	If Not $bCheckOnly Then

		; Check that $AndroidInstance default instance is used for ""
		If $AndroidInstance = "" Then $AndroidInstance = $AndroidAppConfig[$AndroidConfig][1]

	ElseIf

	Local $Result = Execute("Init" & $Android & "(" & $bCheckOnly & ")")



EndFunc