;╔═══════════════════════════════════════════════════════════════════════════════╗
;║                     MyScintilla.pbi  - version 0.11-alpha                     ║
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
;║ Include file that handles Scintilla Gadget Operations.                        ║
;║                                                                               ║
;╚═══════════════════════════════════════════════════════════════════════════════╝ 
 
 
 ; Iniciação do Scintilla
;DEPRECATED in version 6.21   ;HandleMyError(InitScintilla(), "Não se consegue iniciar Scintilla!", 1)  ;>>>>>>>>>> Precisa do GERAL.pbi antes ...

;Scintilla Constant for MARGING FOLDING
#MARGIN_SCRIPT_FOLD_INDEX = 1 ;Margens de 0..4 . Neste caso é a margem = 1 que é folding 

;Message to collpase/expand folder - Margin 1 is sensitive
ScintillaSendMessage(Scintilla_0, #SCI_SETMARGINSENSITIVEN, #MARGIN_SCRIPT_FOLD_INDEX, #True)


 
;DEclaration of needed procedure
 Declare UpdateStatusBar()
 
 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>        SCINTILLA    PROCEDURES       <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Procedure.s GetScintillaLineText (MyGadget, LineNumber.l)
  
  Protected NumChar.l = ScintillaSendMessage(MyGadget, #SCI_LINELENGTH, LineNumber)  ; Gets the Lenght of All characthers in document (nLen)
  
  Protected *Text = AllocateMemory(NumChar +1) ; Allocates memory to buffer (note : Memmory comsumption of a string is nLen + 1)           
  ScintillaSendMessage(MyGadget, #SCI_GETLINE, LineNumber, *Text)   ; Gets UTF8 text to buffer with nLen size (including the 0 terminated)
  Protected text$ = PeekS(*Text, NumChar + 1, #PB_UTF8)                     ; Assign to a string.
  FreeMemory(*Text)
  
  ProcedureReturn text$

EndProcedure

;Read and Format text into Scintilla
Procedure MyScintillaText(MyGadget, MyText$ = "", MyFormat$ = "", ClearBefore.l = 0, InsertPos.l = 0)
  
   ; Scintilla Styles
 XIncludeFile("ScintillaStyles.pbi")
               
  Define *Text=UTF8(MyText$)

  If ClearBefore = 0
    ScintillaSendMessage(MyGadget, #SCI_CLEARALL)                             ; Clear All Text   
    ScintillaSendMessage(MyGadget, #SCI_SETTEXT, InsertPos, *Text)
  Else
    ScintillaSendMessage(MyGadget, #SCI_INSERTTEXT, InsertPos, *Text)
  EndIf
  
  FreeMemory(*Text) ; The buffer made by UTF8() has to be freed, to avoid memory leak
  
  ; Começa a aplicar a Formatação do texto no início do documento : posição "0"
  ScintillaSendMessage(MyGadget, #SCI_STARTSTYLING, InsertPos)
  
  Protected x.l = 1
  Define xChar.s{1}
  Define xForm.s{1}
  
  For x.l = 1 To Len(MyFormat$)   ;Aplica a formatação caracter a caracter a partir do string de formatação
    
    xForm = Mid(MyFormat$,x,1)
    xChar = Mid(MyText$,x,1)
    
    Protected FormatCode.l = Val(xForm)
    Protected Linha = ScintillaSendMessage(MyGadget,#SCI_LINEFROMPOSITION, x - 1) ; Verifica a linha da posição do caracter
    
    ScintillaSendMessage(MyGadget, #SCI_SETSTYLING,1, FormatCode)               ; Aplica a formatação ao caracter
    
    If (xChar <> Chr(10)) And (xChar <> Chr(13)) And (xChar <> Chr(9))  ; Folding das linhas de título (não conta com caracteres de quebra de linha e TAB)
      If FormatCode = 6
        ScintillaSendMessage(MyGadget,#SCI_SETFOLDLEVEL, Linha, 99 | #SC_FOLDLEVELHEADERFLAG)     ; Aplica o Folding se for Título
      Else
        ScintillaSendMessage(MyGadget,#SCI_SETFOLDLEVEL, Linha, #SC_FOLDLEVELBASE)                ; Não aplica o Fold se não for Título ...
      EndIf
    EndIf
      
  Next x
  
EndProcedure

;CALLBACK
Procedure ScintillaCallBack(MyGadget, *scinotify.SCNotification)
  
  Define modifiers = *scinotify\modifiers
  Define position = *scinotify\position
  Define margin = *scinotify\margin
  Define linenumber = ScintillaSendMessage(MyGadget, #SCI_LINEFROMPOSITION, position,0)
    
  Select *scinotify\nmhdr\code
    Case #SCN_MARGINCLICK
        If margin = #MARGIN_SCRIPT_FOLD_INDEX  ; alterna o fold na linha clicada
          ScintillaSendMessage(MyGadget, #SCI_TOGGLEFOLD, lineNumber, 0)
        EndIf

    Case #SCN_DOUBLECLICK   ;Answers for Scintilla modifications
      linenumber = ScintillaSendMessage(MyGadget, #SCI_GETFOLDPARENT, linenumber) ; First line is "0"
      If linenumber > -1
        Protected Text$ = GetScintillaLineText(MyGadget, LineNumber)
        Text$ = Mid(Text$, 1,FindString(Text$,"]",1)-1)
        NoteID = Val (Mid(Text$,FindString(Text$,"[",1)+1,Len(Text$)))
        
        ScintillaSendMessage(MyGadget, #SCI_SETREADONLY,0) ; Desprotect any text in Scintilla !   
        ScintillaSendMessage(MyGadget, #SCI_CLEARALL)
          
        If DatabaseQuery(#MyDATABASE, "SELECT * FROM NotesDB WHERE NoteID = '" + Str(NoteID)+"'")           
          While NextDatabaseRow(#MyDATABASE)
            Text$ = GetDatabaseString(#MyDATABASE, 1)
            Protected Format$ = GetDatabaseString(#MyDATABASE,2)
            DateCreated = GetDatabaseLong(#MyDATABASE,3)
            DateLast = GetDatabaseLong(#MyDATABASE,4)
          Wend
          MyScintillaText(MyGadget,Text$, Format$)
          ScintillaSendMessage(MyGadget, #SCI_EMPTYUNDOBUFFER)
          ScintillaSendMessage(MyGadget, #SCI_SETSAVEPOINT) 
        EndIf
        UpdateStatusBar()
      EndIf
           
    EndSelect
      
EndProcedure



; SCINTILLA - Acquire a String with style codes for each character
Procedure.s GetScintillaFormat(MyGadget) 
  
  Protected NumChar.l = ScintillaSendMessage(MyGadget, #SCI_GETLENGTH)  ; Get Lenght of Scintilla Document
  Protected MyFormat$ = ""
  
  Protected x.l = 0
  
  For x = 0  To NumChar - 1                                          ; O último é o caracter "0" END
    MyFormat$ + Str(ScintillaSendMessage(MyGadget, #SCI_GETSTYLEAT,x))
  Next x      
  
  ProcedureReturn MyFormat$
  
EndProcedure

; SCINTILLA - Acquire All Text in the Document
Procedure.s GetScintillaAllText (MyGadget)
  
  Protected NumChar.l = ScintillaSendMessage(MyGadget, #SCI_GETLENGTH)  ; Gets the Lenght of All characthers in document (nLen)
  
  Protected *Text = AllocateMemory(NumChar + 1) ; Allocates memory to buffer (note : Memmory comsumption of a string is nLen + 1)           
  ScintillaSendMessage(MyGadget, #SCI_GETTEXT, NumChar + 1, *Text)   ; Gets UTF8 text to buffer with nLen size (including the 0 terminated)
  Protected text$ = PeekS(*Text, NumChar + 1, #PB_UTF8)                     ; Assign to a string.
  FreeMemory(*Text)
  
  ProcedureReturn text$

EndProcedure

; SCINTILLA - Format selected Text
Procedure FormatTextScintilla(MyGadget, FormatCode.l)
  
  Protected SelStart.l = ScintillaSendMessage(MyGadget, #SCI_GETSELECTIONSTART) ; Início da seleção de texto
  Protected SelEnd.l = ScintillaSendMessage(MyGadget, #SCI_GETSELECTIONEND)     ; Fim da seleção de texto
  Protected Tamanho.l = SelEnd - SelStart
  
  If Tamanho > 0
    ScintillaSendMessage(MyGadget, #SCI_STARTSTYLING,SelStart)                         ; Começa a formatação na posição do início da seleção
    ScintillaSendMessage(MyGadget, #SCI_SETSTYLING,Tamanho, FormatCode)                ; Formata com o estico FormatCode (ver acima os Styles - MyScintillaText)
  EndIf
  
                                                        ;NOTE USED - to set Folders in Real Time , because style 6 is reserved
  ;Protected LinhaInicio = ScintillaSendMessage(MyGadget,#SCI_LINEFROMPOSITION, SelStart)
  
  ;If FormatCode = 6 ; Style 6 for Folders Titles
    ;ScintillaSendMessage(MyGadget,#SCI_SETFOLDLEVEL, LinhaInicio, 99 | #SC_FOLDLEVELHEADERFLAG)     ; Define a Linha de "Título" como Folded , Hierarquia = "99" !
  ;Else     
    ;Protected LinhaFim = ScintillaSendMessage(MyGadget,#SCI_LINEFROMPOSITION, SelEnd)   ; Define como hierarquia de folding "0" os outros formatos

    ;For Tamanho = LinhaInicio To LinhaFim           ;Reaproveitamento da variável Tamanho : Redefine a Hierarquia "0" de novo !
      ;ScintillaSendMessage(MyGadget,#SCI_SETFOLDLEVEL, Tamanho, #SC_FOLDLEVELBASE)
    ;Next Tamanho    
  ;EndIf
  
EndProcedure


  ; Contract Folds in Scintilla
Procedure ContractFoldsScintilla (MyGadget)
  
  Protected x = 0
  While x < ScintillaSendMessage(MyGadget, #SCI_GETLINECOUNT)
    If ScintillaSendMessage(MyGadget, #SCI_GETFOLDLEVEL, x) > #SC_FOLDLEVELBASE 
      ScintillaSendMessage(MyGadget, #SCI_FOLDLINE, x, #SC_FOLDACTION_CONTRACT)
    EndIf
    x +1
  Wend
  
EndProcedure



; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 1
; Folding = --
; EnableXP