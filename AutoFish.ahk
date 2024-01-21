; Environment variables
#NoEnv  
#Warn  
SendMode Input  
SetWorkingDir %A_ScriptDir%  

; Initialise script variables
workerActive := "Inactive"
initialised := false
currentAction := "Idle" ; Variable to store the current action

; Create GUI
Gui, +AlwaysOnTop
Gui, Color, FFFFFF 
Gui, Font, s14
Gui, Add, Text, x10 y10, F1 to activate
Gui, Add, Text, x10 y40, F2 to deactivate
Gui, Add, Text, x10 y70, Script Enabled:
Gui, Add, Text, x140 y70 w100 h30 Center vWorkerText, % workerActive
Gui, Add, Text, x10 y100, Current Action: 
Gui, Add, Text, x140 y100 w100 h30 Center vActionText, % currentAction 

; If you wish to change the default location of the GUI, edit the X and Y variables of the line below
; Bare in mind, it takes your screen resolution and takes away another number
; the bigger the number, the further left or up it will be
Gui, Show, % "x" A_ScreenWidth - 1900 " y" A_ScreenHeight - 1060 " w" 300 " h" 160, Script Status

F1::
    ; this is to allow the rod to be cast into the water, without this, the macro gets stuck
    ; Preston has implemented lots of weird buttons and things which need mouse movement to be possible to click on
    if (initialised = false) 
    {
        GuiControl,, ActionText, Initialising
        GuiControl,, WorkerText, Active

        ; Set up action to enable fishing
        Loop, 3
            {
                MouseMove, 850, 450
                Sleep, 100
                MouseMove, 950, 450
                Sleep, 100
            }
        
        initialised := true
    }

    ; Fishing loop, this is where the magic happens
    while (true)
    { 
        ; Coordinates and colour hex for a white pixel when the fishing mini-games shows ingame
        ; Change these if you are not on 1920x1080p, use F6 to grab any white pixel from mini-game text around the bottom
        ; middle of screen
        xCord := 772
        yCord := 597
        colour := 0xFFFFFF

        PixelSearch, OutputVarX, OutputVarY, %xCord%, %yCord%, %xCord%, %yCord%, %colour% 

        if (ErrorLevel = 0) ; fish has bitten the rod
        {
            GuiControl,, ActionText, Reeling fish

            Loop, 5 ; reels in fish
            {
                Click, 960, 540 ; this is the center of the screen
                Sleep, 10
            }  
        }
        
        if (ErrorLevel = 1) ; fish has not bitten the rod
        {   
            GuiControl,, ActionText, Casting line

            Sleep, 500 ; delay for after reeling in fish 
            Click, 960, 540 
            Sleep, 500 ; delay to check if fish has bitten first

            PixelSearch, OutputVarX, OutputVarY, %xCord%, %yCord%, %xCord%, %yCord%, %colour% 

            if (ErrorLevel = 1) ; fish has not bitten straight away, delays to make fish bite
            {
                Sleep, 2600
            }
        }
    }

    return

GuiClose: ; Closes the script if you click on the X button on the GUI
    ExitApp
    return

F2:: ; Reloads script, use when you want to stop the macro without closing it
    Reload
    return

F6:: ; F6 to grab coordinates of mouse position, use if you need to change any of the coordinates
    MouseGetPos, MouseX, MouseY
    MsgBox, Mouse Coordinates:`nX: %MouseX%`nY: %MouseY%
    return
