; Environment variables
#NoEnv  
#Warn
#SingleInstance Force
SendMode Input  
SetWorkingDir %A_ScriptDir%  

; Initialise script variables
workerActive := "No"
initialised := false
currentAction := "Idle"
guiPosFile := A_ScriptDir "\gui_position.txt"
whitePixelCordsFile := A_ScriptDir "\white_pixel_cords.txt"
imageFilePath := A_ScriptDir "\HelpImage.png"
guiPosX := 5
guiPosY := 5
xCord := 772
yCord := 596
global guiPosX, guiPosY, xCord, yCord

; Create GUI
Gui, +AlwaysOnTop
Gui, Color, FFFFFF 
Gui, Font, s14
Gui, Add, Tab2, w370 h200, Status||Config
Gui, Add, Text, x25 y50, F1 to activate
Gui, Add, Text, x25 y80, F2 to deactivate
Gui, Add, Text, x25 y110, Script Enabled:
Gui, Add, Text, x160 y110 w100 h30 left vWorkerText, % workerActive
Gui, Add, Text, x25 y140, Current Action: 
Gui, Add, Text, x160 y140 w100 h30 left vActionText, % currentAction 

; tab 2
Gui, Tab, 2
Gui, Add, Text, x25 y50 w350, F7 to run white pixel check to see if it's working properly
Gui, Add, Button, gCaptureWhitePixelCords w350, Click to capture white pixel coordinates
Gui, Add, Text

GetGuiPositionCords(guiPosFile)
GetWhitePixelCords(whitePixelCordsFile)

RunOnGuiShow:
return

; Function to be called when the button is clicked
CaptureWhitePixelCords:
    SplashImage, %imageFilePath%, m2 fm20, ,Right click on a white pixel on the "keep tapping to reel" text., Tip Card
    ;MsgBox, Right click on a white pixel on the "keep tapping to reel" text
    WinActivate, Roblox
    Sleep, 200

    while (WinExist("Tip Card"))
    {
        if (WinExist("Tip Card") = 0)
        {
            break
        }

        Sleep, 100
    }

    Loop
    {
        Sleep, 50
        if (GetKeyState("RButton", "P")) ; Check if the right mouse button is pressed
        {
            break
        }    
    }

    MouseGetPos, MouseX, MouseY
    xCord := MouseX
    yCord := MouseY

    Click, Right, , U
    SaveWhitePixelCords(whitePixelCordsFile, MouseX, MouseY)
    return

F1::
    ; this is to allow the rod to be cast into the water, if there is no bobber icon on the cursor then the rod can't be cast
    WinActivate, Roblox
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
        WinActivate, Roblox
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

GetGuiPositionCords(guiPosFile)
{
    file := FileOpen(guiPosFile, "r")

    if (file)
    {
        content := file.Read()
        file.Close()
        lines := StrSplit(content, ",")
        guiPosX := lines[1]
        guiPosY := lines[2]

        ; bug fix where value saved is -32k, -32k. Not sure why its happening but this will reset positon
        if (guiPosX = -32000 || guiPosY = -32000) 
        {
            guiPosX := 0
            guiPosY := 0 
        }
    }

    Gui, Show, % "x" guiPosX " y" guiPosY " w" 400 " h" 220, Collector's PS99 Fishing Macro, RunOnGuiShow
}

GetWhitePixelCords(whitePixelCordsFile)
{
    file := FileOpen(whitePixelCordsFile, "r")

    if (file)
    {
        content := file.Read()
        file.Close()
        lines := StrSplit(content, ",")
        xCord := lines[1]
        yCord := lines[2]
    
        ; bug fix where value saved is -32k, -32k. Not sure why its happening but this will reset positon
        if (xCord = -32000 || yCord = -32000) 
        {
            MsgBox, File is bugged, please recapture white pixel coordinates
        }
    }
    else
    {
        MsgBox, First time use detected, make sure you go to Config tab on the macro window to set up
    }

    return
}

; Saves position of GUI to config file
SaveGuiPos(guiPosFile)
{
    WinGetPos, OutX, OutY, OutWidth, OutHeight, Collector's PS99 Fishing Macro
    cordfile := FileOpen(guiPosFile, "w")

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

SaveWhitePixelCords(whitePixelCordsFile, xCord, yCord)
{
    cordfile := FileOpen(whitePixelCordsFile, "w")

    if (cordfile) 
    {
        cordfile.Write(xCord "," yCord)
        cordfile.Close()
    } 
    else 
    {
        MsgBox, Failed to open the file for writing.
    }

    MsgBox, Saved coordinates: %xCord%, %yCord%
    WinActivate, Roblox
    return
}

GuiClose: ; Closes the script if you click on the X button on the GUI
    SaveGuiPos(guiPosFile)
    ExitApp
    return

F2:: ; Reloads script, use when you want to stop the macro without closing it
    SaveGuiPos(guiPosFile)
    Reload
    return

F6:: ; F6 to grab coordinates of mouse position, use if you need to change any of the coordinates
    WinActivate, Roblox
    Sleep, 50
    MouseGetPos, MouseX, MouseY
    SaveWhitePixelCords(whitePixelCordsFile, MouseX, MouseY)
    return

F7:: ; white pixel check debug command
    WinActivate, Roblox
    colour := 0xFFFFFF
    PixelSearch, OutputVarX, OutputVarY, %xCord%, %yCord%, %xCord%, %yCord%, %colour%   

    if (ErrorLevel = 0)
    {
        MsgBox, White pixel found
    }
    else if (ErrorLevel = 1)
    {
        MsgBox, White pixel not found, reload the script if you changed it or recapture the coordinates
    }
    else if (ErrorLevel = 2)
    {
        MsgBox, Pixel search failed to execute
    }

