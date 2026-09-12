' Silently launches smtc-bridge.exe and SMTC-Widget-Proxy.exe together,
' with no console windows or flashes.
'
' Setup:
'   1. Put this file in the SAME folder as smtc-bridge.exe and SMTC-Widget-Proxy.exe.
'   2. Edit the two filenames below if yours are named differently.
'   3. To auto-run at login: press Win+R, type shell:startup, hit Enter,
'      then copy this .vbs file (or a shortcut to it) into that folder.
'
' Double-clicking this file directly also works any time you want to start
' both apps manually without opening a terminal.

Dim fso, shell, scriptDir

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

' 0 = hidden window, False = don't wait for it to exit before continuing
shell.Run """" & scriptDir & "\smtc-bridge.exe""", 0, False
shell.Run """" & scriptDir & "\SMTC-Widget-Proxy.exe""", 0, False
