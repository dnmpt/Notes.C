;╔═══════════════════════════════════════════════════════════════════════════════╗
;║                       FileIO.pb  - version 0.11-alpha                         ║
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
;║ Handles File Operations (read/write) for program Notes.C .                    ║
;║                                                                               ║
;╚═══════════════════════════════════════════════════════════════════════════════╝ 


;Update status bar after i/o operations
Procedure UpdateStatusBar()
  Protected Text$ =  "Note ID : " + Str(NoteID) + "   | Filename : " + DatabaseFile$
  StatusBarText(0,0,Text$)
  Text$ = "Created : " + FormatDate("%dd/%mm/%yyyy", DateCreated) + "   | Last modified : " + FormatDate("%dd/%mm/%yyyy", DateLast)
  StatusBarText(0,1,Text$)
EndProcedure


;Finds the records current/last position (NoteID)
Procedure.l FindMyPosition()

  Protected Text4Query$ = "Select NoteID FROM NotesDB"
  If DatabaseQuery(#MyDATABASE, Text4Query$) 
    While NextDatabaseRow(#MyDATABASE)                  
      Protected c.l = GetDatabaseLong(#MyDATABASE, 0)
    Wend
    FinishDatabaseQuery(#MyDATABASE)
    ProcedureReturn c
  Else
    ProcedureReturn #False
  EndIf 
  
EndProcedure


; Save Tags "#" And "@" into database
Procedure SaveTags(MyTextWithTags$)
  
  ; Find and saves Hashtags '#'
  Protected x.l = 0
  Repeat
    x = FindString(MyTextWithTags$,"#", x + 1)
    If x <> 0
      Protected ExtractedString$ = Mid(MyTextWithTags$, x, FindString(MyTextWithTags$, " ", x) - x)
      CheckDatabaseUpdate(#MyDATABASE, "INSERT INTO HashtagDB (NoteID, Hashtag) VALUES ('" + Str(NoteID) +"', '" + ExtractedString$ + "')")
    EndIf
  Until x = 0
  
  ; Find and saves Recipients '@'
  x = 0
  Repeat
    x = FindString(MyTextWithTags$,"@", x + 1)
    If x <> 0
      ExtractedString$ = Mid(MyTextWithTags$, x, FindString(MyTextWithTags$, " ", x) - x)
      CheckDatabaseUpdate(#MyDATABASE, "INSERT INTO RecipientDB (NoteID, Recipient) VALUES ('" + Str(NoteID) + "', '" + ExtractedString$ + "')")
    EndIf
  Until x = 0 
EndProcedure  


; Handles menu "Save"
Procedure SaveMyFile()
  
  Protected Text$ = GetScintillaAllText(Scintilla_0) ; Gets the content of Scintilla !  
  DateLast = Date()
   
  If DatabaseConnected = #True     
    Protected Modified.b = ScintillaSendMessage(Scintilla_0, #SCI_GETMODIFY) ; Check if text was modified since last save
    
    If Modified > 0
      If NoteID > 0
        ;SQL insert
        Protected Text4Query$ = "UPDATE NotesDB SET Note = '" + Text$
        Text4Query$ +"', Format = '" +  GetScintillaFormat(Scintilla_0) + "', DateLast = '" + Str(DateLast)
        Text4Query$ + "' WHERE NoteID = '" + Str(NoteID)+"'"
        CheckDatabaseUpdate(#MyDATABASE, Text4Query$)     
        ScintillaSendMessage(Scintilla_0, #SCI_SETSAVEPOINT)    ;scintilla savepoint notification
        UpdateStatusBar()
        ; -------------------------->>>>>>>>>>>>>>>>>>>>>>>>>> ToDo : Colocar a rotina de verificar os hashtags [LisIcon versus findstring(Text$)]    
      Else
        DateCreated = Date()
        Text4Query$ = "INSERT INTO NotesDB (Note, Format, DateNew, DateLast) VALUES ('" 
        Text4Query$ + Text$ + "', '" + GetScintillaFormat(Scintilla_0) + "', '" + Str(DateCreated) + "', '"+ Str(DateLast)+ "')"
        CheckDatabaseUpdate(#MyDatabase, Text4Query$)  ; SQL command execute INSERT NEW
        NoteID = FindMyPosition()
        ScintillaSendMessage(Scintilla_0, #SCI_SETSAVEPOINT) ;scintilla savepoint notification
        SaveTags(Text$)
        UpdateStatusBar()
      EndIf
    EndIf 
  Else
    DatabaseFile$ = SaveFileRequester("New File","noname.sqlite", "sqlite DB (*.sqlite)|*.sqlite|All Files (*.*)|*.*",0)    
    If DatabaseFile$<>""    
      Protected Error.l = HandleMyError(CreateFile(#MyFile,DatabaseFile$),"File creation failure!",0)     
      If Error = #False
        CloseFile(#MyFile)
        
        Protected NewError.l = HandleMyError(OpenDatabase(#MyDATABASE, DatabaseFile$, "", "",#PB_Database_SQLite),"DataBase connection failure!",0)
        If NewError = #False
          ; Creation of a new Tables
          CheckDatabaseUpdate(#MyDATABASE, "CREATE TABLE NotesDB (NoteID INTEGER PRIMARY KEY AUTOINCREMENT, Note CHAR, Format CHAR, DateNew INT, DateLast INT)")
          CheckDatabaseUpdate(#MyDATABASE, "CREATE TABLE HashtagDB (H_ID INTEGER PRIMARY KEY AUTOINCREMENT, NoteID INT, Hashtag CHAR)")
          CheckDatabaseUpdate(#MyDATABASE, "CREATE TABLE RecipientDB (R_ID INTEGER PRIMARY KEY AUTOINCREMENT, NoteID INT, Recipient CHAR)")
          
          ; Saves the current content, if any ...
          DateCreated = Date()
          Text4Query$ = "INSERT INTO NotesDB (Note, Format, DateNew, DateLast) VALUES ('" 
          Text4Query$ + Text$ + "', '" + GetScintillaFormat(Scintilla_0) + "', '" + Str(DateCreated) + "', '"+ Str(DateLast)+ "')"
          CheckDatabaseUpdate(#MyDatabase, Text4Query$)  ; SQL command execute INSERT NEW
          ScintillaSendMessage(Scintilla_0, #SCI_SETSAVEPOINT)  ;scintilla savepoint notification
          NoteID = 1
          
          SaveTags(Text$)
          UpdateStatusBar()
          
          DatabaseConnected=#True
          
          MessageRequester("Success!", "File Saved sucessfully!", #PB_MessageRequester_Info)
        EndIf
      EndIf
    EndIf
  EndIf
EndProcedure  

;Routine for checking if text was modified and have the option to save it
Procedure.b CheckModifiedAndSave()
    Protected Modified.b = ScintillaSendMessage(Scintilla_0, #SCI_GETMODIFY) ; Check if text was modified since last save
  
  If Modified > 0  ; If modified from last save, ask question to save ...
    Protected Answer.l = MessageRequester("Question?","Save current Note ?", #PB_MessageRequester_Warning | #PB_MessageRequester_YesNoCancel)
    
    Select Answer 
      Case #PB_MessageRequester_Cancel
        ProcedureReturn #False ; Case CANCEL - the only option that remain the "as is" !
      Case #PB_MessageRequester_Yes
        SaveMyFile()      ; Saves if YES
        ProcedureReturn #True
      Default  ; Case #PB_MessageRequester_No
        ProcedureReturn #True
    EndSelect
  Else
    ProcedureReturn #True ; Case not modified
  EndIf
EndProcedure


; Handles menu Open
Procedure OpenMyFile()
  
  Static OldDatabaseFile$
  
  If CheckModifiedAndSave() = #True  ; LOAD operations
    DatabaseFile$ = OpenFileRequester("Open File","", "sqlite DB (*.sqlite)|*.sqlite|Todos (*.*)|*.*",0)
    
    If DatabaseFile$ <> ""
      
      If DatabaseConnected = #True
        HandleMyError(CloseDatabase(#MyDATABASE),"Error closing previous File!",1)
      EndIf
      
      Protected Error.l = HandleMyError(OpenDatabase(#MyDATABASE, DatabaseFile$, "", "",#PB_Database_SQLite),"Error opening File!",0)
      
      If Error = #False
        DatabaseConnected=#True
        OldDatabaseFile$ = DatabaseFile$  ; Keep records of previous file for reconnecting if necessary !
        ScintillaSendMessage(Scintilla_0, #SCI_SETREADONLY,0) ; Desprotect any text in Scintilla !
        ScintillaSendMessage(Scintilla_0, #SCI_CLEARALL)
        
        If DatabaseQuery(#MyDATABASE, "SELECT * FROM NotesDB")           
          While NextDatabaseRow(#MyDATABASE)
            Protected Text$ = GetDatabaseString(#MyDATABASE, 1)
            Protected Format$ = GetDatabaseString(#MyDATABASE,2)
            MyScintillaText(Scintilla_0, Text$, Format$, 1)
            NoteID = GetDatabaseLong(#MyDATABASE,0)
            DateCreated = GetDatabaseLong(#MyDATABASE,3)
            DateLast = GetDatabaseLong(#MyDATABASE,4)
            
            Text$ = #CRLF$ + "NoteID [" + Str(NoteID) + "] - Created/Modified : " + FormatDate("%dd/%mm/%yyyy", DateCreated) + " - " + FormatDate("%dd/%mm/%yyyy", DateLast) + #CRLF$
            Format$ = "00"
            
            Protected x.l = 3 ; 2 charaters are skiped = Chr(10) + Chr(13)
            For x = 3 To Len(Text$)
              Format$ + "6"
            Next x
            
            MyScintillaText(Scintilla_0, Text$, Format$, 1)
          Wend
          FinishDatabaseQuery(#MyDATABASE)
        EndIf
        

        ContractFoldsScintilla(Scintilla_0)
        ScintillaSendMessage(Scintilla_0, #SCI_SETSAVEPOINT)
        ScintillaSendMessage(Scintilla_0, #SCI_EMPTYUNDOBUFFER)
        ScintillaSendMessage(Scintilla_0, #SCI_SETREADONLY,1)
        UpdateStatusBar()
        
        MessageRequester("Success!","File Loaded successfully!", #PB_MessageRequester_Info)
      Else
        If DatabaseConnected=#True
          HandleMyError(OpenDatabase(#MyDATABASE, OldDatabaseFile$, "", "",#PB_Database_SQLite),"Error loading previous File!",1)  ;On error tries to reconnect to previous file ...
        EndIf  
      EndIf
    EndIf
  EndIf  
EndProcedure


; Handles Menu "New"
Procedure NewNoteOrFile()  
 ScintillaSendMessage(Scintilla_0, #SCI_SETREADONLY,0) ; Desprotect any text in Scintilla !
  
 If CheckModifiedAndSave() = #True
   NoteID = 0
   ScintillaSendMessage(Scintilla_0, #SCI_CLEARALL)
   ScintillaSendMessage(Scintilla_0, #SCI_SETSAVEPOINT)  ;scintilla savepoint notification    
 EndIf 
EndProcedure


Procedure CloseMyFile()
   
  If (DatabaseConnected = #True) And (CheckModifiedAndSave() = #True)
    HandleMyError(CloseDatabase(#MyDATABASE),"Error closing previous File!",1)
    DatabaseConnected = #False
    NoteID = 0
    DatabaseFile$ = ""
    DateCreated = Date()
    DateLast = Date()
    ScintillaSendMessage(Scintilla_0, #SCI_SETREADONLY,0) ; Desprotect any text in Scintilla !
    ScintillaSendMessage(Scintilla_0, #SCI_CLEARALL)
    ScintillaSendMessage(Scintilla_0, #SCI_EMPTYUNDOBUFFER)
    ScintillaSendMessage(Scintilla_0, #SCI_SETSAVEPOINT)  ;scintilla savepoint notification    
    UpdateStatusBar()
  EndIf
EndProcedure

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 1
; Folding = --
; EnableXP