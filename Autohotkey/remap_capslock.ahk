;press caps-lock with hjkl to mimic arrow keys
#IF, GetKeyState("Capslock", "P") ;physischer Status: nur bei gedrücktem Capslock
	k::Up
	h::Left
	j::Down
	l::Right

;disable all other caps lock functionality
CapsLock::		; CapsLock
+CapsLock::	; Shift+CapsLock
!CapsLock::	; Alt+CapsLock
^CapsLock::		; Ctrl+CapsLock
#CapsLock::		; Win+CapsLock
^!CapsLock::	; Ctrl+Alt+CapsLock
^!#CapsLock::	; Ctrl+Alt+Win+CapsLock
;............	; You can add whatever you want to block
return			; Do nothing, return
