; Environment variables
#NoEnv  
#Warn  
#SingleInstance, Force  
SendMode Input
SetWorkingDir %A_ScriptDir%  

; Initialise script variables
global workerActive, initialised, currentAction, filePath, guiPosX, guiPosY, hasClanBoost, multiplier, fishingZone, whitePixel_xCord, whitePixel_yCord, lbPixel_xCord, lbPixel_yCord, lbHexCode, shanty_xCord, shanty_yCord, forest_xCord, forest_yCord, tp_xCord, tp_yCord, ShantyScrollCount, ForestScrollCount
workerActive := "No"
initialised := false
currentAction := "Idle"
filePath := A_ScriptDir "\config.txt"
guiPosX := 0
guiPosY := 0
multiplier = 1

; ⭐ set these preferences, if you are not in a clan, put false
; ⭐ put 1 for fishing zone 1, put 2 for fishing zone 2, this will tell the script where to take you if you disconnect and rejoin
; ⭐ don't put any of the changes in quotation marks
hasClanBoost = true
fishingZone = 2

; ⭐ use F6 to get coordinates of a white pixel on the "Keep tapping to reel" text and put them here if pixel search is failing
whitePixel_xCord := 772 
whitePixel_yCord := 597

; ⭐ use F6 to get coordinates of the top of the server leaderboard, this is to check if you have rejoined the server after a disconnect
lbPixel_xCord := 1715
lbPixel_yCord := 81

; ⭐ if for whatever reason, your leaderboard colour is very different, or you wish to use something else to check if you are back in the server, you can edit the colour here
; ⭐ you shouldn't need to change this 
lbHexCode := 0x1D1B19 

; ⭐ use F6 to get coordinates of the teleporter icon on the left of the screen
tp_xCord := 176
tp_yCord := 398

; ⭐ F8 will simulate the script going into the map and scrolling a set number of times
; ⭐ set the number of times the scroll button is used when going down the map starting from the top for each location
; ⭐ you probably won't need to change this but you have to option to, just incase
; ⭐ F8 will also use the location set in fishingZone variable as the target
ShantyScrollCount = 5
ForestScrollCount = 20

; ⭐ F8 will allow you to set up the scrolling through map in the event you disconnect from the server
; ⭐ use F6 to get coordinates of the center of the "shanty town" map icon when it comes into view after scrolling
shanty_xCord := 965
shanty_yCord := 528

; ⭐ and the same for "cloud forest" if you have it unlocked
forest_xCord := 760
forest_yCord := 619


; Create GUI
Gui, +AlwaysOnTop
Gui, Color, FFFFFF 
Gui, Font, s14
Gui, Add, Text, x10 y10, F1 to activate
Gui, Add, Text, x10 y40, F2 to deactivate
Gui, Add, Text, x10 y70, F6 to get coordinates of mouse position
Gui, Add, Text, x10 y100, F8 to simulate travel to fishing zone
Gui, Add, Text, x10 y130, Script Enabled:
Gui, Add, Text, x140 y130 w100 h30 Left vWorkerText, % workerActive
Gui, Add, Text, x10 y160, Current Action: 
Gui, Add, Text, x140 y160 w250 h60 Left vActionText, % currentAction 

file := FileOpen(filePath, "r")

if (file)
{
    content := file.Read()
    file.Close()
    lines := StrSplit(content, ",")
    guiPosX := lines[1]
    guiPosY := lines[2]

    Gui, Show, % "x" guiPosX " y" guiPosY " w" 400 " h" 220, Collector's PS99 Fishing Macro
}
else 
{
    Gui, Show, w350 h170, Collector's PS99 Fishing Macro
}

F1::
    MainLoop()

MainLoop()
{
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
        
        if (hasClanBoost) ; No need for == true
        {
            multiplier := 1
        }
        else 
        {
            multiplier := 1.2
        }

        MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
        initialised := true
    }

    ; Fishing loop, this is where the magic happens
    while (true)
    { 
        whiteHexCode := 0xFFFFFF
        blackHexCode := 0x000000

        ; Searching for white pixel on the "Keep tapping to reel" text
        PixelSearch, OutputVarX, OutputVarY, %whitePixel_xCord%, %whitePixel_yCord%, %whitePixel_xCord%, %whitePixel_yCord%, %whiteHexCode% 

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
            Click, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2) ; this click does two jobs, casts the line and starts the mini-game if a fish has bitten
            Sleep, 500 ; delay to check if fish has bitten first

            PixelSearch, OutputVarX, OutputVarY, %whitePixel_xCord%, %whitePixel_yCord%, %whitePixel_xCord%, %whitePixel_yCord%, %whiteHexCode%  

            if (ErrorLevel = 1) ; fish has not bitten straight away, delays to make fish bite
            {
                Sleep, 2600
            }
        }

        ; Check if you disconnected from the server 
        ImageSearch, FoundX, FoundY, 779, 440, 883, 476, *10 *Trans10 %A_ScriptDir%\Images\disconnect.png

        if (ErrorLevel = 0)
        {
            GuiControl,, ActionText, Detected disconnection, rejoining
            Rejoin()
        }

        ; To check if Big Games restarted their servers, it kicks you out the fishing area
        ; Reusing lb cords because most of the screen will be black anyway
        PixelSearch, OutputVarX, OutputVarY, %lbPixel_xCord%, %lbPixel_yCord%, %lbPixel_xCord%, %lbPixel_yCord%, %blackHexCode% 
        
        if (ErrorLevel = 0)
        {
            GuiControl,, ActionText, Detected PS99 server reset, awaitng restart
            ReloadCheck(2)
        }
    }

    return
}

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

Rejoin()
{
    Send, !{f4}
    Run, https://www.roblox.com/games/8737899170/
    Sleep, 10000  

    GuiControl,, ActionText, Checking website has loaded
    ImageSearch, OutputCordX, OutputCordY, 1113, 373, 1244, 422, %A_ScriptDir%\Images\playButton.png

    if (ErrorLevel = 0) 
    {
        GuiControl,, ActionText, Joining server
        Click, %OutputCordX%, %OutputCordY%
    }
    else if (ErrorLevel = 1) 
    {
        GuiControl,, ActionText, Webpage not loaded, refreshing
        Sleep, 5000
        Rejoin()
    }
    else if (ErrorLevel = 2)
    {
        MsgBox, Detected issue with image search, please ensure playButton.png is in the Images folder and this script is in the root directory. If you are missing the image, use snipping tool and get an image of the play button on the webpage containing the game. Name it playButton.png and put it in the images folder
    }

    GuiControl,, ActionText, Loading in
    Sleep, 20000

    ReloadCheck(1)
    return
}

; Checks if you have reconnected
; kickedType 1 is due to disconnect from server
; kickedType 2 is due to PS99 servers restarting
ReloadCheck(kickedType)
{
    PixelGetColor, OutputColour, %lbPixel_xCord%, %lbPixel_yCord%

    ; Checks leaderboard pixel in top right 
    if (OutputColour = lbHexCode)
    {
        GuiControl,, ActionText, Loaded in
        Sleep, 5000
        
        ; close browser
        Send, !{Tab}
        Sleep, 200
        Send, !{F4}
        Sleep, 200

        if (fishingZone = 1)
        {
            GoToFishingZone1(kickedType)
        }
        else if (fishingZone = 2)
        {
            GoToFishingZone2(kickedType)
        }
    }
    else ()
    {
        Sleep, 5000
        ReloadCheck(kickedType)
    }

    return
}

; Path to fishing zone 1
GoToFishingZone1(kickedType)
{
    if (kickedType = 1)
    {
        GuiControl,, ActionText, Looking for Shanty Town on map
        ; Open map
        MouseMove, tp_xCord, tp_yCord
        Sleep, 100 
        MouseMove, tp_xCord + 2, tp_yCord
        Sleep, 100
        Click
        MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
        Sleep, 10
        MouseMove, A_ScreenWidth - (A_ScreenWidth / 2) + 2, A_ScreenHeight - (A_ScreenHeight / 2)
        Sleep, 10

        ; Scroll down map
        Loop, %ShantyScrollCount%
        {
            Click, WheelDown
            Sleep, 1000
        }

        ; Enable shanty town buttons
        MouseMove, shanty_xCord, shanty_yCord
        Sleep, 10
        MouseMove, shanty_xCord + 2, shanty_yCord
        Sleep, 10
        Click

        GuiControl,, ActionText, Walking to portal
        ; Walk to portal
        Sleep, multiplier * 8000
        Send, {w Down}{d Down}
        Sleep, multiplier * 3800
        Send, {w Up}
        Sleep, multiplier * 3000
        Send, {d Up} 
        Sleep, 5000
    }
    else if (kickedType = 2)
    {
        GuiControl,, ActionText, Walking to portal
        ; Goes back through portal
        Send, {s Down}
        Sleep, multiplier * 2000
        Send, {s Up}
        Sleep, 5000
    }

    GuiControl,, ActionText, Walking to ocean
    ; Walk to ocean
    Send, {w Down}
    Sleep, multiplier * 5000
    Send, {w Up}
    
    ; Angle camera
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
    Sleep, 10
    Click, right down
    Sleep, 10
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2 - 1)
    Sleep, 10
    Click, right up
    Sleep, 10

    ; Start fishing
    MainLoop()
    return
}

; Path for fishing zone 2
GoToFishingZone2(kickedType)
{
    if (kickedType = 1)
    {
        GuiControl,, ActionText, Looking for Cloud Forest on map
        ; Open map
        MouseMove, tp_xCord, tp_yCord
        Sleep, 100 
        MouseMove, tp_xCord + 2, tp_yCord
        Sleep, 100
        Click
        MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
        Sleep, 10
        MouseMove, A_ScreenWidth - (A_ScreenWidth / 2) + 2, A_ScreenHeight - (A_ScreenHeight / 2)
        Sleep, 10

        ; Scroll down map
        Loop, %ForestScrollCount%
        {
            Click, WheelDown
            Sleep, 1000
        }

        ; Enable cloud forest buttons
        MouseMove, forest_xCord, forest_yCord
        Sleep, 10
        MouseMove, forest_xCord + 2, forest_yCord
        Sleep, 10
        click

        GuiControl,, ActionText, Walking to portal
        ; Walk to portal
        Sleep, multiplier * 8000
        Send, {s Down}
        Sleep, multiplier * 7000
        Send, {s Up}
        Sleep, 10
        Send, {d down} 
        Sleep, multiplier * 3000
        Send, {d up}
        Sleep, 10
        Send, {s down}
        Sleep, multiplier * 1000
        Send, {s up}
        Sleep, 5000
    }
    else if (kickedType = 2)
    {
        GuiControl,, ActionText, Walking to portal
        ; Goes back through portal
        Send, {s Down}
        Sleep, multiplier * 2000
        Send, {s Up}
        Sleep, 5000
    }

    GuiControl,, ActionText, Walking to ocean
    ; Walk to ocean
    Send, {w Down}
    Sleep, multiplier * 8000
    Send, {w Up}
    
    ; Angle camera
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
    Sleep, 10
    Click, right down
    Sleep, 10
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2 - 1)
    Sleep, 10
    Click, right up
    Sleep, 10

    ; Start fishing
    MainLoop()
    return
}

F8::
    GuiControl,, WorkerText, Yes
    if (fishingZone = 1)
        {
            GoToFishingZone1(1)
        }
        else if (fishingZone = 2)
        {
            GoToFishingZone2(1)
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
