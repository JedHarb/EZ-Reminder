#NoEnv ; Recommended for AHK scripts.
#SingleInstance, Off ; Allow the user to run multiples of the app at once.
SetTitleMatchMode 3 ; Ensure that the #IfWinActive directive must match the window name exactly.

StartScript:
	; Create the reminder setup gui to ask for input.
	Gui +ToolWindow
	Gui, Add, Text, , Reminder Note
	Gui, Add, Edit, w100 vNote
	Gui, Add, Text, , Reminder Time
	Gui, Add, Edit, x10 w20 vHour, 
	Gui, Add, Text, x+2, ` :
	Gui, Add, Edit, x+5 w20 vMinute, 
	Gui, Add, Radio, x+10 w40 vTimePeriodAM, AM
	Gui, Add, Radio, y+1 w40 vTimePeriodPM Checked, PM
	Gui, Add, Button, w100 x10 gCreateReminder, Create Reminder
	Gui, Show
return

; Pressing Enter clicks the Create Reminder button in the gui.
#IfWinActive, EZ-Reminder.exe
Enter::
NumpadEnter::

CreateReminder:
	Gui, Submit
	
	; Trim leading or trailing spaces.
	note := Trim(Note)
	savedHour := Trim(Hour)
	savedMinute := Trim(Minute)

	; Trim leading 0s (because later, RegExMatch() returning the 0s counts as "false")
	targetHour := LTrim(savedHour, "0")
	targetMinute := LTrim(savedMinute, "0")

	; Convert the hour and minute to integers
    targetHour := targetHour + 0
    targetMinute := targetMinute + 0

	; Set timePeriod to AM or PM
	timePeriod := TimePeriodAM ? "AM" : "PM"
	
	; Validate the time format.
	if (!RegExMatch(targetHour, "^([1]?[0-9])$") || (!RegExMatch(targetMinute, "^([1-5]?[0-9])$") && targetMinute != "")) {
		MsgBox, Invalid time! Please try again useing the 12-hour format hh:mm.
		; I thought blanking these variables would be required before restarting the script. It seems to work the same without this line, but I'll comment it out here just in case I need it back...
		;note := hour := minute := targetHour := targetMinute := "" 
		Gui, Destroy
		GoSub, StartScript ; Go back to the beginning of the script.
		return
	}

	if (targetMinute = "")
		targetMinute := 00
	
	; Loop once per second to check if the target hour/minute matches the current hour/minute.
	Loop {
		if ((timePeriod = "AM" && targetHour = A_Hour && targetMinute = A_Min) || (timePeriod = "PM" && targetHour = A_Hour - 12 && targetMinute = A_Min)) {
			; Create a new gui to pop up the reminder.
			Gui, Destroy
			Gui +ToolWindow +LastFound +AlwaysOnTop
			Gui, Margin, 20, 20
			Gui, Font, s15
			Gui Color, 94C7CB
			Gui Add, Text, 0x80, Note: %note%`n`nReminder time: %savedHour%:%savedMinute%
			Gui Show, xCenter yCenter, ` ` ` ` ` ` REMINDER!

			; Blinking effect for the reminder box.
            Loop 5 {
                Gui Color, e53056 
                Sleep, 500
                Gui Color, 94C7CB
                Sleep, 500
            }

			return
		}
		Sleep, 1000 
	}
return

GuiClose:
	ExitApp