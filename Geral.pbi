;╔═══════════════════════════════════════════════════════════════════════════════╗
;║                          Geral.pbi  - version 0.11-alpha                      ║
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
;║ General library with error handling and other routines that can be            ║
;║ usefull for   any program.                                                    ║
;╚═══════════════════════════════════════════════════════════════════════════════╝ 


; Handles any SYSTEM error that occurs
Procedure ErrorHandler()
  Protected ErrorMsg.s = "Error code:" + #TAB$ + Str(ErrorCode()) + #CRLF$
  ErrorMsg + "Error description:" + #TAB$ + ErrorMessage() + #CRLF$
  ErrorMsg + "Occured on line:" + #TAB$ + Str(ErrorLine()) + #CRLF$
  ErrorMsg + "Occured on file:" + #TAB$ + ErrorFile() + #CRLF$
  ErrorMsg + #CRLF$ + "The program will now EXIT !"
  Protected AnswerBox.l = MessageRequester("ERROR", ErrorMsg, #PB_MessageRequester_Ok!#PB_MessageRequester_Error)
EndProcedure ; Program will always exit on ending the procedure ErrorHandler


; Handles any I/O error that occurs
Procedure HandleMyError (Result.l, ErrorMsg.s, Critical.l = 0) ; Optional 'Critical.l = 0' (= No, it can be choose either to proceed or not)
  If Result = 0
    If Critical = 0
      Protected AnswerBox.l = MessageRequester("ERROR", ErrorMsg + #CRLF$ + #CRLF$ + "Do you want to continue ?", #PB_MessageRequester_YesNo|#PB_MessageRequester_Error)
      If AnswerBox = #PB_MessageRequester_No
        End ; Ends program
      Else
        ProcedureReturn #True ;Returns a True value, signalizing that an Error happened but execution proceeded !
      EndIf
    Else
      AnswerBox.l = MessageRequester("Critical ERROR", ErrorMsg + #CRLF$ + #CRLF$ + "Critical Error !" + #CRLF$ + #CRLF$ + "Program will exit ...", #PB_MessageRequester_Ok|#PB_MessageRequester_Error)
      End
    EndIf
  EndIf
  ProcedureReturn #False ; Returns False value signalizing that an error didn't happened.
EndProcedure


; Handles DataBase operations check
Procedure CheckDatabaseUpdate(Database, Query$)
   Protected Result = DatabaseUpdate(Database, Query$)
   If Result = 0
     Protected Erro$ = DatabaseError()
      MessageRequester("Error",Erro$,#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
   EndIf
   ProcedureReturn Result
 EndProcedure
 
 
;Disables deselection (state -1) in a ListIcon Gadget
 Procedure NoDeselection(MyGadget.l , ByDefault.l)
   If GetGadgetState(MyGadget) <0
     SetGadgetState(MyGadget,ByDefault)
   EndIf   
 EndProcedure
 
 ; Searches for a text removing special characters before and after
 Procedure.s RemoveSpecialChars(MyText$)
   
   Protected Char1.s{1} = MyText$                        ; String of 1 character lenght for searching step by step
   
   While (Char1 = Chr(10)) Or (Char1 = Chr(13)) Or (Char1 = " ")  ;Removes end of lines characters in the begin.
     MyText$ = LTrim(MyText$, Chr(10))                      ;#LF
     MyText$ = LTrim(MyText$, Chr(13))                      ;#CR
     MyText$ = LTrim(MyText$)                               ; SPACE
     Char1 = MyText$
   Wend
   
   If FindString(MyText$, Chr(10), 1) <> 0
     MyText$ = Mid(MyText$, 1,FindString(MyText$, Chr(10), 1) - 1) ; Only gets a text until end of line chr(10) : #LF
   EndIf
   
   If FindString(MyText$, Chr(13), 1) <> 0
     MyText$ = Mid(MyText$, 1,FindString(MyText$, Chr(13), 1) - 1) ; Only gets a text until end of line chr(13) : #CR
   EndIf
   
   If MyText$ ="" : MyText$ = "No Text!" : EndIf   ; If not finds a end of line character chr(10) ou chr(13)
   
   ProcedureReturn MyText$
 EndProcedure   
 
 
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP