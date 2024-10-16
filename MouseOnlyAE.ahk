#Persistent
#NoEnv
#SingleInstance Force
SetTitleMatchMode, 2



#IfWinActive, Adobe After Effects  ; Use the correct window class identifier

; Create overlay GUI
Gui, +AlwaysOnTop +ToolWindow -Caption +E0x20  ; E0x20 makes the window click-through
Gui, Color, Black
Gui, Font, s14, Arial  ; Increase font size
Gui, Add, Text, vStatusText cWhite, [Wheel Button] Play`n[Wheel] Scroll through the timeline`n[Hold Left Click + Wheel] Move frame by frame`n[Upper Side Mouse Button] Split`n[Lower Side Mouse Button] Delete`n[Hold Left + Right Click] Menu  ; Add instructions
Gui, Show, NoActivate x10 y130 AutoSize, StatusOverlay  ; Show the GUI with AutoSize and position it 100 pixels lower
WinSet, Transparent, 200, StatusOverlay  ; Set transparency to 200 (range 0-255)

; Create context menu
Menu, MyContextMenu, Add, Undo (Ctrl + Z), HandleMenuClick
Menu, MyContextMenu, Add, Redo (Ctrl + Shift + Z), HandleMenuClick
Menu, MyContextMenu, Add, Save Project (Ctrl + S), HandleMenuClick

; Variables to store menu position
global MenuX := 0
global MenuY := 0
global MenuOpened := false

; Handlers for menu items
HandleMenuClick:
    if (A_ThisMenuItem = "Undo (Ctrl + Z)") {
        Send, ^z
        UpdateStatus("Selected: Undo (Ctrl + Z)")
    } else if (A_ThisMenuItem = "Redo (Ctrl + Shift + Z)") {
        Send, ^+z
        UpdateStatus("Selected: Redo (Ctrl + Shift + Z)")
    } else if (A_ThisMenuItem = "Save Project (Ctrl + S)") {
        Send, ^s
        UpdateStatus("Selected: Save Project (Ctrl + S)")
    }
    SetTimer, ResetStatus, -2000  ; Reset status after 2 seconds
    SetTimer, ReopenMenu, -10
return

CloseContextMenu:
Menu, MyContextMenu, DeleteAll
return

; Show context menu when holding both left and right mouse buttons
~LButton & RButton::
    KeyWait, LButton, T0.5  ; Wait for left mouse button to be held for 0.5 seconds
    if (ErrorLevel) {
        MouseGetPos, MenuX, MenuY
        Menu, MyContextMenu, Show, %MenuX%, %MenuY%
        MenuOpened := true
    }
return

~RButton & LButton::
    KeyWait, RButton, T0.5  ; Wait for right mouse button to be held for 0.5 seconds
    if (ErrorLevel) {
        MouseGetPos, MenuX, MenuY
        Menu, MyContextMenu, Show, %MenuX%, %MenuY%
        MenuOpened := true
    }
return

; Reopen the context menu
ReopenMenu:
if (MenuOpened) {
    Menu, MyContextMenu, Show, %MenuX%, %MenuY%
}
return



; Bind upper side mouse button to Del
XButton1::
Send, {Del}
return

; Bind lower side mouse button to Ctrl + Shift + D
XButton2::
Send, ^+d
return

; Bind WheelUp to Shift + WheelUp
WheelUp::
Send, +{WheelUp}
return

; Bind WheelDown to Shift + WheelDown
WheelDown::
Send, +{WheelDown}
return

; Bind LButton + WheelUp to Ctrl + Left Arrow
~LButton & WheelUp::
Send, {LButton Up}
Send, ^{Left}
return

; Bind LButton + WheelDown to Ctrl + Right Arrow
~LButton & WheelDown::
Send, {LButton Up}
Send, ^{Right}
return

; Bind middle mouse button to Space
MButton::
Send, {Space}
return



; Update status
UpdateStatus(Status) {
    global currentStatus
    if (currentStatus != Status) {
        GuiControl,, StatusText, %Status%
        currentStatus := Status
    }
}

; Reset status
ResetStatus:
UpdateStatus("[Wheel Button] Play`n[Wheel] Scroll through the timeline`n[Hold Left Click + Wheel] Move frame by frame`n[Upper Side Mouse Button] Split`n[Lower Side Mouse Button] Delete`n[Hold Left + Right Click] Menu")
return

; Exit script
Esc::
ExitApp

#IfWinActive  ; End activation condition

