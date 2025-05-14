#Requires AutoHotkey v2.0
CoordMode "Mouse", "Screen"
SendMode "Event"
#Include  "lib\DiscordBuilderAHK-0.0.1.1\DiscordBuilder.ahk"
#Include "lib\FindText.ahk"
#Include "lib\Image.ahk"
#Include "lib\AHKv2-Gdip-master\Gdip_All.ahk"
#Include "lib\JSON.ahk"
#Include "lib\OCR-main\Lib\OCR.ahk"
#NoTrayIcon
global StageStartTime := 0
essenceSpots := Map(
    1, {x: 238, y: 450 },
    2, {x: 431, y: 452 },
    3, {x: 608, y: 248 },
    4, {x: 614, y: 351 },
    5, {x: 614, y: 463 }
)
global elementToEssence := Map(
    "Fire",  "FireEssence",
    "Dark",  "DarkEssence",
    "Light", "LightEssence",
    "Water", "WaterEssence",
    "Nature","NatureEssence"
)
essences := Map(
    "DarkEssence",  "|<>*111$79.zzzzzzzzzzzzzzzzzzzzzzzzzzwDzyDs7zzzzzzw1zz7s3zzzzzzy8TzXwTzzzzzzz7801C3kkkEA47XY0070tNM0221lkEA7UQA80MC0sk8a3lz746A71y1UHUw3331aEET1sPqS1VVkrAQDzzzzzzzzzzzzzzzzzzzzzzzzzzk",
    "LightEssence", "|<>*106$81.zzzzzzzzzzzzzzzzzzzzzzzzzzzrlz7vw3zzzzzzwTTsyT0TzzzzzzXzz7lszzzrzzxwS80471sMM8623Xl000s7//00EEAS30mT0sME0kQ1Xk86HszXW163UQ384m7UMMMAm23k/ViMw333ViMsTzzDzzzzzzzzzzzz1zzzzzzzzzzzzyzzzzzzzzzzzU",
    "FireEssence",  "|<>*111$74.zzzzzzzzzzzzzzzzzzzzzzzzz07zzUTzzzzzzU3zzk7zzzzzzszzzwTzzzzzzy308D1sMM8623UE21kCKK00UUM430Q3VV031k6D0kT7wQEMkQ7ntC3s6663AUUxyrky1VVkrAQDzzzzzzzzzzzzzzzzzzzzzzzzs",
    "NatureEssence","|<>*109$94.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxtzvzzzy1zzzzzzzXbzDzzzk7zzzzzzy6TwTzzz7zzzzzzzs9U060Uw7VVUUM8DU600M21kCKK00UUS8F4lUk70sME0kQ1sV4HYH1wTll1X1kTn6121C3s6663AUUzSQCAZwDUMMQBn73zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy",
    "WaterEssence", "|<>*110$89.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzziRzrzzs7zzzzzzyAlzDzzUDzzzzzzyEbyDzz7zzzzzzzwV8088C3kkkEA47s0E0E0Q3ZZU0887s14H03s732063UDlW8a37lz746A71zX6123DkAAA6N11zjS766zUMMQBn73zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
)
foundEssences := Map()
global SlotColors := Map(
    1, "0xFF2E2E",     ; 🟥 Red (Slot 1)
    2, "0xFF944C",     ; 🟧 Orange (Slot 2)
    3, "0xFFE866",     ; 🟨 Yellow (Slot 3)
    4, "0x00FF33",     ; 🟩 Green (Slot 4)
    5, "0x0040FF",     ; 🟦 Blue (Slot 5)
    6, "0xFF33FF"      ; 🟪 Magenta (Slot 6)
)
global UnitGuideGUI
global InfRoom := 0
global CurrentGuideIndex := 1
global PageOrder := ["Simple", "Advanced", "Summary", "Markers", "Placement", "Upgrade"]
global PageImages := Map(
    "Simple",    A_ScriptDir "\lib\images\page1.png",
    "Advanced",  A_ScriptDir "\lib\images\page2.png",
    "Summary",   A_ScriptDir "\lib\images\page3.png",
    "Markers",   A_ScriptDir "\lib\images\page4.png",
    "Placement", A_ScriptDir "\lib\images\page5.png",
    "Upgrade",   A_ScriptDir "\lib\images\page6.png"
)
global ImageControl := 0
GuiExist(gui) {
    try {
        return gui != "" && gui.Hwnd != ""
    } catch {
        return false
    }
}
global DraggingMarker := ""
global FailCount := 0
global SuccessCount := 0
global TotalRuns := 0
global MarkerMap := Map()
global IsUnitGuideVisible := false
global DragPreviewX := 0
global DragPreviewY := 0
global x1 := 0 
global UpgMode := "Multi"
global GuiState := Map()
global y1 := 0 
global x2 := A_ScreenWidth
global isSelectingCoords := false
global y2 := A_ScreenHeight
global MacroRuntime := A_TickCount
global wins := 0
global loss := 0
global Winrate := 0
global AvgTime := 0
global TargetPage := 0
global TargetUnit := 0
global UnitPage := 1
global SettingsPage := 1
global RetryPic := "lib\images\retry.png"
global NextPic := "lib\images\Next.png"
global StoryWinPic := "lib\images\StoryWin.png"
global StartPic := "lib\images\Start.png"
#SingleInstance Force
global robloxWin := "ahk_exe RobloxPlayerBeta.exe"
global fendilogo := "lib\images\logo.png"
global StatsControls := []
global ModeSettingsControls := []
global unitControls := Map()
TraySetIcon(fendilogo)
SetWorkingDir A_ScriptDir
global uiBorders := []
global uiTheme := []
global F1Key := "F1"
global F2Key := "F2"
global F3Key := "F3"
Hotkey(F1Key, (*) => Zoom())
Hotkey(F2Key, (*) => StartMacro())
Hotkey(F3Key, (*) => Reload())
uiTheme.Push("0xffffff") 
SetTimer(HandleStatControls, 1000)
global MainGUI := Gui("-Caption ")
MainGUI.BackColor := 0x1E1E1E
MainGUI.SetFont("", "Segoe UI bold")

global game := "Anime Last Stand"
global ver := "2.0.0"       
global Creator := "Fendi"
TitleMsg := Creator " " game " v" ver
global title := MainGui.AddText("w300 h24 x5 y3 BackgroundTrans", TitleMsg)
title.SetFont("s14 cffffff")

global PageTitle := MainGui.AddText("w120 h24 x1170 y3 BackgroundTrans", "Unit " UnitPage)
PageTitle.Visible := true
PageTitle.SetFont("s16 cffffff")

global SettingsTitleMain := MainGui.AddText("w1000 h54 x1030 y312 BackgroundTrans", "Main Settings")
SettingsTitleMain.Visible := true
SettingsTitleMain.SetFont("s16 cffffff")

global SettingsTitleMode := MainGui.AddText("w1000 h54 x1230 y312 BackgroundTrans", "Mode Settings")
SettingsTitleMode.Visible := true
SettingsTitleMode.SetFont("s16 cffffff")

global modeDDL := MainGui.AddDropDownList("x1005 y348 w120", ["Legend Stage", "Story", "Raids", "Cavern", "Portals"])
modeDDL.SetFont("s9 cffffff")
modeDDL.Visible := true

global mapDDL := MainGui.AddDropDownList("x1005 y378 w120", [])
mapDDL.SetFont("s9 cffffff")
mapDDL.Visible := false

global actDDL := MainGui.AddDropDownList("x1005 y408 w120", [])
actDDL.SetFont("s9 cffffff")
actDDL.Visible := false

modeDDL.OnEvent("Change", ModeChanged)
mapDDL.OnEvent("Change", MapChanged)
actDDL.OnEvent("Change", ActChanged)

; MAIN SETTINGS SEPERATORS

global SelectedModeText := MainGui.AddText("x1005 y348 w200 cffffff BackgroundTrans", "")
SelectedModeText.SetFont("s9")
SelectedModeText.Visible := false

global HotkeyHintText := MainGui.AddText("x1005 y370 w190 h100 c0xaaaaaa BackgroundTrans", "F1: Fix Roblox`nF2: Start Macro`nF3: Restart Macro")
HotkeyHintText.SetFont("s10")
HotkeyHintText.Visible := false

global ConfirmModeBtn := MainGui.AddButton("x1140 y415 w90 h22", "Confirm")
ConfirmModeBtn.SetFont("s9")
ConfirmModeBtn.Visible := false

global StatsText := MainGUI.AddText("x1005 y432 w1000 h50 cffffff BackgroundTrans", "Wins: 0 | Losses: 0 | Total: 0")
StatsText.SetFont("s9")

global WinRateText := MainGUI.AddText("x1005 y449 w1000 h50 cffffff BackgroundTrans", "Winrate: 0%")
WinRateText.SetFont("s9")

global AvgStageTimeText := MainGUI.AddText("x1005 y466 w1000 h30 cffffff BackgroundTrans", "Avrg Stage Time: 0m 0s")
AvgStageTimeText.SetFont("s9")

global MacroRunTimeText := MainGUI.AddText("x1005 y483 w1000 h50 cffffff BackgroundTrans", "Macro Runtime: 0d 0h 0m 0s")
MacroRunTimeText.SetFont("s9")

global WebhookEnabled := MainGui.AddCheckbox("x1005 y505 w80 h20 cffffff", "Webhook")
WebhookEnabled.SetFont("s9")

global PingUser := MainGui.AddCheckbox("x1103 y508 cffffff", "Ping")
PingUser.SetFont("s9")

global DiscordUserIDEdit := MainGui.AddEdit("x1005 y551 w80 h22", "User ID")
DiscordUserIDEdit.SetFont("s9")

global WebhookURLEdit := MainGui.AddEdit("x1005 y525 w135 h22", "Webhook URL")
WebhookURLEdit.SetFont("s9")

global TestWebhookBtn := MainGui.AddButton("x1086 y551 w53 h22", "Test")
TestWebhookBtn.OnEvent("Click", (*) => SendTestWebhook())
global SendScreenshot := MainGui.AddCheckbox("x1005 y575 w135 h22 cffffff", "Screenshot")
SendScreenshot.SetFont("s9")

global AutoAbility := MainGUI.AddCheckbox("x1309 y405 w80 h20 cffffff", "Auto Ability")

global NextPageBtn := MainGui.AddButton("x1345 y6 w50 h20", ">>")
NextPageBtn.SetFont("s9")
NextPageBtn.Visible := true 
NextPageBtn.OnEvent("Click", (*) => NextPageFunc())

global PrevPageBtn := MainGui.AddButton("x1005 y6 w50 h20", "<<")
PrevPageBtn.SetFont("s9")
PrevPageBtn.Visible := true
PrevPageBtn.OnEvent("Click", (*) => PrevPageFunc())
btnW := 94
gap := 5
startX := 1005 

global LoadedDelay := MainGUI.AddEdit("x1365 y435 w20 h20 Number Limit2", "2")
LoadedDelayDesc := MainGUI.AddText("x1270 y438 w10000 h50 BackgroundTrans cffffff", "Delay after Loaded:")

global DebugBtn := MainGUI.AddButton("x" startX " y605 w" btnW " h20", "Debug Macro")
DebugBtn.OnEvent("Click", (*) => debug())
global SaveSettingsBtn := MainGUI.AddButton("x" (startX + btnW + gap) " y605 w" btnW " h20", "Save Settings")
global UnitGuideBtn := MainGUI.AddButton("x" (startX + (btnW + gap) * 2) " y605 w" btnW " h20", "Unit Guide")
global SaveCoordsBtn := MainGUI.AddButton("x" (startX + (btnW + gap) * 3) " y605 w" btnW " h20", "Save Units")
SaveCoordsBtn.Enabled := false
UnitGuideBtn.OnEvent("Click", (*) => ToggleUnitGuide())
SaveCoordsBtn.OnEvent("Click", SaveUnitLayout)
SaveSettingsBtn.OnEvent("Click", SaveSettings)
global DifSwitch := MainGUI.AddDropDownList("x1205 y380 w92 Choose2", ["Normal", "Nightmare", "Purgatory"])
global UpgModeLable := MainGUI.AddText("x1305 y383 w1000 h50 cffffff BackgroundTrans", "Upg: ")
global PrioPlaceBtn := MainGUI.AddButton("x1205 y348 w92", "Priority Place")
global PrioUpgrBtn := MainGUI.AddButton("x1302 y348 w92", "Priority Upgrade")
PrioPlaceBtn.OnEvent("Click", (*) => showPlacePrioGui()) 
PrioUpgrBtn.OnEvent("Click", (*) => togglePrioGui()) 
UpgModeLable.SetFont("s9 bold")
global UpgModeSelect := MainGUI.AddButton("x1338 y381 h20 w50", "Multi")
UpgModeSelect.OnEvent("Click", (*) => ChangeUpgMode())
ModeSettingsControls.Push(SendScreenshot)
ModeSettingsControls.Push(WebhookEnabled)
ModeSettingsControls.Push(PingUser)
ModeSettingsControls.Push(WebhookURLEdit)
ModeSettingsControls.Push(DiscordUserIDEdit)
ModeSettingsControls.Push(TestWebhookBtn)
ModeSettingsControls.Push(DebugBtn)
ModeSettingsControls.Push(SaveSettingsBtn)
ModeSettingsControls.Push(UnitGuideBtn)
ModeSettingsControls.Push(SaveCoordsBtn)
DifSwitch.Visible := false
for ctrl in ModeSettingsControls 
    ctrl.Visible := false

SlowType(text, delay := 43) {
    for char in StrSplit(text)
    {
        SendInput(char)
        Sleep(delay)
    }
}

StartPortal(portal) {
    if IsInLobby() {
        Sleep(500)
        FixClick(87, 317) ; open items
        Sleep(500)
        FixClick(190, 219)
        Sleep(200)
        FixClick(369, 183)
        Sleep(300)
        SlowType(portal)
        Sleep(100)
        FixClick(315, 256)
        Sleep(150)
        FixClick(755, 529)
        Sleep(250)
        PortalStart:="|<>*102$71.000000000000000000000000000000000000000000000000000000000000000000000000Dz00CDC00000zz00yTy00001VazzBX7zz0021DzyT6Dzz00AQ660C4Mar00A8880Q0U0600Q9UFns000M01qH0Xbl020k030X177X4430033a2T7CMQa007zzzrvzzzw003vzz7XbzTk000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
        x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
        FixClick(87, 463)
        FixClick(87, 463)
        FixClick(87, 463)
        while ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, PortalStart) {
            FixClick(87, 463)
            FixClick(87, 463)
            FixClick(87, 463)
            Sleep(100)
        }
    return
    }
    MsgBox("Lobby not found")
}

ChallengeMode() {

}

PortalMode() {
    global modeDDL, mapDDL
    StartPortal(mapDDL.Text)
    CheckLoaded()
    SetupGame()
    PlacingUnits()
}

LegendMode() {
    legendmovement()
    CheckLoaded()
    SetupGame()
    PlacingUnits()
}

EasterMode() {
    EasterMovement()
    CheckLoaded()
    SetupGame()
    PlacingUnits()
}

InfCastleMode() {

}

RaidMode() {
    RaidMovement()
    CheckLoaded()
    SetupGame()
    PlacingUnits()
}

StoryMode() {
    PlayMovement()
    CheckLoaded
    SetupGame()
    PlacingUnits()
}

CavernMode() {
    CavernMovement()
    CheckLoaded()
    SetupGame()
    PlacingUnits()
}

SurvivalMode() {
    SurvMovement()
    CheckLoaded()
    SetupGame()
    PlacingUnits()
}

InfinityCastleMovement() {
global InfCastleGui, InfCastleGui1, InfCastleGui2, DifSwitch
TpToSummon()
HoldKey("d", 230)
SendEvent("Q")
HoldKey("W", 1400)
if ok:=FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, InfCastleGui) || FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, InfCastleGui1) || FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, InfCastleGui2) {
    if DifSwitch.Text = "Hard" {
        FixClick(438, 474)
    }
}
}

RaidMovement() {
    global RaidAngle1, RaidAngle2, BoxConfirm1, BoxConfirm2
    TpToRaid()
    SendInput("{S Down}")    
    Sleep(3000)
    SendInput("{S Up}")  
    found1 := FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, BoxConfirm1)
    found2 := FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, BoxConfirm2)

if !found1 && !found2 {
    TpToRaid()
    Sleep(175)

    dirs := ["A", "S"]
    success := false

    Loop 4 {
        dir := dirs[(A_Index + 1) // 2]  ; each key gets two attempts
        SendInput("{" dir " Down}")
        Sleep(3000)
        SendInput("{" dir " Up}")

        found1 := FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, BoxConfirm1)
        found2 := FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, BoxConfirm2)
        if found1 || found2 {
            success := true
            break
        }
    }

    if !success {
        MsgBox("Couldn't locate confirmation box after movement attempts.")
        return
    }
}
global MapDDL
mapName := MapDDL.Text
MapCoords := GetMapCoords(mapName)
FixClick(345, 350)
if MapCoords {
    Loop MapCoords.scroll {
        SendInput("{WheelDown}")
        Sleep(200)
    }

    ; Now click the map location
    FixClick(MapCoords.x, MapCoords.y)
}
Sleep(175)

global ActDDL
act := ActDDL.Text
ActCoords := GetActCoords(act)
FixClick(ActCoords.x, ActCoords.y)
Sleep(175)
FixClick(497, 444)
Sleep(175)
FixClick(497, 444)
}

Pixel(color, x1, y1, addx1, addy1, variation) {
    global foundX, foundY
    try {
        if PixelSearch(&foundX, &foundY, x1, y1, x1 + addx1, y1 + addy1, color, variation) {
            return [foundX, foundY] AND true
        }
        return false
    } catch Error as e {
        MsgBox("Error in Pixel: " e.Message)
        return false
    }
}

CavernMovement() {
    global mapDDL
    TpToPlay()
    SendInput("{S Down}") 
    Sleep(500) 
    SendInput("{S Up}")
    SendInput("{A Down}") 
    Sleep(160)
    SendInput("{A Up}")
    SendInput("Q")
    Sleep(1500)
    x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
    if (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, CavernConfirm))
    {
        element := mapDDL.Text
        checkEssences()
        Sleep(500)
        HandleDifficulty()
        Sleep(1000)
        FixClick(499, 472)
        while (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, TelBtn4)) || (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, TelBtn3)) {  
            FixClick(732, 492)
            Sleep(375)
        }
    }else {
        global TelBtn4, TelBtn3
        TpToPlay()
        SendInput("{A Down}") 
        Sleep(500) 
        SendInput("{A Up}")
        SendInput("{W Down}") 
        Sleep(200)
        SendInput("{W Up}")
        SendInput("Q")
        SendInput("{W Down}") 
        Sleep(200)
        SendInput("{W Up}")
        Sleep(2500)

        checkEssences()
        HandleDifficulty()
        Sleep(1000)
        FixClick(499, 472)
        x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
        while (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, TelBtn4)) || (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, TelBtn3)) {  
            FixClick(732, 492)
            Sleep(375)
        }
    }
}

checkEssences() {
    global essenceSpots, essences, mapDDL, elementToEssence
    local chosen := elementToEssence[mapDDL.Text]
    x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight

    for spot, pos in essenceSpots {
        FixMove(pos.x, pos.y)
        Sleep(100)
        for name, pattern in essences {
            if FindText(&X, &Y, x1, y1, x2, y2, 0, 0, pattern) {
                if (name = chosen) {
                    FixClick(pos.x, pos.y)
                    return true
                }
                break
            }
        }
    }
    return false
}

LegendMovement() {
    TpToPlay()
    SendInput("{S Down}")
    SendInput("{A Down}") 
    Sleep(1000) 
    SendInput("{A Up}")  
    Sleep(3000) 
    SendInput("{S Up}") 
    found1 := FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, StoryConfirm)
    found2 := FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, StoryConfirm)
    if !found1 && !found2 {
        TpToPlay()
        Sleep(175)
    
        dirs := ["D", "S"]
        success := false
    
        Loop 4 {
            dir := dirs[(A_Index + 1) // 2]  ; each key gets two attempts
            SendInput("{" dir " Down}")
            Sleep(3000)
            SendInput("{" dir " Up}")
    
            found1 := FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, StoryConfirm)
            found2 := FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, StoryConfirm)
            if found1 || found2 {
                success := true
                break
            }
        }
    
        if !success {
            MsgBox("Couldn't locate confirmation box after movement attempts.")
            return
        }
    }
    Sleep(175)
    FixClick(700, 150)
    global MapDDL
    mapName := MapDDL.Text
    if (mapName = "Oasis")
        mapName := "OasisLeg"
    else if (mapName = "Babylon")
        mapName := "BabylonLeg"
    else if (mapName = "Harge Forest")
        mapName := "Harge ForestLeg"
    MapCoords := GetMapCoords(mapName)
    FixClick(345, 350)
    if MapCoords {
        Loop MapCoords.scroll {
            SendInput("{WheelDown}")
            Sleep(200)
        }

        ; Now click the map location
        FixClick(MapCoords.x, MapCoords.y)
    }
    Sleep(175)
    
    global ActDDL
    act := ActDDL.Text
    ActCoords := GetActCoords(act)
    FixClick(ActCoords.x, ActCoords.y)
    Sleep(175)
    FixClick(497, 444)
    Sleep(175)
    x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
    while (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, TelBtn)) || (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, TelBtn2)) {  
      FixClick(497, 434)
      Sleep(375)
    }
}

PlayMovement() {
    global DifSwitch
    TpToPlay()
    SendInput("{S Down}")
    SendInput("{A Down}") 
    Sleep(1000) 
    SendInput("{A Up}")  
    Sleep(3000) 
    SendInput("{S Up}") 
    found1 := FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, StoryConfirm)
    found2 := FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, StoryConfirm)
    if !found1 && !found2 {
        TpToPlay()
        Sleep(175)
    
        dirs := ["D", "S"]
        success := false
    
        Loop 4 {
            dir := dirs[(A_Index + 1) // 2]  ; each key gets two attempts
            SendInput("{" dir " Down}")
            Sleep(3000)
            SendInput("{" dir " Up}")
    
            found1 := FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, StoryConfirm)
            found2 := FindText(&X, &Y, 496-150000, 450-150000, 496+150000, 450+150000, 0, 0, StoryConfirm)
            if found1 || found2 {
                success := true
                break
            }
        }
    
        if !success {
            MsgBox("Couldn't locate confirmation box after movement attempts.")
            return
        }
    }
    Sleep(175)
    global MapDDL
    mapName := MapDDL.Text
    if mapName = "Unknown Planet"
        mapName := "UnknownStory"
    MapCoords := GetMapCoords(mapName)
    FixClick(345, 350)
    if MapCoords {
        Loop MapCoords.scroll {
            SendInput("{WheelDown}")
            Sleep(200)
        }
        ; Now click the map location
        FixClick(MapCoords.x, MapCoords.y)
    }
    Sleep(175)
    
    global ActDDL
    act := ActDDL.Text
    ActCoords := GetActCoords(act)
    FixClick(ActCoords.x, ActCoords.y)
    Sleep(175)
    HandleDifficulty()
    Sleep(175)
    FixClick(497, 444)
    Sleep(175)
    x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
    while (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, TelBtn)) || (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, TelBtn2)) {  
      FixClick(497, 434)
      Sleep(375)
    }
}

SurvMovement() {
    global modeDDL, actDDL, mapDDL
    act := actDDL.Text
    TpToRaid()
    FixClick(500, 515)
    SendInput("{D Down}") 
    Sleep 3300
    SendInput("{D Up}") 
    x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
    if (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, SurvConfirm1)) 
    || (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, SurvConfirm2))
    || (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, SurvConfirm3)) {
        HandleDifficulty()
        Sleep(100)
        MapCoords := GetMapCoords(mapDDL.Text)
        if MapCoords {
            FixClick(MapCoords.x, MapCoords.y)
        }
        sleep 400
        FixClick(262, 475)
        sleep 400
        FixClick(740, 459)
    }else {
        TpToRaid()
        FixClick(500, 515)
        SendInput("{W Down}") 
        Sleep 3300
        SendInput("{W Up}")
        sleep 200
        HandleDifficulty()
        Sleep(1500)
        FixClick(262, 475)
        sleep 400
        FixClick(740, 459)
    }
}

IsInLobby() {
    x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
    return (ok:=FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, LobbyText))
}

EasterMovement() {
    if !IsInLobby() {
        MsgBox("Lobby NOT found, (Fix ur resolution: 1920x1080 || 100%)")
        return
    }
    FixClick(57, 480)
    sleep 350
    FixClick(392, 184)
    sleep 900
    FixClick(498, 475)
}

TpToSummon() {
    FixClick(132,372)
    Sleep(175)
    FixClick(40, 360)
    Sleep(175)
    FixClick(363, 340)
    Sleep(175)
    FixClick(495, 206)
    Sleep(175)
    FixClick(620, 140)
}

TpToRaid() {
    FixClick(132,372)
    Sleep(175)
    FixClick(40, 360)
    Sleep(175)
    FixClick(363, 340)
    loop 2 {
        Sleep(75)
        SendInput("{WheelDown}")
    }
    Sleep(225)
    FixClick(500, 400)
    Sleep(175)
    FixClick(620, 140)
}

TpToPlay() {
    FixClick(132,372)
    Sleep(175)
    FixClick(40, 360)
    Sleep(175)
    FixClick(363, 340)
    Sleep(175)
    FixClick(495, 360)
    Sleep(175)
    FixClick(620, 140)
}

BClick(to_x, to_y, button := "Left") {
    MouseMove(x, y)
    Sleep(100)
    MouseMove(1, 0, , "R")
    Sleep(150)
    MouseClick("Left", -1, 0, , , , "R")
    Sleep(50)
}

MoveForNoName() {
    FixClick(599, 72, "Right")
    Sleep(4000)
    FixClick(631, 285, "Right")
    Sleep(3000)
}

MoveForU18() {
    FixClick(826, 130, "Right")
    Sleep(4000)
}

MoveForCentralCity() {
    FixClick(499, 61, "Right")
    Sleep(4000)
}

MoveForOasis() {
    FixClick(607, 91, "Right")
    Sleep(4000)
}

MoveForCarvern() {
    FixClick(988, 561, "Right")
    Sleep(13000)
    FixClick(575, 182, "Right")
    Sleep(5000)
}

MoveForUnknown() {
    FixClick(572, 314, "Right")
    Sleep(3000)
}

ArrayHasValue(arr, val) {
    for _, v in arr
        if v = val
            return true
    return false
}

NextPageFunc() {
    global UnitPage
    if UnitPage < 6 {
        HideAllUnitControls()
        UnitPage += 1
        PageTitle.Text := "Unit " UnitPage
        ShowCurrentSlotControls()
    }
}

PrevPageFunc() {
    global UnitPage
    if UnitPage > 1 {
        HideAllUnitControls()
        UnitPage -= 1
        PageTitle.Text := "Unit " UnitPage
        ShowCurrentSlotControls()
    }
}

ActivateRoblox() {
    if !WinExist(robloxWin) {
        Sleep(1000)
    } else {
        WinGetPos(&X, &Y, &W, &H, MainGui)
        WinActivate(robloxWin)
        WaitForRobloxReady()
        return true
    }
}

ShowCurrentSlotControls() {
    global unitControls, UnitPage
    if !unitControls.Has(UnitPage)
        return

    for _, ctrlGroup in unitControls[UnitPage] {
        ctrlGroup.checkbox.Visible := true
        ctrlGroup.xEdit.Visible := true
        ctrlGroup.yEdit.Visible := true
        ctrlGroup.button.Visible := true
    }
}

HideAllUnitControls() {
    global unitControls
    for _, units in unitControls {
        for _, ctrlGroup in units {
            ctrlGroup.checkbox.Visible := false
            ctrlGroup.xEdit.Visible := false
            ctrlGroup.yEdit.Visible := false
            ctrlGroup.button.Visible := false
        }
    }
}
StatsControls.Push(StatsText)
StatsControls.Push(WinRateText)
StatsControls.Push(AvgStageTimeText)
StatsControls.Push(MacroRunTimeText)
for ctrl in StatsControls {
    ctrl.Visible := false
}
ConfirmModeBtn.OnEvent("Click", (*) => ConfirmModeSelection())
uiBorders.Push(MainGui.AddText("x1000 y120 w520 h1 +Background" uiTheme[1])) ; seperate 1
uiBorders.Push(MainGui.AddText("x1000 y213 w520 h1 +Background" uiTheme[1])) ; seperate 2
uiBorders.Push(MainGui.AddText("x1200 y30 w1 h570 +Background" uiTheme[1])) ; seperate 3
uiBorders.Push(MainGui.AddText("x999 y600 w400 h1 +Background" uiTheme[1])) ; seperate 3

uiBorders.Push(MainGui.AddText("x1000 y310 w560 h1 +Background" uiTheme[1])) ; Settings top
uiBorders.Push(MainGui.AddText("x0 y0 w1500 h1 +Background" uiTheme[1])) ; Settings Bottom
uiBorders.Push(MainGui.AddText("x1000 y340 w1500 h1 +Background" uiTheme[1]))
uiBorders.Push(MainGui.AddText("x1000 y30 w500 h1 +Background" uiTheme[1]))
uiBorders.Push(MainGui.AddText("x0 y1 w1 h1000 +Background" uiTheme[1]))
uiBorders.Push(MainGui.AddText("x1399 y0 w1 h1200 +Background" uiTheme[1]))
uiBorders.Push(MainGui.AddText("x999 y0 w1 h1000 +Background" uiTheme[1]))
uiBorders.Push(MainGui.AddText("x0 y629 w1500 h1 +Background" uiTheme[1]))

TransBox := MainGui.AddProgress("c0x7e4141 x0 y30 h600 w1000", 100)
WinSetTransColor("0x7e4141 255", MainGui.Hwnd)
FixClick(x, y, LR := "Left") {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    MouseClick(LR, -1, 0, , , , "R")
    Sleep(50)
}

FixMove(x, y, LR := "Left") {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    Sleep(50)
}

HoldKey(key, duration) {
    SendInput ("{" key "up}")  
    ; go to teleporter
    Sleep 100  
    SendInput ("{" key " down}")
    Sleep duration
    SendInput ("{" key " up}")
    KeyWait key ; Wait for "d" to be fully processed
}

ChangeUpgMode() {
    global UpgModeSelect, UpgMode
    if (UpgMode == "Multi") {
        UpgMode := "Single"
        UpgModeSelect.Text := "Single"
    }else {
        UpgMode := "Multi"
        UpgModeSelect.Text := "Multi"
    }
}

ModeChanged(*) {
    global modeDDL, mapDDL, actDDL, ConfirmModeBtn

    selectedMode := modeDDL.Text
    maps := []

    mapDDL.Visible := false
    actDDL.Visible := false
    ConfirmModeBtn.Visible := false

    switch selectedMode {
        case "Story":
            maps := ["Oasis", "Firefighters Base", "Unknown Planet", "Hog Town", "Harge Forest", "Babylon"]
        case "Legend Stage":
            maps := ["Shibuya", "Ruined Morioh", "Thriller Bark", "Ryuudou Temple", "Snowy Village", "Rain Village", "Oni Island", "Unknown Planet", "Oasis", "Harge Forest", "Babylon"]
        case "Cavern":
            maps := ["Fire", "Water", "Nature", "Light", "Dark"]
        case "Raids":
            maps := ["Ancient Dungeon"]
        case "Portals":
            maps := ["No-Name Planet", "Demon Skull Village", "Void"]
    
    }Text:="|<>*104$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyDz07zzzznzzwTy07zzzz3zzsTw07zzzy7zzkzsQDzzzwDzzVzkwC1wEk3l73zVsM1s106067z3UU1k2080ADy0311Ui0k0MTw06D33y7Vkkzs0QS67wD7VVzk3sQADsS633zVzk0MTkQ067z3zU1kzkM0A7y7zU7XzUM0M7wTzkT7zVwFsTzzzzzzzzzzzzzzzzzzzzzzzy"
    if (maps.Length > 0) {
        ClearDDL(mapDDL)
        for map in maps
            mapDDL.Add([map])
        mapDDL.Visible := true
        actDDL.Visible := false
        ConfirmModeBtn.Visible := false
    } else {
        modeDDL.GetPos(&x, &y, &w, &h)
        ConfirmModeBtn.Move(x, y + h + 10)
        ConfirmModeBtn.Visible := true
    }
}

UpdateDifficultyVisibility() {
    global modeDDL, actDDL, DifSwitch

    mode := modeDDL.Text
    act := actDDL.Text

    showDiff := false

    if (mode = "Cavern") {
        showDiff := true
        DifSwitch.Delete()
        DifSwitch.Add(["Normal", "Nightmare", "Purgatory"])
    }

    else if (mode = "Infinity Castle") {
        showDiff := true
        DifSwitch.Delete()
        DifSwitch.Add(["Normal", "Hard"])
        DifSwitch.Text := "Normal" ; optional default
    }

    else if (act = "Act 6") {
        showDiff := true
        DifSwitch.Delete()
        DifSwitch.Add(["Nightmare", "Purgatory"])
    }

    DifSwitch.Visible := showDiff
}

MapChanged(*) {
    global modeDDL, mapDDL, actDDL, ConfirmModeBtn

    selectedMode := modeDDL.Text
    selectedMap := mapDDL.Text
    acts := []

    if (selectedMode = "Story") {
        acts := ["Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6", "Infinite"]
    } else if (selectedMode = "Legend Stage") {
        acts := ["Act 1", "Act 2", "Act 3"]
    } else if (selectedMode = "Raids") {
        acts := ["Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6"]
    }
    ClearDDL(actDDL)
    for act in acts
        actDDL.Add([act])

    if (acts.Length > 0) {
        actDDL.Visible := true
        ConfirmModeBtn.Visible := false
    } else {
        actDDL.Visible := false
        mapDDL.GetPos(&x, &y, &w, &h)
        ConfirmModeBtn.Move(x, y + h + 10)
        ConfirmModeBtn.Visible := true
    }
}

ActChanged(*) {
    global actDDL, ConfirmModeBtn
    if (actDDL.Text = "")
        return

    actDDL.GetPos(&x, &y, &w, &h)
    ConfirmModeBtn.Move(x, y + h + 10)
    ConfirmModeBtn.Visible := true
}

ConfirmModeSelection() {
    global modeDDL, mapDDL, actDDL, ConfirmModeBtn, StatsControls, SelectedModeText
    global mode, act, HotkeyHintText, unitControls, UnitPage, DifSwitch
    MainSettingBorder1 := uiBorders.Push(MainGui.AddText("x999 y365 w201 h1 +Background" uiTheme[1])) 
    MainSettingBorder2 := uiBorders.Push(MainGui.AddText("x999 y425 w201 h1 +Background" uiTheme[1])) 
    MainSettingBorder3 := uiBorders.Push(MainGui.AddText("x999 y500 w201 h1 +Background" uiTheme[1])) 
    mode := modeDDL.Text
    modemap := mapDDL.Text
    act := actDDL.Text
    modeDDL.Visible := false
    mapDDL.Visible := false
    actDDL.Visible := false
    ConfirmModeBtn.Visible := false
    LoadUnitLayout()
    UpdateDifficultyVisibility()
    if (modemap = "" && act = "") {
        SelectedModeText.Text := "Mode: " mode
    } else {
        SelectedModeText.Text := (modemap ? "Mode: " modemap : "") (act ? " [" act "]" : "")
    }    
    SelectedModeText.Visible := true

    for ctrl in StatsControls {
        ctrl.Visible := true
    }

    for ctrl in ModeSettingsControls
        ctrl.Visible := true 

    IniWrite(mode, "lib/settings.ini", "ModeSelect", "Mode")
    IniWrite(act,  "lib/settings.ini", "ModeSelect", "Act")

    ;SettingsNextBtn.Enabled := true
    ;SettingsPrevBtn.Enabled := true
    HotkeyHintText.Text := "F1: Fix Roblox`nF2: Start Macro`nF3: Restart Macro"
    HotkeyHintText.Visible := true

    for _, units in unitControls {
        for _, ctrlGroup in units {
            ctrlGroup.button.Enabled := true
        }
    }
}

HandleStatControls(*) {
    global StatsText, WinRateText, AvgStageTimeText, MacroRunTimeText, MacroRuntime, wins, loss, Winrate, AvgTime, FailCount, SuccessCount
    wins := SuccessCount
    loss := FailCount

    totalGames := wins + loss
    Winrate := (totalGames > 0) ? Round((wins / totalGames) * 100, 1) : 0

    elapsedMS := A_TickCount - MacroRuntime
    elapsedSecs := elapsedMS // 1000

    days := elapsedSecs // 86400
    hours := Mod(elapsedSecs // 3600, 24)
    minutes := Mod(elapsedSecs // 60, 60)
    seconds := Mod(elapsedSecs, 60)

    StatsText.Value := Format("Wins: {} | Losses: {} | Total: {}", wins, loss, totalGames)
    WinRateText.Value := Format("Winrate: {}%", Winrate)
    AvgStageTimeText.Value := Format("Avrg Stage Time: {}m {}s", AvgTime // 60, Mod(AvgTime, 60))
    MacroRunTimeText.Value := Format("Macro Runtime: {}d {}h {}m {}s", days, hours, minutes, seconds)
}

debug() {
    if (A_ScreenWidth != 1920 || A_ScreenHeight != 1080) {
        MsgBox("❌ Your resolution must be 1920x1080. Current: " A_ScreenWidth "x" A_ScreenHeight)
        return
    }

    if WinExist("ahk_exe Windows10Universal.exe") {
        MsgBox("You are using the Microsoft Store version of Roblox.`nPlease uninstall it and install Roblox from the official website (roblox.com).")
        return
    }

    dpi := DllCall("GetDpiForSystem")
    if (dpi != 96) { ; 96 DPI = 100% scale
        scalePercent := Round(dpi / 96 * 100)
        MsgBox("❌ Your scaling must be 100%. Current: " scalePercent "%")
        return
    }

    centerX := A_ScreenWidth // 2
    centerY := A_ScreenHeight // 2

    MouseMove(centerX, centerY)
    Sleep(500)
    
    MouseGetPos(&currX, &currY)

    if (Abs(currX - centerX) > 10 || Abs(currY - centerY) > 10) {
        MsgBox("❌ Mouse couldn't move correctly! Something might be blocking it (like Riot Client).")
        return
    }

    MsgBox("Detected no problems, open a ticket (/strive) and ping a supporter")
}

ClearDDL(ddl) {
    Loop 10 {
        try ddl.Delete(1)
        catch
            break
    }
}

BuildFullGUI() {
    global UnitPage, actDDL, MainGui

    MainGui.Opt("+OwnDialogs")  ; Prevent msgboxes from hiding GUI
    Loop 6 {
        tempPage := A_Index
        BuildGuiForPage(tempPage)
    }
    MainGui.Show("x135 y30 w1400 h600")
}
LoadSettings()
MainGui.Opt("-AlwaysOnTop") 
MainGui.Hide() 
BuildFullGUI() 
MainGui.Show("x0 y0 w1400 h630")
MainGui.Opt("+AlwaysOnTop")
ActivateRoblox()
x := 0, y := 0, w := 1016, h := 638
WaitForRobloxReady(x := 0, y := 0, w := 1016, h := 638) {
        robloxWin := WinExist("ahk_exe RobloxPlayerBeta.exe")
        if !WinExist(robloxWin) {
            Sleep(1000)
        }

        WinGetPos(&currX, &currY, &currW, &currH, robloxWin)
        if (currX = x && currY = y && currW = w && currH = h) {
        }
        WinMove(x-8, y, w, h, robloxWin)
        Sleep(1000)
}
if WinExist(robloxWin) { 
    WinActivate(robloxWin)
}
BuildGuiForPage(page) {
    global unitControls, MainGui

    if !unitControls.Has(page)
        unitControls[page] := Map()

    positions := [
        {x: 1020, y: 35}, {x: 1220, y: 35},
        {x: 1020, y: 125}, {x: 1220, y: 125},
        {x: 1020, y: 220}, {x: 1220, y: 220}
    ]

    Loop 6 {
        unitNum := A_Index

        if unitControls[page].Has(unitNum)
            continue

        pos := positions[unitNum]
        cb := MainGui.AddCheckbox("x" pos.x " y" pos.y " cffffff", "Placement " unitNum)
        cb.SetFont("s9")

        labelW := 20, editW := 50, spacing := 10
        labelY := pos.y + 28, editY := labelY

        xLabel := MainGui.AddText("x" pos.x " y" labelY+3 " BackgroundTrans cffffff", "X:")
        xLabel.SetFont("s9")
        xEdit := MainGui.AddEdit("x" (pos.x + labelW) " y" editY " w" editW " h20", "")
        xEdit.SetFont("s9")

        yLabel := MainGui.AddText("x" (pos.x + labelW + editW + spacing) " y" labelY+3 " BackgroundTrans cffffff", "Y:")
        yLabel.SetFont("s9")
        yEdit := MainGui.AddEdit("x" (pos.x + labelW*2 + editW + spacing) " y" editY " w" editW " h20", "")
        yEdit.SetFont("s9")

        btn := MainGui.AddButton("x" pos.x " y" (pos.y + 55) " w150 h25", "Select Coords")
        
        btn.SetFont("s9")
        btn.Name := "btn_u" page "_" unitNum
        btn.Enabled := false
        local pageCopy := page, unit := unitNum
        btn.OnEvent("Click", (btnCtrl, *) => SelectCoordinates(btnCtrl))

        unitControls[page][unitNum] := {
            checkbox: cb, xLabel: xLabel, xEdit: xEdit,
            yLabel: yLabel, yEdit: yEdit, button: btn
        }
    }
}

ImageSearchWrapper(&FoundX, &FoundY, X1, Y1, X2, Y2, ImagePath, Tolerance := 30) {
    try {
        ; Store the previous CoordMode and set to Screen
        prevCoordMode := A_CoordModePixel
        CoordMode "Pixel", "Screen"

        ; Perform the image search with specified tolerance
        result := ImageSearch(&FoundX, &FoundY, X1, Y1, X2, Y2, "*" Tolerance " " ImagePath)

        ; Restore previous CoordMode if needed
        if (prevCoordMode != "Screen")
            CoordMode "Pixel", prevCoordMode

        ; Return and log results
        if (result) {
            return true
        } else {
            return false
        }
    } catch as e {
        MsgBox("Error in ImageSearchWrapper: " e.Message)
        return false
    }
}

CaptureRobloxScreenshot(OutputFile) {
    if !Gdip_Startup() {
        MsgBox("❌ GDI+ not initialized.")
        return
    }

    hwnd := WinExist("ahk_exe RobloxPlayerBeta.exe")
    if !hwnd {
        MsgBox("❌ Roblox window not found.")
        return
    }

    WinGetClientPos(&cx, &cy, &cw, &ch, hwnd)
    WinGetPos(&wx, &wy,,, hwnd)

    x := wx + cx+4
    y := wy + cy

    if (cw = 0 || ch = 0) {
        MsgBox("❌ Invalid client area size.")
        return
    }

    pBitmap := Gdip_BitmapFromScreen(x "|" y "|" cw "|" ch)
    if !pBitmap {
        MsgBox("❌ Failed to capture screen.")
        return
    }

    try {
        Gdip_SaveBitmapToFile(pBitmap, OutputFile)
    } catch as e {
        ; MsgBox("❌ Failed to save screenshot.n" e.Message)
    }

    Gdip_DisposeImage(pBitmap)
}

SendTestWebhook() {
    global WebhookURLEdit, PingUser, DiscordUserIDEdit, SendScreenshot, mode, act

    url := WebhookURLEdit.Text
    userID := DiscordUserIDEdit.Text
    shouldPing := PingUser.Value
    includeScreenshot := SendScreenshot.Value

    if (url = "" || !RegexMatch(url, "^https:\/\/discord\.com\/api\/webhooks\/")) {
        MsgBox("❌ Invalid or missing webhook URL.")
        return
    }

    ScreenshotPath := A_ScriptDir "\test_screenshot.png"
    if (includeScreenshot)
        CaptureRobloxScreenshot(ScreenshotPath)

    hasScreenshot := includeScreenshot && FileExist(ScreenshotPath)
    fileName := "test_screenshot.png"
    fileObj := hasScreenshot ? [{name: fileName, fileName: ScreenshotPath}] : []

    pingMsg := (shouldPing && userID != "") ? "<@" userID ">" : " "

    embed := EmbedBuilder()
    embed.setTitle("✅ Test Webhook")
    embed.setDescription("This is a test message from the Fendi Macro Settings lol")
    embed.setColor(0x00ffcc)
    embed.setFooter({text: "Fendi Macro • Webhook Test"})
    embed.addFields([
        { name: "📅 Time Sent:", value: FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"), inline: true }
    ])

    if hasScreenshot
        embed.setImage({ url: "attachment://" fileName })

    webhook := Discord.Webhook(url)

    try {
        webhook.Send({
            content: pingMsg,
            embeds: [embed],
            files: fileObj
        })
        MsgBox("✅ Test webhook sent successfully.")
    } catch as e {
        ; MsgBox("❌ Webhook error: " e.Message)
    }

    if hasScreenshot
        FileDelete(ScreenshotPath)
}

global ModeImages := Map(
    "Breach",            A_ScriptDir "\lib\images\coords_breach.png",
    "Hog Town",          A_ScriptDir "\lib\images\coords_hog.png",
    "Unknown Planet",    A_ScriptDir "\lib\images\coords_unknown.png",
    "Firefighters Base", A_ScriptDir "\lib\images\coords_firefighter.png",
    "Oasis",             A_ScriptDir "\lib\images\coords_oasis.png",
    "Cavern",            A_ScriptDir "\lib\images\coords_cavern.png",
    "Shibuya",           A_ScriptDir "\lib\images\coords_shibuya.png",
    "Ruined Morioh",     A_ScriptDir "\lib\images\coords_morioh.png",
    "Thriller Bark",     A_ScriptDir "\lib\images\coords_thriller.png",
    "Ryuudou Temple",    A_ScriptDir "\lib\images\coords_ryuudou.png",
    "Snowy Village",     A_ScriptDir "\lib\images\coords_snowy.png",
    "Rain Village",      A_ScriptDir "\lib\images\coords_rainy.png",
    "Oni Island",        A_ScriptDir "\lib\images\coords_oni.png",
    "U-18",              A_ScriptDir "\lib\images\coords_u18.png",
    "Hell City",         A_ScriptDir "\lib\images\coords_Hell_city.png",
    "Central City",      A_ScriptDir "\lib\images\coords_central.png",
    "Flower Garden",     A_ScriptDir "\lib\images\coords_flower.png",
    "Flying Island",     A_ScriptDir "\lib\images\coords_flying.png",
    "Water",             A_ScriptDir "\lib\images\coords_water.png",
    "Fire",              A_ScriptDir "\lib\images\coords_fire.png",
    "Nature",            A_ScriptDir "\lib\images\coords_nature.png",
    "Dark",              A_ScriptDir "\lib\images\coords_dark.png",
    "Light",             A_ScriptDir "\lib\images\coords_light.png",
    "Inner Dimension",   A_ScriptDir "\lib\images\coords_portal.png",
    "Infernal",          A_ScriptDir "\lib\images\coords_infernal.png",
    "Monarch",           A_ScriptDir "\lib\images\coords_monarch.png",
    "Holy Invasion",     A_ScriptDir "\lib\images\coords_holy.png",
    "Villain Invasion",  A_ScriptDir "\lib\images\coords_villain.png",
    "Ancient Dungeon",   A_ScriptDir "\lib\images\coords_ancient.png",
    "Harge Forest",      A_ScriptDir "\lib\images\coords_harge.png",
    "Babylon",           A_ScriptDir "\lib\images\coords_babylon.png",
    "Tournament of Power", A_ScriptDir "\lib\images\coords_top.png",
    "No-Name Planet",    A_ScriptDir "\lib\images\coords_noname.png",
    "Void",              A_ScriptDir "\lib\images\coords_void.png",

)

HandleImgGuiClose(*) {
    global isSelectingCoords, ImageGUI, PaletteGui, TargetPage, TargetUnit
    isSelectingCoords := false
    TargetPage := ""
    TargetUnit := ""

    try if GuiExist(ImageGUI)
        ImageGUI.Destroy()

    try if GuiExist(PaletteGui)
        PaletteGui.Destroy()
}

SelectCoordinates(btnCtrl) {
    global unitControls, testimg, isSelectingCoords
    global TargetPage, TargetUnit
    global mapDDL

    mapName := mapDDL.Text
    selectedMode := modeDDL.Text

    imageKey := (selectedMode = "Cavern") ? selectedMode : mapName

    if ModeImages.Has(imageKey)
        testimg := ModeImages[imageKey]
    else
        testimg := "lib\images\image.png"

    global paletteImg := "lib\images\ColorTut.png"


if isSelectingCoords {
    MsgBox("🛑 Coordinate selection is already in progress.")
    return
}

isSelectingCoords := true 
    global isSelectingCoords
    CoordMode "Mouse", "Screen" 
    if !RegExMatch(btnCtrl.Name, "btn_u(\d+)_(\d+)", &m)
        return MsgBox("Unknown button clicked.")

    page := Integer(m[1])
    unitNum := Integer(m[2])

    TargetPage := page
    TargetUnit := unitNum


    global ImageGUI := Gui("AlwaysOnTop +ToolWindow", "Select Coordinates")
    ImageGUI.BackColor := "Black"
    ImageGUI.SetFont("s8", "Segoe UI")
    ImageGUI.AddPicture("x0 y0 w1000 h599", testimg)
    ImageGUI.OnEvent("Close", (*) => HandleImgGuiClose())
    global MarkerMap := Map()  ; stores marker references and metadata

for p, units in unitControls {
slotColor := SlotColors.Has(p) ? SlotColors[p] : "White"
for n, ctrlGroup in units {
    x := ctrlGroup.xEdit.Value
    y := ctrlGroup.yEdit.Value
    if (x != "" && y != "") {
        marker := ImageGUI.Add("Text", "x" (x - 2) " y" (y - 2) " w8 h8 +Background" slotColor " +Border")
        marker.SetFont("s7", "Segoe UI")
        marker.Opt("+0x200")
        marker.OnEvent("Click", (ctrl, *) => StartDrag(ctrl))
        marker.OnEvent("DoubleClick", (ctrl, *) => DeleteMarker(ctrl))
        label := ImageGUI.Add("Text", "x" (x + 6) " y" (y - 5) " cWhite BackgroundTrans", n ":" p)
        
        MarkerMap[marker.Hwnd] := {
            page: p,
            unit: n,
            marker: marker,
            label: label
        }
    }
}
}
    ImageGUI.SetFont("s7", "Segoe UI")        
    ImageGUI.Show("x" 0-8 " y0 w999 h599")
    DllCall("SetWindowLong", "Ptr", ImageGUI.Hwnd, "Int", -20, "Int", 0x08)
    slotInfo := ImageGUI.Add("Text", "x0 y579 w70 h20 +BackgroundBlack cWhite Center", "[Unit] | [Slot]")
slotInfo.SetFont("s9", "Segoe UI")

DragTut := ImageGUI.Add("Text", "x80 y579 w140 h20 +BackgroundBlack cWhite Center", "[Hold RMB to Drag marks]")
DragTut.SetFont("s9", "Segoe UI")

global PaletteGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
PaletteGui.BackColor := "Black"
PaletteGui.AddPicture("x0 y0 w350 h30", paletteImg)
PaletteGui.Show("x330 y600 w350 h30")
WinSetAlwaysOnTop true, "ahk_id " PaletteGui.Hwnd

SetTimer(WatchForRightClick, 5)

WatchForRightClick() {
    global isSelectingCoords, ImageGUI, PaletteGui, unitControls, TargetPage, TargetUnit
    if GetKeyState("RButton", "P") {
        MouseGetPos &mx, &my

        if GuiExist(ImageGUI) && WinActive("ahk_id " ImageGUI.Hwnd) {
            SetTimer(WatchForRightClick, 0)
            if IsSet(PaletteGui)
                PaletteGui.Opt("+AlwaysOnTop")
            isSelectingCoords := false
            ctrl := unitControls[TargetPage][TargetUnit]
            ctrl.screenX := mx
            ctrl.screenY := my
            unitControls[TargetPage][TargetUnit] := ctrl

            pt := Buffer(8, 0)
            NumPut("int", mx, pt, 0)
            NumPut("int", my, pt, 4)
            DllCall("ScreenToClient", "Ptr", ImageGUI.Hwnd, "Ptr", pt)
            relX := NumGet(pt, 0, "int")
            relY := NumGet(pt, 4, "int")

            if (relX < 0 || relX > 1000 || relY < 0 || relY > 570) {
                MsgBox("That's outside the image bounds.\nX: " relX " | Y: " relY)
                return
            }

            ; Store coordinates
            ctrl.xEdit.Value := relX
            ctrl.yEdit.Value := relY

            ImageGUI.Destroy()
            PaletteGui.Destroy()
        }
    }
}     
}   

StartDrag(ctrl) {
    global DraggingMarker
    DraggingMarker := ctrl
    SetTimer(DoDrag, 10)
}

FinalizeDrag() {
    global DraggingMarker, MarkerMap, DragPreviewX, DragPreviewY
    if !DraggingMarker
        return
    
    hwnd := DraggingMarker.Hwnd
    if !MarkerMap.Has(hwnd)
        return
    
    data := MarkerMap[hwnd]
    
    relX := DragPreviewX 
    relY := DragPreviewY
    
    offsetY := 23
    
    markerX := relX - 4
    markerY := relY - 10 - offsetY 
    labelX := relX + 6
    labelY := relY - 14 - offsetY
    
    data.marker.Move(markerX, markerY)
    data.label.Move(labelX, labelY)
    
    ctrl := unitControls[data.page][data.unit]
    ctrl.xEdit.Value := relX
    ctrl.yEdit.Value := relY    
    
    DraggingMarker := ""
    }
    
    DoDrag() {
        global DraggingMarker, DragPreviewX, DragPreviewY, MarkerMap
    
        if !DraggingMarker
            return
    
        if !GetKeyState("LButton", "P") {
            SetTimer(DoDrag, 0)
            ToolTip() 
            FinalizeDrag()
            return
        }
    
        CoordMode "Mouse", "Screen"
        MouseGetPos(&mx, &my)
        DragPreviewX := mx
        DragPreviewY := my
    
        hwnd := DraggingMarker.Hwnd
        if MarkerMap.Has(hwnd) {
            data := MarkerMap[hwnd]
            ToolTip("🟦 Dragging Unit " data.unit " | Slot " data.page)
        }
}

DeleteMarker(ctrl) {
    global MarkerMap, unitControls

    hwnd := ctrl.Hwnd
    if !MarkerMap.Has(hwnd)
        return

    data := MarkerMap[hwnd]
    page := data.page
    unit := data.unit

    if MsgBox("Delete coordinates for Unit " unit " in Slot " page "?", "Confirm", "YesNo") = "No"
        return

    ; Clear fields
    ctrlGroup := unitControls[page][unit]
    ctrlGroup.xEdit.Value := ""
    ctrlGroup.yEdit.Value := ""

    data.marker.Destroy()
    data.label.Destroy()

    MarkerMap.Delete(hwnd)

    MsgBox("❌ Coordinates for Unit " unit " in Slot " page " have been removed.")
}

CheckLobby() {
    global modeDDL
    loop {
        Sleep 1000
        if (ok := FindText(&X, &Y, 746, 514, 789, 530, 0, 0, LobbyText)) {
            break
        }
    }
    global ModeDDL
    mode := ModeDDL.Text
    return StartMode(modeDDL.Text)
}

CheckLoaded() {
    global LoadedDelay
    timeOut := 60000
    start := A_TickCount
    loop {
        if (A_TickCount - start > timeOut) {
            break
        }
        x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
        Sleep(1000)
        if (ok := FindText(&X, &Y, x1, y1, x2, y2, 0, 0, VoteStart))
        || (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, VoteStart1))
        || (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, VoteStart2))
        || (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, VoteStart3))
        || (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, SurvLoaded))
        || (ok:=FindText(&X, &Y, x1, y1, x2, y2, 0, 0, SurvLoaded1)) {
            Wait := ConvertDelay(Number(LoadedDelay.Value))
            Sleep(Wait)
            global MaxedUnits := Map()
            return true
        }
    }
    Sleep(100)
    global MaxedUnits := Map()
    return false
}

FixDisconnect() {
    global modeDDL
    FixClick(591, 419) ; click reconnect
    CheckLobby()
    FixClick(791, 146) ; close upd log
    return StartMode(modeDDL.Text)
}

Disconnected() {
    global modeDDL, mapDDL, actDDL, Disconnect1, Disconnect2, Disconnect3
    x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
    if (
        FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, Disconnect1)
        || FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, Disconnect2)
        || FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, Disconnect3)
    ) {
        return true
    }
    return false
}

hasEnabledUnits(slotNum) {
    global unitControls
    if !unitControls.Has(slotNum)
        return false

    for _, ctrl in unitControls[slotNum] {
        if ctrl.checkbox.Value
            return true
    }
    return false
}

showPlacePrioGui() {
    static PlaceGui := 0
    static IsGuiVisible := false

    if !IsSet(PlaceGui) || !PlaceGui {
        PlaceGui := Gui("+AlwaysOnTop", "Placement Priorities")
        PlaceGui.BackColor := 0x2d2d30
        PlaceGui.SetFont("s9", "Segoe UI")

        global placePriorityDropdowns := Map()
        y := 10

        Loop 6 {
            slot := A_Index
            PlaceGui.AddText("x10 y" y " cffffff", "Slot " slot ":")
            ddl := PlaceGui.AddDropDownList("x70 y" y " w60", [])
            ddl.Enabled := false
            placePriorityDropdowns[slot] := ddl
            y += 35
        }

        PlaceGui.AddButton("x10 y" y+10 " w100", "Save").OnEvent("Click", SavePlacePriorities)
        PlaceGui.OnEvent("Close", (*) => (
            IsGuiVisible := false,
            PlaceGui.Hide()
        ))
    }

    enabledSlots := []
    for slot, _ in placePriorityDropdowns {
        if hasEnabledUnits(slot)
            enabledSlots.Push(slot)
    }

    priorities := []
    Loop enabledSlots.Length
        priorities.Push(A_Index)

    for slot, ddl in placePriorityDropdowns {
        key := "PlaceSlot" slot
        if ArrayHasValue(enabledSlots, slot) {
            ddl.Delete()
            ddl.Add(priorities)
            ddl.Enabled := true

            saved := GuiState.Has(key) ? GuiState[key] : ""
            if ArrayHasValue(priorities, saved)
                ddl.Text := saved
            else
                ddl.Text := ""
        } else {
            ddl.Delete()
            ddl.Add([""])
            ddl.Text := ""
            ddl.Enabled := false
        }
    }

    if IsGuiVisible {
        PlaceGui.Hide()
        IsGuiVisible := false
    } else {
        PlaceGui.Show("AutoSize")
        IsGuiVisible := true
    }
}

togglePrioGui() {
    static MyGui := 0
    static IsGuiVisible := false

    if !IsSet(MyGui) || !MyGui {
        MyGui := Gui("+AlwaysOnTop", "Upgrade Priorities")
        MyGui.BackColor := 0x2d2d30
        MyGui.SetFont("s9", "Segoe UI")

        global priorityUpgradeSlots := Map()
        y := 10

        Loop 6 {
            slot := A_Index
            MyGui.AddText("x10 y" y " cffffff", "Slot " slot ":")
            ddl := MyGui.AddDropDownList("x70 y" y " w60", [])
            ddl.Enabled := false
            priorityUpgradeSlots[slot] := ddl
            y += 35
        }

        MyGui.AddButton("x10 y" y+10 " w100", "Save").OnEvent("Click", SavePriorities)
        MyGui.OnEvent("Close", (*) => (
            IsGuiVisible := false,
            MyGui.Hide()
        ))
    }

    enabledSlots := []
    for slot, _ in priorityUpgradeSlots {
        if hasEnabledUnits(slot)
            enabledSlots.Push(slot)
    }

    priorities := []
    Loop enabledSlots.Length
        priorities.Push(A_Index)

    for slot, ddl in priorityUpgradeSlots {
        if ArrayHasValue(enabledSlots, slot) {
            ddl.Delete()
            ddl.Add(priorities)
            ddl.Enabled := true
    
            saved := GuiState.Has("Slot" slot) ? GuiState["Slot" slot] : ""
            if ArrayHasValue(priorities, saved)
                ddl.Text := saved
            else
                ddl.Text := ""
        } else {
            ddl.Delete()
            ddl.Add([""])
            ddl.Text := ""
            ddl.Enabled := false
        }
    }

    if IsGuiVisible {
        MyGui.Hide()
        IsGuiVisible := false
    } else {
        MyGui.Show("AutoSize")
        IsGuiVisible := true
    }
}


SavePriorities(*) {
    global priorityUpgradeSlots, GuiState

    for slot, ddl in priorityUpgradeSlots {
        key := "Slot" slot
        if ddl.Enabled {
            GuiState[key] := ddl.Text
        } else if GuiState.Has(key) {
            GuiState.Delete(key)
        }
    }
}

SavePlacePriorities(*) {
    global placePriorityDropdowns, GuiState

    for slot, ddl in placePriorityDropdowns {
        key := "PlaceSlot" slot
        if ddl.Enabled {
            GuiState[key] := ddl.Text
        } else if GuiState.Has(key) {
            GuiState.Delete(key)
        }
    }
}

HandleDifficulty() {
    global actDDL, DifSwitch, modeDDL

    mode := modeDDL.Text
    act := actDDL.Text
    diff := DifSwitch.Text

    if (mode = "Legend Stage" || mode = "Raids")
        return

    if (mode = "Cavern") {
        if (diff = "Normal")
            FixClick(215, 202)
        else if (diff = "Nightmare")
            FixClick(215, 236)
        else if (diff = "Purgatory")
            FixClick(215, 288)
        else if (diff = "Insanity")
            FixClick(215, 321)
    }else if ((mode = "Story") && act = "Act 6") {
        if (diff = "Purgatory")
            FixClick(715, 280)
        else if (diff = "Nightmare")
            FixClick(605, 280)
    }
}

HandleMapMovement(mapName) {
    switch mapName {
        case "U-18":
            return MoveForU18()
        case "Central City": 
            return MoveForCentralCity()
        case "Oasis":
            return MoveForOasis()
        case "Unknown Planet":
            return MoveForUnknown()
        case "No-Name Planet":
            return MoveForNoName()
        default:
            return
    }
}

UnitPlaced(slot, x, y) {
    Sleep 300

    if FindText(&fx, &fy, 160, 215, 330, 420, 0, 0, UpgradeText)
     || FindText(&fx, &fy, 160, 215, 330, 420, 0, 0, UpgradeText2)
    {
        Sleep 150
        return true
    }

    FixClick(500, 515)
    Sleep 300
    FixClick(x, y)
    Sleep 300

    if FindText(&fx, &fy, 160, 215, 330, 420, 0, 0, UpgradeText)
     || FindText(&fx, &fy, 160, 215, 330, 420, 0, 0, UpgradeText2)
    {
        Sleep 150
        return true
    }
    FixClick(500, 515)
    Sleep(300)
    SendEvent("V")
    SendEvent("X")
    FixClick(510, 515)
    return false
}

PlaceUnit(x, y, slot := 1) {
    global unitControls
    SendInput(slot) 
    Sleep(250)
    MouseMove(x, y)
    Sleep(175)
    FixClick(x, y)
    Sleep(100)
    SendInput("x")
    Sleep(300)
    if !UnitPlaced(slot, x, y)
        return false
    Sleep(200)
    FixClick(500, 515) ; close unit
    return true
}

CheckMaxLvl(x, y, slotNum, unitNum) {
    global MaxUpgText, MaxUpgText2, MaxedUnits
    key := slotNum "_" unitNum

    if MaxedUnits.Has(key)
        return true
    x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
    if FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, MaxUpgText)
     || FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, MaxUpgText2)
    {
        MaxedUnits[key] := true
        return true
    }
    return false
}

GetActCoords(act) {
    switch act {
        case "Act 1":
            return { x: 393, y: 215 }
        case "Act 2":
            return { x: 393, y: 254 }
        case "Act 3":
            return { x: 393, y: 294 }
        case "Act 4":
            return { x: 393, y: 334 }
        case "Act 5":
            return { x: 393, y: 370 }
        case "Act 6":
            return { x: 393, y: 409 }
        case "Infinite":
            return { x:393 , y: 456 }
        default:
            return { x: 393, y: 409 } 
    }
}

GetMapCoords(MapName) {
    switch MapName {
        case "Shibuya":
            return { x: 280, y: 215, scroll: 0}
        case "Ruined Morioh":
            return { x: 280, y: 250, scroll: 0}
        case "U-18" :
            return { x: 280, y: 460, scroll: 0}
        case "Hell City" :
            return { x: 280, y: 250, scroll: 0}
        case "Flower Garden":
            return { x: 280, y: 400, scroll: 1}
        case "Central City":
            return { x: 280, y: 370, scroll: 0}
        case "Oasis":
            return { x: 280, y: 440, scroll: 2}
        case "OasisLeg":
            return { x: 280, y: 470, scroll: 0}
        case "Flying Island":
            return { x: 280, y: 440, scroll: 0}
        case "Firefighters Base":
            return { x: 280, y: 280, scroll: 0}
        case "Unknown Planet":
            return { x: 280, y: 440, scroll: 0}
        case "Thriller Bark":
            return { x: 280, y: 280, scroll: 0}
        case "Ryuudou Temple":
            return { x: 280, y: 310, scroll: 0}
        case "Snowy Village":
            return { x: 280, y: 340, scroll: 0}
        case "Rain Village":
            return { x: 280, y: 370, scroll: 0}
        case "Oni Island":
            return { x: 280, y: 400, scroll: 0}
        case "UnknownStory":
            return { x: 280, y: 410, scroll: 2}
        case "Hog Town":
            return { x: 280, y: 210, scroll: 0}
        case "Villain Invasion":
            return { x: 415, y: 145, scroll: 0}
        case "Ancient Dungeon":
            return { x: 280, y: 405, scroll: 1}
        case "Harge Forest":
            return { x: 280, y: 370, scroll: 3}
        case "Babylon":
            return { x: 280, y: 405, scroll: 3}
        case "Harge ForestLeg":
            return { x: 280, y: 370, scroll: 1}
        case "BabylonLeg":
            return { x: 280, y: 405, scroll: 1}
        default: 
            return
    }
}

CloseChat() {
    if (ok:=FindText(&X, &Y, 136-150000, 65-150000, 136+150000, 65+150000, 0, 0, OpenChat)) {
        FixClick(138, 64)
    }
}

TpSpawn() {
    FixClick(290, 45)
    Sleep(175)
    FixClick(580, 242)
    Sleep(175)
    FixClick(659, 135)
}

StartGame() {
    FixClick(447, 533)
    sleep 100
    FixClick(447, 533)
    sleep 100
    FixClick(447, 533)
}

Retrycheck() {
    global SuccessCount, modeDDL, VictoryText, VictoryText2, DefeatText, DefeatText2, retry, next, loss, wins, FailCount, StageStartTime, AvgTime
    mode := modeDDL.Text
    x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
    if ((FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, VictoryText) || FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, VictoryText2)) && FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, retry)) {
        SuccessCount++
        elapsed := (A_TickCount - StageStartTime) // 1000
        AvgTime := ((AvgTime * (SuccessCount + FailCount - 1)) + elapsed) // (SuccessCount + FailCount)
        global winChance := GetWinrate()
        SendWebhook(true)
        Sleep(1000)
        FixClick(515, 452)
        FixClick(515, 452)
        FixClick(515, 452)
        CheckLoaded()
        return true
    }
    if ((FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, DefeatText) || FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, DefeatText2)) && FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, retry)) {
        FailCount++
        elapsed := (A_TickCount - StageStartTime) // 1000
        AvgTime := ((AvgTime * (SuccessCount + FailCount - 1)) + elapsed) // (SuccessCount + FailCount)
        global winChance := GetWinrate()
        SendWebhook(true)
        Sleep(1000)
        FixClick(515, 452)
        FixClick(515, 452)
        FixClick(515, 452)
        CheckLoaded()
        return true
    }
    ok1 := FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, StoryWin)
    ok2 := FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, StoryEnd)
    ok3 := FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, retry)
    if ((ok1 && ok2) || (ok1 && ok3)) {
        SuccessCount++
        elapsed := (A_TickCount - StageStartTime) // 1000
        AvgTime := ((AvgTime * (SuccessCount + FailCount - 1)) + elapsed) // (SuccessCount + FailCount)
        global winChance := GetWinrate()
        SendWebhook(true)
        Sleep(1000)
        FixClick(515, 452)
        FixClick(515, 452)
        FixClick(515, 452)
        Sleep 10000
        CheckLoaded()
        return true
    }

    ok4 := FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, StoryLoss)
    ok5 := FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, StoryEnd)
    ok6 := FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, retry)
    if ((ok4 && ok5) ||(ok4 && ok6))  {
        FailCount++
        elapsed := (A_TickCount - StageStartTime) // 1000
        AvgTime := ((AvgTime * (SuccessCount + FailCount - 1)) + elapsed) // (SuccessCount + FailCount)
        global winChance := GetWinrate()
        SendWebhook(true)
        Sleep(1000)
        FixClick(515, 452)
        FixClick(515, 452)
        FixClick(515, 452)
        Sleep 10000
        CheckLoaded()
        return true
    }
    return false 
}

Shake() {
    MouseMove(5, 5, 5, "R")
    Sleep(30)
    MouseMove(-5, -5, 5, "R")
}

HandlePortalLoss() {
    global mapDDL, loss, FailCount

    FailCount++
    winrate := GetWinrate()

    SendWebhook(false)
    Shake()
    FixClick(481, 453) 
    Sleep(1500)
    FixClick(337, 181) 
    Sleep(1250)
    Send mapDDL.Text
    Sleep(1000)
    FixClick(316, 257)
    Sleep(1000)
    FixClick(770, 527)
    Sleep(1000)
    FixClick(445, 359)
    CheckLoaded()
}

HandlePortalWin() {
    global mapDDL, wins, SuccessCount
    global Portal := mapDDL.Text
    SuccessCount++
    winrate := GetWinrate()
    loop 4{
        FixClick(501, 336)
        Sleep(1000)
        FixClick(499, 475)
        Sleep(4000)
    }
    SendWebhook(true)
    FixClick(481, 453)
    Sleep(1500)
    FixClick(337, 181)
    Sleep(1250)
    Send mapDDL.Text
    Sleep(1000)
    FixClick(316, 257)
    Sleep(1000)
    FixClick(770, 527)
    Sleep(1000)
    FixClick(445, 359)
    CheckLoaded()
    return true
}

RetryCheckMode(mode) {
    HandleVictory() {
        global SuccessCount, StageStartTime, AvgTime
        SuccessCount++
        elapsed := (A_TickCount - StageStartTime) // 1000
        AvgTime := ((AvgTime * (SuccessCount + FailCount - 1)) + elapsed) // (SuccessCount + FailCount)
        SendWebhook(true)
    }

    HandleDefeat() {
        global FailCount, StageStartTime, AvgTime
        FailCount++
        elapsed := (A_TickCount - StageStartTime) // 1000
        AvgTime := ((AvgTime * (SuccessCount + FailCount - 1)) + elapsed) // (SuccessCount + FailCount)
        SendWebhook(true)
    }

    if (mode = "Story") {
        x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
        if FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, StoryWin)
         && (ok:=FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, StoryEnd) || FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, retry)) {
            HandleVictory()
            Sleep(1000)
            FixClick(515, 452)
            return true
        }

        if FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, StoryLoss)
         && (ok:=FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, StoryEnd) || FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, retry)) {
            HandleDefeat()
            Sleep(1000)
            FixClick(515, 452)
            return true
        }
    }

    else if (mode = "Portals") {
        x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
        if (ok:=FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, PortalSelect)
            || FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, PortalConfirm1)) {
            HandlePortalWin()
            return true
        }

        if (ok:=FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, DefeatText)
            || FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, DefeatText2))
            && FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, PortalRetry) {
            HandlePortalLoss()
            return true
        }
    }

    else {
        x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight
        if (ok:=FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, VictoryText) || FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, VictoryText2))
         && FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, retry) {
            HandleVictory()
            Sleep(1000)
            FixClick(515, 452)
            return true
        }

        if (ok:=FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, DefeatText) || FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, DefeatText2))
         && FindText(&fx, &fy, x1, y1, x2, y2, 0, 0, retry) {
            HandleDefeat()
            Sleep(1000)
            FixClick(515, 452)
            return true
        }
    }
    return false
}

SendWebhook(isWin := true) {
    global WebhookURLEdit, PingUser, DiscordUserIDEdit, SendScreenshot
    global mode, act, TotalRuns, SuccessCount, FailCount, winChance, WebhookEnabled

    if !WebhookEnabled.Value {
        return
    }
    runTime := Floor((A_TickCount - MacroRuntime) / 1000)
    hours := Floor(runTime / 3600)
    mins := Floor(Mod(runTime / 60, 60))
    secs := Mod(runTime, 60)
    duration := (hours ? hours "h " : "") (mins ? mins "m " : "") secs "s"

    url := WebhookURLEdit.Text
    userID := DiscordUserIDEdit.Text
    shouldPing := PingUser.Value
    includeScreenshot := SendScreenshot.Value

    if (url = "" || !RegexMatch(url, "^https:\/\/discord\.com\/api\/webhooks\/"))
        return

    TotalRuns += 1

    ScreenshotPath := A_ScriptDir "\round_screenshot.png"
    if (includeScreenshot)
        CaptureRobloxScreenshot(ScreenshotPath)

    hasScreenshot := includeScreenshot && FileExist(ScreenshotPath)
    attachment := hasScreenshot ? AttachmentBuilder("round_screenshot.png") : ""

    content := (shouldPing && userID != "") ? "<@" userID ">" : ""

    embedColor := isWin ? 0x00cc66 : 0xcc0000
    resultIcon := isWin ? "🟢" : "🔴"
    resultText := isWin ? "Victory" : "Defeat"

    desc := "**Mode: ** " (mode ? mode : "Unknown") ""
    if (act && act != "none")
        desc .= " - " act ""

    embed := EmbedBuilder()
    embed.setTitle(resultIcon " " resultText)
    embed.setDescription(desc)
    embed.setColor(embedColor)
    embed.setFooter({ 
        text: "Fendi Macro • Run Result • 🕓 " FormatTime(A_Now, "HH:mm:ss") 
    })    

    if hasScreenshot
        embed.setImage({ url: attachment.attachmentName })

    embed.addFields([
        {
            name: " ",
            value:
            "✅ Wins: " SuccessCount "`n"
          . "❌ Fails: " FailCount "`n"
          . "📊 Total: " TotalRuns "`n"
          . "🕒 Runtime: " duration "`n"
          . "📈 Win Rate: " GetWinrate(),
            inline: false
        }
    ])

    webhook := Discord.Webhook(url)
    try {
        webhook.send({
            content: content,
            embeds: [embed],
            files: hasScreenshot ? [attachment] : []
        })
    } catch as e {
       ; MsgBox("❌ Webhook error: " e.Message)
    }

    if hasScreenshot
        FileDelete(ScreenshotPath)
}

GetWinrate() {
    global SuccessCount, FailCount
    totalRuns := SuccessCount + FailCount
    if (totalRuns > 0) {
        winratePercent := Round((SuccessCount / totalRuns) * 100, 2)
        global winChance := winratePercent
        return winratePercent "% (" SuccessCount "W/" FailCount "L)"
    }
    return "0%"
}

ConvertDelay(num) {
    return num * 1000
}

Zoom() {
    global modeDDL, mapDDL
    MoveMouseRelative(1, 0)

    Loop 20 {
        SendInput("{WheelUp}")
        Sleep(50)
    }
    selectedMode := modeDDL.Text
    selectedMap := mapDDL.Text
    MouseLookDown(2550, 0)

    Loop 20 {
        SendInput("{WheelDown}")
        Sleep(50)
    }

    if modeDDL.Text = "Survival" || mapDDL.Text = "Holy Invasion" {
        SendInput("{WheelDown}")
        Sleep(50)
        SendInput("{WheelDown}")
        Sleep(50)
    }
}

MoveMouseRelative(x, y) {
    DllCall("mouse_event", "UInt", 0x01, "UInt", x, "UInt", y, "UInt", 0, "UPtr", 0)
}

MouseLookDown(totalY := 150, stepDelay := 10) {
    DllCall("mouse_event", "UInt", 0x08, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)

    step := 5
    steps := totalY // step

    Loop steps {
        MoveMouseRelative(0, step)
        Sleep(stepDelay)
    }

    DllCall("mouse_event", "UInt", 0x10, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
}

SetupGame() {
    global StageStartTime := A_TickCount
    global mapDDL, modeDDL
    global AdjustedOpacity := true
    mapName := MapDDL.Text
    mode := modeDDL.Text
    SendInput("{Tab}")
    Sleep(175)
    FixClick(687, 104)
    Sleep(175)
    FixClick(687, 193)
    CloseChat()
    TpSpawn() 
    Zoom()
    if mode == "Cavern" {
        HandleMapMovement(mode)
    }
    HandleMapMovement(mapName)
    Sleep(1000)
    StartGame()
}

ValidateMode() {
    global actDDL, modeDDL, mapDDL, ConfirmModeBtn

    if ConfirmModeBtn.Visible {
        return false
    } else {
        return true
    }
}

ValidateEnabledUnits() {
    global unitControls
    hasEnabledUnits := false

    for page, units in unitControls {
        for unitNum, ctrlGroup in units {
            isEnabled := ctrlGroup.checkbox.Value
            x := ctrlGroup.xEdit.Value
            y := ctrlGroup.yEdit.Value

            if (isEnabled && (x = "" || y = "")) {
                ctrlGroup.checkbox.Value := false
            }

            if (ctrlGroup.checkbox.Value) {
                hasEnabledUnits := true
            }
        }
    }
    return hasEnabledUnits
}

StartMode(Mode) {
    switch Mode {
        case "Raids":
            RaidMode()
        case "Legend Stage":
            LegendMode()
        case "Story":
            StoryMode()
        case "Cavern":
            CavernMode()
        case "Survival":
            SurvivalMode()
        case "Challenges":
            ChallengeMode()
        case "Easter Event":
            EasterMode()
        case "Portals":
            PortalMode()
    }
}

RestartStage(mode:=false) {
    global modeDDL, mapDDL
    SetupGame()
    PlacingUnits() 
}

StartMacro(){
    global modeDDL, actDDL, mapDDL, UpgModeSelect, UpgMode

    if !ValidateEnabledUnits() {
        MsgBox("No enabled units with valid coordinates found. Please configure your units.")
        return
    }

    if !ValidateMode {
        return
    }

    mode := modeDDL.Text
    return StartMode(mode)
}

ComparePlacePriorities(a, b) {
    global GuiState
    aPrio := GuiState.Has("PlaceSlot" a.slot) ? Integer(GuiState["PlaceSlot" a.slot]) : 999
    bPrio := GuiState.Has("PlaceSlot" b.slot) ? Integer(GuiState["PlaceSlot" b.slot]) : 999
    return aPrio - bPrio
}

CompareSlotPriorities(a, b) {
    global GuiState
    aPrio := GuiState.Has("Slot" a.slot) ? Integer(GuiState["Slot" a.slot]) : 999
    bPrio := GuiState.Has("Slot" b.slot) ? Integer(GuiState["Slot" b.slot]) : 999
    return aPrio - bPrio
}

PlacingUnits() {
    global modeDDL
    global unitControls, successfulCoordinates
    successfulCoordinates := []
    StageStartTime := A_TickCount
    totalUnits := 0
    placedUnits := 0

    local sorted := []
    for slotNum, units in unitControls {
        for unitNum, ctrlGroup in units {
            if !IsInteger(unitNum) || !ctrlGroup.checkbox.Value
                continue
            x := ObjHasOwnProp(ctrlGroup, "screenX") ? ctrlGroup.screenX : ""
            y := ObjHasOwnProp(ctrlGroup, "screenY") ? ctrlGroup.screenY : ""
            if (x = "" || y = "")
                continue
    
            totalUnits++
            sorted.Push({x: x, y: y, slot: slotNum, unit: unitNum, screenX: x, screenY: y})
        }
    }

    Loop sorted.Length - 1 {
        Loop sorted.Length - A_Index {
            a := sorted[A_Index]
            b := sorted[A_Index + 1]
            if ComparePlacePriorities(a, b) > 0 {
                temp := sorted[A_Index]
                sorted[A_Index] := sorted[A_Index + 1]
                sorted[A_Index + 1] := temp
            }
        }
    }

    for idx, unit in sorted {
        if Disconnected() 
            FixDisconnect()

        if IsInLobby()
            return CheckLobby()

        slotNum := unit.slot
        unitNum := unit.unit
        x := unit.x
        y := unit.y

        retryCount := 0
        maxRetries := 100
    while (retryCount < maxRetries) {
        if Disconnected() 
            FixDisconnect()

        if RetryCheckMode(modeDDL.Text) {
            return RestartStage()
        }

    if PlaceUnit(x, y, slotNum) {
        successfulCoordinates.Push(unit)
        placedUnits++
        break
    }
    retryCount++
    Sleep(500)
}

        if (retryCount >= maxRetries)

        Sleep(300)
    }

    if (totalUnits = placedUnits) {

    } else {

    }
    UpgradeUnits()
}

UpgradeUnits() {
    global successfulCoordinates, unitControls, UpgModeSelect, modeDDL, GuiState, modeDDL

    if (successfulCoordinates.Length = 0)
        return

    UpgMode := UpgModeSelect.Text
    static singleIndex := 1
    global shouldRun := true
    mode := modeDDL.Text
    singleIndex := 1

    sortedCoords := successfulCoordinates.Clone()

    Loop sortedCoords.Length - 1 {
        Loop sortedCoords.Length - A_Index {
            a := sortedCoords[A_Index]
            b := sortedCoords[A_Index + 1]
            if CompareSlotPriorities(a, b) > 0 {
                temp := sortedCoords[A_Index]
                sortedCoords[A_Index] := sortedCoords[A_Index + 1]
                sortedCoords[A_Index + 1] := temp
            }
        }
    }

    loop 60000 {
        static loggedAllMaxed := false 
    
        maxedCount := 0
        for unit in sortedCoords {
            key := unit.slot "_" unit.unit
            if MaxedUnits.Has(key)
                maxedCount++
        }
    
        if (maxedCount = sortedCoords.Length) {
            if !loggedAllMaxed {
                loggedAllMaxed := true
            }   
            FixClick(500, 515)
            Sleep(1000)

            if Disconnected() 
                FixDisconnect()
        
            if RetryCheckMode(mode) {
                successfulCoordinates := []
                return RestartStage(mode)
            }
        } else {
            loggedAllMaxed := false 
        }
    
        loop sortedCoords.Length {
            idx := (UpgMode = "Single") ? singleIndex : A_Index
            if (idx > sortedCoords.Length)
                break
    
            unit := sortedCoords[idx]
            slot := unit.slot
            unitNum := unit.unit
    
            if !unitControls.Has(slot)
                continue
    
            key := slot "_" unitNum
            if MaxedUnits.Has(key)
                continue

            if Disconnected() 
                FixDisconnect()
    
            if RetryCheckMode(mode) {
                successfulCoordinates := []
                return RestartStage(mode)
            }
    
            UpgradeUnit(unit.screenX, unit.screenY, unitNum, slot)
            Sleep(150)
    
            Sleep(175)
            FixClick(500, 550)
            FixClick(500, 550)
            if (UpgMode = "Single") {
                singleIndex++
                if (singleIndex > sortedCoords.Length)
                    singleIndex := 1
                break
            }
        }
    }
}

UpgradeUnit(x, y, unit, slot) {
    FixClick(x, y)
    Sleep(175)
    if CheckMaxLvl(x, y, slot, unit)
        return 
    AbilityCheck()
    FixClick(165, 405)
    Sleep(175)
    FixClick(165, 405)
    Sleep(125)
}

GetElementCoords(elm) {
    switch elm {
        case "Water": 
            return { x: 250, y: 220, scroll: 0}
        case "Fire": 
            return { x: 250, y: 280, scroll: 0}
        case "Nature": 
            return { x: 250, y: 340, scroll: 0}
        case "Dark": 
            return { x: 250, y: 390, scroll: 0}
        case "Light": 
            return { x: 250, y: 460, scroll: 0}
        default:
            MsgBox("❌ Unknown element selected: " elm)
            return { x: 0, y: 0, scroll: 0 }
    }
}

ToggleUnitGuide() {
    global UnitGuideGUI, IsUnitGuideVisible

    if IsSet(UnitGuideGUI) && UnitGuideGUI && IsUnitGuideVisible {
        UnitGuideGUI.Hide()
        IsUnitGuideVisible := false
    } else {
        ShowUnitGuide()
        IsUnitGuideVisible := true
    }
}

ShowUnitGuide() {
    global UnitGuideGUI, ImageControl, CurrentGuideIndex

    if IsSet(UnitGuideGUI) && UnitGuideGUI
        UnitGuideGUI.Destroy()

    UnitGuideGUI := Gui("+AlwaysOnTop +Border", "Unit Guide")
    UnitGuideGUI.BackColor := "0x1E1E1E"
    UnitGuideGUI.SetFont("s9", "Segoe UI")

    ; Prev & Next buttons
    UnitGuideGUI.Add("Button", "x20 y10 w60 h25", "<<").OnEvent("Click", (*) => GuidePrevPage())
    UnitGuideGUI.Add("Button", "x780 y10 w60 h25", ">>").OnEvent("Click", (*) => GuideNextPage())

    ; Enlarged image area
    ImageControl := UnitGuideGUI.Add("Picture", "x20 y50 w820 h460 Border")

    LoadGuidePage(PageOrder[CurrentGuideIndex])
    UnitGuideGUI.Show("w880 h530")
}

GuideNextPage() {
    global CurrentGuideIndex, PageOrder

    if (CurrentGuideIndex < PageOrder.Length) {
        CurrentGuideIndex++
        LoadGuidePage(PageOrder[CurrentGuideIndex])
    }
}

GuidePrevPage() {
    global CurrentGuideIndex

    if (CurrentGuideIndex > 1) {
        CurrentGuideIndex--
        LoadGuidePage(PageOrder[CurrentGuideIndex])
    }
}

LoadGuidePage(name) {
    global PageImages, ImageControl

    if !PageImages.Has(name)
        return MsgBox("Page '" name "' not found.")

    imagePath := PageImages[name]
    if !FileExist(imagePath)
        return MsgBox("Missing image file:`n" imagePath)

    ImageControl.Value := imagePath
}

SaveUnitLayout(*) {
    global unitControls, modeDDL, mapDDL

    mode := modeDDL.Text
    map := mapDDL.Text

    if (mode = "" || map = "") {
        MsgBox("Please select both a mode and map before saving.")
        return
    }

    section := mode "|" map
    file := "lib\unit_layouts.ini"

    for page, units in unitControls {
        for unitNum, ctrl in units {
            prefix := "U" page "_" unitNum
            enabled := ctrl.checkbox.Value
            x := ctrl.xEdit.Value
            y := ctrl.yEdit.Value

            IniWrite(enabled, file, section, prefix "_enabled")
            IniWrite(x, file, section, prefix "_x")
            IniWrite(y, file, section, prefix "_y")
        }
    }

    MsgBox("Unit layout saved for " mode " - " map)
}

LoadUnitLayout() {
    global unitControls, modeDDL, mapDDL

    mode := modeDDL.Text
    map := mapDDL.Text
    if (mode = "" || map = "")
        return

    section := mode "|" map
    file := "lib\unit_layouts.ini"

    for page, units in unitControls {
        for unitNum, ctrl in units {
            prefix := "U" page "_" unitNum

            enabled := IniRead(file, section, prefix "_enabled", "")
            x := IniRead(file, section, prefix "_x", "")
            y := IniRead(file, section, prefix "_y", "")

            ctrl.checkbox.Value := (enabled = "1")
            ctrl.xEdit.Value := x
            ctrl.yEdit.Value := y
        }
    }
}

SaveSettings(*) {
    global WebhookURLEdit, PingUser, DiscordUserIDEdit, SendScreenshot, WebhookEnabled
    global UpgMode, DifSwitch

    file := "lib\settings.ini"

    ; Webhook + Discord
    IniWrite(WebhookURLEdit.Text, file, "Discord", "WebhookURL")
    IniWrite(DiscordUserIDEdit.Text, file, "Discord", "UserID")
    IniWrite(WebhookEnabled.Value ? "1" : "0", file, "Discord", "Enabled")
    IniWrite(PingUser.Value ? "1" : "0", file, "Discord", "Ping")
    IniWrite(SendScreenshot.Value ? "1" : "0", file, "Discord", "Screenshot")

    ; Upgrade settings
    IniWrite(UpgMode, file, "Upgrade", "Mode")

    ; Difficulty setting (optional)
    IniWrite(DifSwitch.Text, file, "Game", "Difficulty")

    MsgBox("Settings saved successfully.")
}

LoadSettings() {
    global WebhookURLEdit, PingUser, DiscordUserIDEdit, SendScreenshot, WebhookEnabled
    global UpgMode, UpgModeSelect, DifSwitch

    file := "lib\settings.ini"

    WebhookURLEdit.Text := IniRead(file, "Discord", "WebhookURL", "")
    DiscordUserIDEdit.Text := IniRead(file, "Discord", "UserID", "")
    WebhookEnabled.Value := IniRead(file, "Discord", "Enabled", "0")
    PingUser.Value := IniRead(file, "Discord", "Ping", "0")
    SendScreenshot.Value := IniRead(file, "Discord", "Screenshot", "0")

    savedMode := IniRead(file, "Upgrade", "Mode", "Multi")
    UpgMode := savedMode
    UpgModeSelect.Text := savedMode

    DifSwitch.Text := IniRead(file, "Game", "Difficulty", "Normal")
}

AbilityCheck() {
    global AutoAbility
    if AutoAbility.Value {
        if Pixel(0xC22725, 334, 315, 4, 4, 20) || Pixel(0xC0272C, 336, 331, 4, 4, 20) || Pixel(0xFF2C2C, 333, 293, 4, 4, 20) {
            FixClick(FoundX, FoundY)
        }
    } 
}

c::ExitApp()