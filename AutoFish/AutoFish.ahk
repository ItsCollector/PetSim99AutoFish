; Environment variables
#NoEnv  
#Warn  
SendMode Input  
SetWorkingDir %A_ScriptDir%  

; Initialise script variables
workerActive := "No"
initialised := false
currentAction := "Idle"
filePath := A_ScriptDir "\config.txt"
guiPosX := 0
guiPosY := 0

; use F6 to get coordinates of a white pixel on the "Keep tapping to reel" text and put them here if pixel search is failing
xCord := 772 
yCord := 597

; Create GUI
Gui, +AlwaysOnTop
Gui, Color, FFFFFF 
Gui, Font, s14
Gui, Add, Text, x10 y10, F1 to activate
Gui, Add, Text, x10 y40, F2 to deactivate
Gui, Add, Text, x10 y70, F6 to get coordinates of mouse position
Gui, Add, Text, x10 y100, Script Enabled:
Gui, Add, Text, x140 y100 w100 h30 Center vWorkerText, % workerActive
Gui, Add, Text, x10 y130, Current Action: 
Gui, Add, Text, x140 y130 w100 h30 Center vActionText, % currentAction 

file := FileOpen(filePath, "r")

if (file)
{
    content := file.Read()
    file.Close()
    lines := StrSplit(content, ",")
    guiPosX := lines[1]
    guiPosY := lines[2]

    Gui, Show, % "x" guiPosX " y" guiPosY " w" 350 " h" 170, Collector's PS99 Fishing Macro
}
else 
{
    Gui, Show, w350 h170, Collector's PS99 Fishing Macro
}

F1::
    ; this is to allow the rod to be cast into the water, if there is no bobber icon on the cursor then the rod can't be cast
    if (initialised = false) 
    {
        GuiControl,, ActionText, Initialising
        GuiControl,, WorkerText, Yes

        Loop, 3
            {
                MouseMove, A_ScreenWidth - (A_ScreenWidth / 3), A_ScreenHeight - (A_ScreenHeight * 0.6)
                Sleep, 100
                MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight * 0.6)
                Sleep, 100
            }
        
        MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
        initialised := true
    }

    ; Fishing loop, this is where the magic happens
    while (true)
    { 
        ; Coordinates and colour hex for a white pixel when the fishing mini-games shows ingame
        ; Change these if you are not on 1920x1080p, use F6 to grab any white pixel from mini-game text around the bottom
        ; middle of screen
        colour := 0xFFFFFF

        PixelSearch, OutputVarX, OutputVarY, %xCord%, %yCord%, %xCord%, %yCord%, %colour% 

        if (ErrorLevel = 0) ; fish has bitten the rod
        {
            GuiControl,, ActionText, Reeling fish

            Loop, 5 ; reels in fish
            {
                Click, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
                Sleep, 10
            }  
        }
        
        if (ErrorLevel = 1) ; fish has not bitten the rod
        {   
            GuiControl,, ActionText, Casting line

            Sleep, 500 ; delay for after reeling in fish 
            Click, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
            Sleep, 500 ; delay to check if fish has bitten first

            PixelSearch, OutputVarX, OutputVarY, %xCord%, %yCord%, %xCord%, %yCord%, %colour% 

            if (ErrorLevel = 1) ; fish has not bitten straight away, delays to make fish bite
            {
                Sleep, 2600
            }
        }
    }

    return

; Saves position of GUI to config file
SaveGuiPos(filePath)
{
    WinGetPos, OutX, OutY, OutWidth, OutHeight, Collector's PS99 Fishing Macro
    cordfile := FileOpen(filePath, "w")

    if (cordfile) 
    {
        cordfile.Write(OutX "," OutY)
        cordfile.Close()
    } 
    else 
    {
        MsgBox, Failed to open the file for writing.
    }

    return
}

GuiClose: ; Closes the script if you click on the X button on the GUI
    SaveGuiPos(filePath)
    ExitApp
    return

F2:: ; Reloads script, use when you want to stop the macro without closing it
    SaveGuiPos(filePath)
    Reload
    return

F6:: ; F6 to grab coordinates of mouse position, use if you need to change any of the coordinates
    MouseGetPos, MouseX, MouseY
    MsgBox, Mouse Coordinates:`nX: %MouseX%`nY: %MouseY%
    return

; In the process of debugging
F8::
    ImageSearch, FoundX, FoundY, 779, 440, 883, 476, *10 *Trans10 %A_ScriptDir%\Images\disconnect.png

    if (ErrorLevel = 0)
    {
        Send, !{f4}
        Run, https://www.roblox.com/games/8737899170/
        Sleep, 10000  
        Click, 1183, 398
        Sleep, 40000
        
        ImageSearch, FoundX, FoundY, 1753, 709, 1836, 719, *10 *Trans10 %A_ScriptDir%\Images\rewards.png
        
        if (ErrorLevel = 0)
        {
            MouseMove, 176, 398
            Sleep, 100 
            MouseMove, 178, 398
            Sleep, 100
            Click
            MouseMove, 970, 541
            Sleep, 10
            MouseMove, 972, 541
            Sleep, 10
            Loop, 5
            {
                Click, WheelDown
                Sleep, 1000
            }
            MouseMove, 965, 528
            Sleep, 10
            MouseMove, 967, 528
            Sleep, 10
            Click
            Sleep, 8000
            Send, {w Down}{d Down}
            Sleep, 4000
            Send, {w Up}
            Sleep, 3000
            Send, {d Up} 
        }
        else 
        {
            MsgBox, Failed to find reward image
        }
    }

    return

; In the process of debugging
F9::
    ImageSearch, FoundX, FoundY, 1753, 709, 1836, 719, *10 *Trans10 %A_ScriptDir%\Images\rewards.png

    if (ErrorLevel = 0)
    {
        MouseMove, 176, 398
        Sleep, 100 
        MouseMove, 178, 398
        Sleep, 100
        Click
        MouseMove, 970, 541
        Sleep, 10
        MouseMove, 972, 541
        Sleep, 10
        Loop, 5
        {
            Click, WheelDown
            Sleep, 1000
        }
        MouseMove, 965, 528
        Sleep, 10
        MouseMove, 967, 528
        Sleep, 10
        Click
        Sleep, 8000
        Send, {w Down}{d Down}
        Sleep, 4000
        Send, {w Up}
        Sleep, 3000
        Send, {d Up} 
    }
    else if (ErrorLevel = 2)
    {
        MsgBox, Failed to search for image
    }
    else 
    {
        MsgBox, Failed to find image
    }

    
    return