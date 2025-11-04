;╔═══════════════════════════════════════════════════════════════════════════════╗
;║                          Notes_C.pb  - version 0.11-alpha                     ║
;╟───────────────────────────────────────────────────────────────────────────────╢
;║            Copyright 2021-2025  Duarte Mendes <duartenm@net.sapo.pt>          ║
;║                                                                               ║
;║ Permission is hereby granted, free of charge, To any person obtaining a copy  ║
;║ of this software And associated documentation files (the "Software"), To deal ║
;║ in the Software without restriction, including without limitation the rights  ║
;║ To use, copy, modify, merge, publish, distribute, sublicense, And/Or sell     ║
;║ copies of the Software, subject To the following conditions:                  ║
;║                                                                               ║
;║ The above copyright notice And this permission notice shall be included in    ║
;║ all copies Or substantial portions of the Software.                           ║     
;║                                                                               ║
;║ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,               ║
;║ EXPRESS Or IMPLIED, INCLUDING BUT Not LIMITED To THE WARRANTIES               ║
;║ OF MERCHANTABILITY, FITNESS For A PARTICULAR PURPOSE And NONINFRINGEMENT.     ║
;╟───────────────────────────────────────────────────────────────────────────────╢
;║ > PURPOSE :                                                                   ║
;║ Main source code for Program Notes.C # Includes Main Loop and event           ║
;║ handling.                                                                     ║
;╚═══════════════════════════════════════════════════════════════════════════════╝ 
 
 
; General Statements and Uses
EnableExplicit
UseSQLiteDatabase()

;ID enumeration constants for Files
Enumeration
  #MyFile
  #MyDATABASE
EndEnumeration

;Global variables to be used inside procedures also 
Global Window_0 ;default longint
Global DatabaseFile$ = ""
Global Quit.b = #False
Global DatabaseConnected.b = #False
Global NoteID.l = 0
Global DateCreated.l = Date()
Global DateLast.l = Date()
;Include Top Files (error handlers and Form)
XIncludeFile("Geral.pbi")
XIncludeFile("MyNotesForm.pbi")                                  ;<<<<<<<<<<<<<<<<<< Atention a Form transformed to Include File !
XIncludeFile("MyScintilla.pbi")
XIncludeFile("FileIO.pb")


Procedure Window_0_Events(event)
  Select event
    Case #PB_Event_CloseWindow
      ProcedureReturn #True
      
    Case #PB_Event_SizeWindow
      ;SetWindowPos_(Window_0, 0, 0, 0, width, height, #SWP_NOZORDER | #SWP_NOMOVE)
      
    Case #PB_Event_Menu
      Select EventMenu()
        Case #MenuItem_5
          If DatabaseConnected = #True
            HandleMyError(CloseDatabase(#MyDATABASE), "Error disconnecting DataBase!", 1)           
          EndIf
          ProcedureReturn #True
        Case #MenuItem_10
          NewNoteOrFile()
        Case #MenuItem_3
          SaveMyFile()
        Case #MenuItem_2
          OpenMyFile()
        Case #MenuItem_11
          CloseMyFile()
        Case #MenuItem_8
          MessageRequester("Scintilla", "     This software uses Scintilla" + #CRLF$ + #CRLF$ + "Copyright 1998-2003 by Neil Hodgson" + #CRLF$ + "       <neilh@scintilla.org>" + #CRLF$ + "        All Rights Reserved",#PB_MessageRequester_Info | #PB_MessageRequester_Ok)
        Case #MenuItem_9
          MessageRequester("About","         Notes.C - 'Notes collector'" + #CRLF$ + "   A simple place for complex ideas." + #CRLF$  + #CRLF$+ "      versão 0.11-alpha #20251104" + #CRLF$ + #CRLF$ + "Copyright (c) 2021-2025 by Duarte Mendes", #PB_MessageRequester_Info | #PB_MessageRequester_Ok)
        Case #Toolbar_Normal
          FormatTextScintilla(Scintilla_0, 0)
        Case #Toolbar_Bold
          FormatTextScintilla(Scintilla_0, 1)
        Case #Toolbar_Italic
          FormatTextScintilla(Scintilla_0, 2)
        Case #Toolbar_Title
          FormatTextScintilla(Scintilla_0, 3)
        Case #Toolbar_Code
          FormatTextScintilla(Scintilla_0, 4)
        Case #Toolbar_Highl
          FormatTextScintilla(Scintilla_0, 5)
      EndSelect
      
    Case #PB_Event_Gadget
      
      
      
  EndSelect
  ProcedureReturn #False
EndProcedure

;--------------------------------------------------------- MAIN LOOP -----------------------------------------------------------------
OpenWindow_0()

; Start Conditions Here ...

UpdateStatusBar()
MyScintillaText(Scintilla_0)
ScintillaSendMessage(Scintilla_0, #SCI_SETSAVEPOINT)  ;scintilla savepoint notification    


Repeat
  Define MyEvent.l = WaitWindowEvent()  ;Wait for an event
  Quit = Window_0_Events(MyEvent)
Until Quit = #True     ;End of Main Loop when Menu "Quit" is selected, or window is closed.
   
End

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 23
; Folding = -
; EnableXP
; Executable = NotesC.exe
; CompileSourceDirectory