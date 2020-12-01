;  #NoTrayIcon
#SingleInstance Force

SetCapsLockState, AlwaysOff

setWindowPosition(splitX, splitY, posX, posY, widthMultiplier = 1, heightMultiplier = 1, posXMultiplier = 1, posYMultiplier = 1)
{

    margin := 0
    Mon2x := -174
    Mon2y := 1440
    Mon2Width := 1920 
    Mon2Height := 1080
    Mon1Width := 3440 
    Mon1Height := 1440


    WinGetPos, MMWinGetX, MMWinGetY, , , A
    monX := 0
    monY := 0
    monWidth = %Mon1Width%
    monHeight := Mon1Height


    if (MMWinGetY >= Mon2y)
    {
        monX := Mon2x
        monY := Mon2y
        monWidth := Mon2Width
        monHeight := Mon2Height
    }
    ;MsgBox, %monX%, %monY%, %monWidth%, %monHeight%
    WinGetTitle, title, A
    WinRestore, %title%
    WinMove, %title%,, ((monWidth/splitX) * (posX-1) * posXMultiplier) + monX, ((monHeight/splitY) * (posY - 1) * posYMultiplier ) + monY, (monWidth/splitX) * widthMultiplier,  (monHeight/splitY) * heightMultiplier
    return
}

return ; -----------------  end of autoload -----------------------------------

CapsLock::
    Send {Escape}
return

Control & k::
    Send {Up}
return

Control & j::
    Send {Down}
return

Alt & Escape::
   Send {Alt Shift Tab}
return

!q::
    Send !{F4}
return

; upper left corner
#!1::
setWindowPosition(2, 2, 1, 1)
return

; upper right corner
#!2::
setWindowPosition(2, 2, 2, 1)
return

; lower left corner
#!3::
setWindowPosition(2, 2, 1, 2)
return

; lower right corner
#!4::
setWindowPosition(2, 2, 2, 2)
return

; center of screen
#!5::
setWindowPosition(4, 4, 2, 2, 3, 3, 0.5, 0.5)
return

; whole screen (not fullscreen)
#!6::
setWindowPosition(1, 1, 1, 1)
return

; left half
#!7::
setWindowPosition(2, 1, 1, 1)
return

; right half
#!8::
setWindowPosition(2, 1, 2, 1)
return

; left 1/3
#!9::
setWindowPosition(3, 1, 1, 1)
return

; middle 1/3
#!0::
setWindowPosition(3, 1, 2, 1)
return

;key (us) = -
; right 1/3
#!SC00C::
setWindowPosition(3, 1, 3, 1)
return

; key (us) = [
; left 2/3
#!SC01A:: 
setWindowPosition(3, 1, 1, 1, 2, 1)
return


; key (us) = ]
; right 2/3
#!SC01B::
setWindowPosition(3, 1, 2, 1, 2, 1)
return

; key us = =
; move window to next screen and center it
#!SC00D::
MMPrimDPI := 1.0 ;DPI Scale of the primary monitor (divided by 100).
MMSecDPI := 2.0  ;DPI Scale of the secondary monitor (divided by 100).
SysGet, MMCount, MonitorCount
SysGet, MMPrimary, MonitorPrimary
SysGet, MMPrimLRTB, Monitor, MMPrimary
WinGetPos, MMWinGetX, MMWinGetY, MMWinGetWidth, MMWinGetHeight, A
MMDPISub := Abs(MMPrimDPI - MMSecDPI) + 1
;Second mon is off, window is lost, bring to primary
if ( (MMCount = 1) and !((MMWinGetX > MMPrimLRTBLeft + 20) and (MMWinGetX < MMPrimLRTBRight - 20) and (MMWinGetY > MMPrimLRTBTop + 20) and (MMWinGetY < MMPrimLRTBBottom - 20)) ){
    if ((MMPrimDPI - MMSecDPI) >= 0)
        MMWHRatio := 1 / MMDPISub
    Else
        MMWHRatio := MMDPISub
    MMWinMoveWidth := MMWinGetWidth * MMWHRatio
    MMWinMoveHeight := MMWinGetHeight * MMWHRatio
    WinMove, A,, 0, 0, MMWinMoveWidth, MMWinMoveHeight
    WinMove, A,, 0, 0, MMWinMoveWidth, MMWinMoveHeight ;Fail safe
    return
}
if (MMPrimary = 1)
    SysGet, MMSecLRTB, Monitor, 2
Else
    SysGet, MMSecLRTB, Monitor, 1
MMSecW := MMSecLRTBRight - MMSecLRTBLeft
MMSecH := MMSecLRTBBottom - MMSecLRTBTop
;Primary to secondary
if ( (MMWinGetX > MMPrimLRTBLeft - 20) and (MMWinGetX < MMPrimLRTBRight + 20) and (MMWinGetY > MMPrimLRTBTop - 20) and (MMWinGetY < MMPrimLRTBBottom + 20) ){
    if ( (MMSecW) and (MMSecH) ){ ;Checks if sec mon exists. Could have used MMCount instead: if (MMCount >= 2){}
        if ((MMSecDPI - MMPrimDPI) >= 0){
            MMWidthRatio := (MMSecW / A_ScreenWidth) / MMDPISub
            MMHeightRatio := (MMSecH / A_ScreenHeight) / MMDPISub
        }
        Else {
            MMWidthRatio := (MMSecW / A_ScreenWidth) * MMDPISub
            MMHeightRatio := (MMSecH / A_ScreenHeight) * MMDPISub            
        }
        MMWinMoveX := (MMWinGetX * MMWidthRatio) + MMSecLRTBLeft
        MMWinMoveY := (MMWinGetY * MMHeightRatio) + MMSecLRTBTop
        if (MMSecLRTBBottom - MMWinMoveY < 80) ;Check if window is going under taskbar and fixes it.
            MMWinMoveY -= 80
        MMWinMoveWidth := MMWinGetWidth * MMWidthRatio
        MMWinMoveHeight := MMWinGetHeight * MMHeightRatio
        WinMove, A,, MMWinMoveX, MMWinMoveY, MMWinMoveWidth, MMWinMoveHeight
        WinMove, A,, MMWinMoveX, MMWinMoveY, MMWinMoveWidth, MMWinMoveHeight
    }
} ;Secondary to primary
Else if ( (MMWinGetX > MMSecLRTBLeft - 20) and (MMWinGetX < MMSecLRTBRight + 20) and (MMWinGetY > MMSecLRTBTop - 20) and (MMWinGetY < MMSecLRTBBottom + 20) ){
    if ( (MMSecW) and (MMSecH) ){
        if ((MMPrimDPI - MMSecDPI) >= 0){
            MMWidthRatio := (A_ScreenWidth / MMSecW) / MMDPISub
            MMHeightRatio := (A_ScreenHeight / MMSecH) / MMDPISub
        }
        Else{
            MMWidthRatio := (A_ScreenWidth / MMSecW) / MMDPISub
            MMHeightRatio := (A_ScreenHeight / MMSecH) / MMDPISub
        }
        MMWinMoveX := (MMWinGetX - MMSecLRTBLeft) * MMWidthRatio
        MMWinMoveY := (MMWinGetY - MMSecLRTBTop) * MMHeightRatio
        if (MMPrimLRTBBottom - MMWinMoveY < 80)
            MMWinMoveY -= 80
        MMWinMoveWidth := MMWinGetWidth * MMWidthRatio
        MMWinMoveHeight := MMWinGetHeight * MMHeightRatio
        WinMove, A,, MMWinMoveX, MMWinMoveY, MMWinMoveWidth, MMWinMoveHeight
        WinMove, A,, MMWinMoveX, MMWinMoveY, MMWinMoveWidth, MMWinMoveHeight
    }
} ;If window is out of current monitors' boundaries or if script fails
Else{
    MsgBox, 4, MM, % "Current window is in " MMWinGetX " " MMWinGetY "`nDo you want to move it to 0,0?"
    IfMsgBox Yes
    WinMove, A,, 0, 0
}
; center on new screen
setWindowPosition(4, 4, 2, 2, 3, 3, 0.5, 0.5)
return
