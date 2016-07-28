; #FUNCTION# ====================================================================================================================
; Name ..........: PrismoCRBot
; Description ...: This file contains all coding for PrismoCRBot
; Author ........: prismoclash (2016)
; Modified ......:
; Remarks .......: No Copyright yet
;                  It will hopefully be distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/prismoclash/PrismoCRBot
; Example .......: No
; ===============================================================================================================================
#RequireAdmin

#include <WinAPIGdi.au3>

#Region Declare Variables

	Global $HWnD = 0 ; Handle for Android window
	Global $BlueStacksFrontendPID = 0 ; Android Frontend process

	Global $aPixelBlueStacksLoaded[3] = [16+6, 70+5, Dec('F38025')]

	;--> Menu locations
	Global $aMenuOrder[5] = ['shop', 'cards', 'battle', 'clan', 'tournament']

	Global $aPixel_in_shop[3] = [84+6, 684+6, Dec('66EA37')]
	Global $aPixel_in_cards[3] = [176+6, 684+6, Dec('F0AB35')]
	Global $aPixel_in_battle[3] = [250+6, 684+6, Dec('D8E8F4')]
	Global $aPixel_in_clan[3] = [334+6, 686+6, Dec('FFFFFF')]
	Global $aPixel_in_tournament[3] = [420+6, 684+6, Dec('F0F9FF')]

	;--> Popup menus
	Global $aPixel_connectionlost[3] = [250, 500, Dec('282828')]
	Global $aPixel_donation_received[3] = [450, 200, Dec('FFACD6')]


#EndRegion

#Region Launch BlueStacks and CR

	;--> Check if already launched
	$HWnD = WinGetHandle("BlueStacks Android Plugin")

	ConsoleWrite('$HWnD = ' & $HWnD & @CRLF)
	ConsoleWrite('@error = ' & @error & @CRLF)

	If $HWnD <> 0 Then

		_FindMenu('shop', 5000)
		_FindMenu('battle', 5000)
		_FindMenu('cards', 5000)
		_FindMenu('tournament', 5000)
		_FindMenu('clan', 5000)
		_FindMenu('battle', 5000)

	Else

		;-->Set correct resolution and close Bluestacks
		ConsoleWrite('Setting correct resolution and closing BlueStacks' & @CRLF)
		ShellExecute(@ScriptDir & "\BlueStacks Resolution\resolution.bat")

		ConsoleWrite('@error = ' & @error & @CRLF)

		Sleep(2000)

		;--> Launch BlueStacks
		ConsoleWrite('Launching BlueStacks' & @CRLF)
		$BlueStacksFrontendPID = ShellExecute("C:\Program Files (x86)\BlueStacks\" & "HD-Frontend.exe", "Android")

		ConsoleWrite('$BlueStacksFrontendPID = ' & $BlueStacksFrontendPID & @CRLF)

		Sleep(2000)

		$HWnD = WinGetHandle("BlueStacks Android Plugin")

		ConsoleWrite('$HWnD = ' & $HWnD & @CRLF)
		ConsoleWrite('@error = ' & @error & @CRLF)

		While _CanFindPixel($aPixelBlueStacksLoaded, 0) = 0
			;ConsoleWrite("Waiting for color " & Hex($aPixelBlueStacksLoaded[2]) & " at pixel position " & $aPixelBlueStacksLoaded[0] & ", " & $aPixelBlueStacksLoaded[1] & @CRLF)
		WEnd

		;--> Launch ClashRoyale
		ConsoleWrite('Launching Clash Royale' & @CRLF)
		_SendADB("connect localhost:5555")

		Sleep(2000)

		_SendADB("-a shell am start -n com.supercell.clashroyale/.GameApp")

	EndIf



#EndRegion

#Region Functions

	Func _SendADB($command)
		ShellExecute("C:\Program Files (x86)\BlueStacks\HD-Adb.exe", $command, '', '', @SW_HIDE)
	EndFunc   ;==>_SendADB

	Func _CanFindPixel($a, $sVari = 5, $Ignore = "")

		If $a[2] = 0 Then Return False

		;--> Convert dec to hex
		$nColor1 = Hex(PixelGetColor($a[0], $a[1], $HWnD))
		;ConsoleWrite('$nColor1 ' & $nColor1 & ' at pixel position ' & $a[0] & ', ' & $a[1] & @CRLF)
		$nColor2 = Hex($a[2])


		$Red1 = _WinAPI_GetRValue($nColor1)
		$Blue1 = _WinAPI_GetBValue($nColor1)
		$Green1 = _WinAPI_GetGValue($nColor1)

		$Red2 = _WinAPI_GetRValue($nColor2)
		$Blue2 = _WinAPI_GetBValue($nColor2)
		$Green2 = _WinAPI_GetGValue($nColor2)

		Switch $Ignore
			Case "Red" ; mask RGB - Red
				If Abs($Blue1 - $Blue2) > $sVari Then Return False
				If Abs($Green1 - $Green2) > $sVari Then Return False
			Case "Heroes" ; mask RGB - Green
				If Abs($Blue1 - $Blue2) > $sVari Then Return False
				If Abs($Red1 - $Red2) > $sVari Then Return False
			Case Else
				If Abs($Blue1 - $Blue2) > $sVari Then Return False
				If Abs($Green1 - $Green2) > $sVari Then Return False
				If Abs($Red1 - $Red2) > $sVari Then Return False
		EndSwitch

		Return True

	EndFunc   ;==>_CanFindPixel

	Func _FindMenu($sMenuToFind, $timeout = 0)
		$timer = TimerInit()
		;--> Get to main menu
		While _CanFindPixel(Eval('aPixel_in_' & $sMenuToFind)) = 0

			ConsoleWrite('Searching ' & $sMenuToFind & @CRLF)

			;--> Check for disconnection menu
			If _CanFindPixel($aPixel_connectionlost) = 1 Then
				_ClickPixel($aPixel_connectionlost)
			EndIf

			;--> Check for donatios received button.
			If _CanFindPixel($aPixel_donation_received) = 1 Then
				_ClickPixel($aPixel_donation_received)
			EndIf

			;--> Check for time out
			If TimerDiff($timer) >= $timeout And $timeout > 0 Then
				Return 0
				ExitLoop
			EndIf

			;--> Figure out which tab we're in
			$sMenuCurrent = ''
			For $i = 0 To UBound($aMenuOrder) - 1
				If _CanFindPixel(Eval('aPixel_in_' & $aMenuOrder[$i])) = 1 Then
					$sMenuCurrent = $aMenuOrder[$i]
					ExitLoop
				EndIf
			Next

			;--> Swipe left or right according to if we're before or after the tab we want
			If $sMenuCurrent <> '' Then
				For $i = 0 To UBound($aMenuOrder) - 1
					If $aMenuOrder[$i] = $sMenuToFind Then
						_SwipeRight()
						ExitLoop
					ElseIf $aMenuOrder[$i] = $sMenuCurrent Then
						_SwipeLeft()
						ExitLoop
					EndIf
				Next
			EndIf

			Sleep(1000)
		WEnd

		_WaitForPixel(Eval('aPixel_in_' & $sMenuToFind))
		ConsoleWrite('Found ' & $sMenuToFind & @CRLF)
		Sleep(1000)
		Return 1
	EndFunc   ;==>_FindMenu


	Func _ClickPixel($a)

		If _CanFindPixel($a) Then
	;~ 		MouseClick($MOUSE_CLICK_PRIMARY, $AndroidPos[0] + $a[0], $AndroidPos[1] + $a[1])
			_SendADB("-a shell input tap " & $a[0] & " " & $a[1])
			Return 1
		Else
			Return 0
		EndIf

	EndFunc   ;==>_ClickPixel


	Func _SwipeRight()
	;~ 	MouseClickDrag($MOUSE_CLICK_PRIMARY, $AndroidPos[0] + 50, $AndroidPos[1] + 400, $AndroidPos[0] + 450, $AndroidPos[1] + 400)
		_SendADB("-a shell input swipe 50 400 450 400")
		Sleep(100)
	EndFunc   ;==>_SwipeRight


	Func _SwipeLeft()
	;~ 	MouseClickDrag($MOUSE_CLICK_PRIMARY, $AndroidPos[0] + 450, $AndroidPos[1] + 400, $AndroidPos[0] + 50, $AndroidPos[1] + 400)
		_SendADB("-a shell input swipe 450 400 50 400")
		Sleep(100)
	EndFunc   ;==>_SwipeLeft


	Func _WaitForPixel($a, $timeout = 0)

		$timer = TimerInit()
		$result = _CanFindPixel($a)

		While $result = 0
			Sleep(100)
			$result = _CanFindPixel($a)
	;~ 		ConsoleWrite($result & @CRLF)
			If TimerDiff($timer) >= $timeout And $timeout > 0 Then
				ExitLoop
			EndIf
		WEnd

		Return $result

	EndFunc   ;==>_WaitForPixel


#EndRegion