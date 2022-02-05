; FROM Example - General.ahk in Edit Library (from jballi)

EEGUI_Init:

$EEGUI:=2

;-- FindReplace flags
FR_DOWN          :=0x1
FR_WHOLEWORD     :=0x2
FR_MATCHCASE     :=0x4
FR_SHOWHELP      :=0x80
FR_NOUPDOWN      :=0x400
FR_NOMATCHCASE   :=0x800
FR_NOWHOLEWORD   :=0x1000
FR_HIDEUPDOWN    :=0x4000
FR_HIDEMATCHCASE :=0x8000
FR_HIDEWHOLEWORD :=0x10000
FR_REGEX         :=0x100000  ;-- FindGUI2 flag
FR_NOREGEX       :=0x200000  ;-- FindGUI2 flag
FR_HIDEREGEX     :=0x400000  ;-- FindGUI2 flag


EEGUI_Find:
gui %$EEGUI%:Default

;-- Bounce if Find or Replace dialog is already showing
IfWinExist ahk_id %hFRDialog%
    return

;-- Where are we starting from?
Edit_GetSel(hEdit,Dummy,$EndSelectPos)
Dlg_FindFromTheTop :=($EndSelectPos=0) ? True:False

;-- Set Dlg_Flags
Dlg_Flags :=FR_DOWN

;-- Anything selected?
$Selected:=Edit_GetSelText(hEdit)
if StrLen($Selected)
    {
    ;-- Ignore if multiple lines are selected
    if not InStr($Selected,"`n")
        Dlg_FindWhat:=$Selected
    }

;-- Show the Find dialog
hFRDialog :=Dlg_FindText(hEEGUI,Dlg_Flags|FR_HIDEWHOLEWORD,Dlg_FindWhat,"EEGUI_OnFind")
return


EEGUI_FindNext:
gui %$EEGUI%:Default

;-- Bounce if Find or Replace dialog is showing
IfWinExist ahk_id %hFRDialog%
    return

;-- Bounce if Find was never called (EDIT JL: call Find instead)
if not StrLen(Dlg_FindWhat)
{
	Gosub, EEGUI_Find
	return
}

;-- Save Dlg_Flags
$Saved_Dlg_Flags:=Dlg_Flags

;-- Update Dlg_Flags
Dlg_Flags|=FR_DOWN

;-- Find next
EEGUI_OnFind(0,"F",Dlg_Flags,Dlg_FindWhat)

;-- Restore Dlg_Flags
Dlg_Flags :=$Saved_Dlg_Flags
return


EEGUI_FindPrevious:
gui %$EEGUI%:Default

;-- Bounce if Find was never called
if not StrLen(Dlg_FindWhat)
	return

;-- Save Dlg_Flags
$Saved_Dlg_Flags:=Dlg_Flags

;-- Update Dlg_Flags
Dlg_Flags&=~FR_DOWN

;-- Find previous
EEGUI_OnFind(0,"F",Dlg_Flags,Dlg_FindWhat)

;-- Restore Dlg_Flags
Dlg_Flags :=$Saved_Dlg_Flags
return



;*****************
;*               *
;*     OnFind    *
;*    (EEGUI)    *
;*               *
;*****************
EEGUI_OnFind(hDialog,p_Event,p_Flags,p_FindWhat,Dummy="")
    {
    Global $EEGUI
          ,Dlg_Flags
          ,Dlg_FindWhat
          ,Dlg_FindFromTheTop
          ,hEEGUI
          ,hEdit

    Static Dummy2117

          ;-- FindReplace flags
          ,FR_DOWN         :=0x1
          ,FR_WHOLEWORD    :=0x2
          ,FR_MATCHCASE    :=0x4
          ,FR_SHOWHELP     :=0x80
          ,FR_NOUPDOWN     :=0x400
          ,FR_NOMATCHCASE  :=0x800
          ,FR_NOWHOLEWORD  :=0x1000
          ,FR_HIDEUPDOWN   :=0x4000
          ,FR_HIDEMATCHCASE:=0x8000
          ,FR_HIDEWHOLEWORD:=0x10000
          ,FR_REGEX        :=0x100000   ;-- FindGUI2 flag
          ,FR_NOREGEX      :=0x200000   ;-- FindGUI2 flag
          ,FR_HIDEREGEX    :=0x400000   ;-- FindGUI2 flag

          ;-- Message Box return values
          ,IDOK    :=1
          ,IDCANCEL:=2

    ;[===================]
    ;[  Set GUI default  ]
    ;[===================]
    gui %$EEGUI%:Default  ;-- Required to support independent threads

    ;[==========]
    ;[  Close?  ]
    ;[==========]
    if (p_Event="C")
        return

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    ;-- If needed, set hDialog to the master window
    IfWinNotExist ahk_id %hDialog%  ;-- Dialog not showing
        hDialog:=hEEGUI

    ;-- Update globals
    Dlg_Flags   :=p_Flags
    Dlg_FindWhat:=p_FindWhat
        ;-- These global variables are used by Find, FindNext, FindPrevious, and
        ;   Replace routines.

    ;-- Convert Dlg_Find flags to Edit_FindText flags
    l_Flags:=""
    if p_Flags & FR_MATCHCASE
        l_Flags.="MatchCase "

    if p_Flags & FR_REGEX
        l_Flags.="RegEx "

    ;[===========]
    ;[  Find it  ]
    ;[===========]
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)

    ;-- Which direction?
    if p_Flags & FR_DOWN
        l_FindPos:=Edit_FindText(hEdit,p_FindWhat,l_EndSelPos,-1,l_Flags,l_RegExOut)
     else
        l_FindPos:=Edit_FindText(hEdit,p_FindWhat,l_StartSelPos,0,l_Flags,l_RegExOut)

    ;-- Find anything?
    if (l_FindPos>-1)
        {
        ;-- Select and scroll to it
        if StrLen(l_RegExOut)
            Edit_SetSel(hEdit,l_FindPos,l_FindPos+StrLen(l_RegExOut))
         else
            Edit_SetSel(hEdit,l_FindPos,l_FindPos+StrLen(p_FindWhat))

        ;-- Make sure caret is showing
        Edit_ScrollCaret(hEdit)

        ;-- First selected line showing?
        Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)
        l_FirstSelectedLine:=Edit_LineFromChar(hEdit,l_StartSelPos)
        l_FirstVisibleLine :=Edit_GetFirstVisibleLine(hEdit)
        if (l_FirstVisibleLine>l_FirstSelectedLine)
            Edit_LineScroll(hEdit,0,(l_FirstVisibleLine-l_FirstSelectedLine)*-1)
        }
     else
        {
        ;-- Notify/Prompt the user
        $Message=Next occurrence of "%p_FindWhat%" not found.
        if (Dlg_FindFromTheTop or not (p_Flags & FR_DOWN))
            {
            Dlg_MessageBox(hDialog
                ,0x40   ;-- 0x0 (OK button) + 0x40 (Info icon)
                ,"Find"
                ,$Message)

            Dlg_FindFromTheTop:=False
            return
            }

        RC:=Dlg_MessageBox(hDialog
            ,0x21   ;-- 0x1 (OK/Cancel buttons) + 0x20 ("?" icon)
            ,"Find"
            ,$Message . "`nContinue search from the top?")

        if (RC=IDCANCEL)
            {
            Dlg_FindFromTheTop:=False
            return
            }

        ;[===================]
        ;[  Start searching  ]
        ;[    from the top   ]
        ;[===================]
        Dlg_FindFromTheTop:=True
        Edit_SetSel(hEdit,0,0)   ;-- Move caret to the top
        EEGUI_OnFind(hDialog,"F",p_Flags,p_FindWhat)
            ;-- Recursive call
        }

    ;-- Return to sender
    return
    }


;*******************
;*                 *
;*    OnReplace    *
;*     (EEGUI)     *
;*                 *
;*******************
EEGUI_OnReplace(hDialog,p_Event,p_Flags,p_FindWhat,p_ReplaceWith)
    {
    Global Dlg_Flags
          ,Dlg_FindWhat
          ,Dlg_ReplaceWith
          ,Dlg_FindFromTheTop
          ,hEdit

    Static Dummy6011

          ;-- FindReplace flags
          ,FR_DOWN         :=0x1
          ,FR_WHOLEWORD    :=0x2
          ,FR_MATCHCASE    :=0x4
          ,FR_SHOWHELP     :=0x80
          ,FR_NOUPDOWN     :=0x400
          ,FR_NOMATCHCASE  :=0x800
          ,FR_NOWHOLEWORD  :=0x1000
          ,FR_HIDEUPDOWN   :=0x4000
          ,FR_HIDEMATCHCASE:=0x8000
          ,FR_HIDEWHOLEWORD:=0x10000
          ,FR_REGEX        :=0x100000   ;-- FindGUI2 flag
          ,FR_NOREGEX      :=0x200000   ;-- FindGUI2 flag
          ,FR_HIDEREGEX    :=0x400000   ;-- FindGUI2 flag

          ;-- Message Box return values
          ,IDOK    :=1
          ,IDCANCEL:=2

    ;[==========]
    ;[  Close?  ]
    ;[==========]
    if (p_Event="C")
        return

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    ;-- Update globals
    Dlg_Flags      :=p_Flags
    Dlg_FindWhat   :=p_FindWhat
    Dlg_ReplaceWith:=p_ReplaceWith
        ;-- These global variables are used by Find, FindNext, FindPrevious, and
        ;   Replace routines.

    ;-- Convert Dlg_Find flags to Edit_FindText flags
    l_Flags:=""
    if p_Flags & FR_MATCHCASE
        l_Flags.="MatchCase "

    if p_Flags & FR_REGEX
        l_Flags.="RegEx "

    ;-- Get select positions
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)

    ;[=========]
    ;[  Find   ]
    ;[=========]
    if (p_Event="F")
        {
        ;-- Look for it
        l_FindPos:=Edit_FindText(hEdit,p_FindWhat,l_EndSelPos,-1,l_Flags)

        ;-- Anything found?
        if (l_FindPos>-1)
            {
            ;-- Select and scroll to it
            Edit_SetSel(hEdit,l_FindPos,l_FindPos+StrLen(p_FindWhat))
            Edit_ScrollCaret(hEdit)
            }
         else
            {
            ;-- Notify/Prompt the user
            $Message="%p_FindWhat%" not found.
            if Dlg_FindFromTheTop
                {
                Dlg_MessageBox(hDialog
                    ,0x40   ;-- 0x0 (OK button) + 0x40 (Info icon)
                    ,"Find"
                    ,$Message)

                Dlg_FindFromTheTop:=False
                return
                }

            RC:=Dlg_MessageBox(hDialog
                ,0x21   ;-- 0x1 (OK/Cancel buttons) + 0x20 ("?" icon)
                ,"Find"
                ,$Message . "`nContinue search from the top?")

            if (RC=IDCANCEL)
                {
                Dlg_FindFromTheTop:=False
                return
                }

            ;[===================]
            ;[  Start searching  ]
            ;[    from the top   ]
            ;[===================]
            Dlg_FindFromTheTop:=True
            Edit_SetSel(hEdit,0,0)  ;-- Move caret to the top
            EEGUI_OnReplace(hDialog,"F",p_Flags,p_FindWhat,p_ReplaceWith)
                ;-- Recursive call
            }
        }

    ;[===========]
    ;[  Replace  ]
    ;[===========]
    if (p_Event="R")
        {
        ;-- Anything selected and if so, is it the same length of p_FindWhat?
         if (l_StartSelPos<>l_EndSelPos)
        and StrLen(p_FindWhat)=l_EndSelPos-l_StartSelPos
            {
            ;-- Look for it within the selected area
            l_FindPos:=Edit_FindText(hEdit,p_FindWhat,l_StartSelPos,l_EndSelPos,l_Flags)
                ;-- Programming note: The Edit_FindText function is called here
                ;   instead of just doing a plain "If selected=p_FindWhat"
                ;   test because the function takes the search flags into
                ;   consideration.


            ;-- If found, replace with p_ReplaceWith
            if (l_FindPos=l_StartSelPos)
                Edit_ReplaceSel(hEdit,p_ReplaceWith)
            }

        ;-- Find next
        EEGUI_OnReplace(hDialog,"F",p_Flags,p_FindWhat,p_ReplaceWith)
            ;-- Recursive call
        }

    ;[================]
    ;[  Replace All   ]
    ;[================]
    if (p_Event="A")
        {
        ;-- Disable dialog
        WinSet Disable,,ahk_id %hDialog%

        ;-- Position caret
         if (l_StartSelPos<>l_EndSelPos)
            if (StrLen(p_FindWhat)=l_EndSelPos-l_StartSelPos)
                Edit_SetSel(hEdit,l_StartSelPos,l_StartSelPos)
             else
                Edit_SetSel(hEdit,l_EndSelPos+1,l_EndSelPos+1)

        ;-- Replace All
        l_ReplaceCount:=0
        Loop
            {
            ;-- Get select positions
            Edit_GetSel(hEdit,Dummy,l_EndSelPos)

            ;-- Look for next
            l_FoundPos:=Edit_FindText(hEdit,p_FindWhat,l_EndSelPos,-1,l_Flags)

            ;-- Are we done?
            if (l_FoundPos<0)
                Break

            ;-- Select and scroll to it
            Edit_SetSel(hEdit,l_FoundPos,l_FoundPos+StrLen(p_FindWhat))
            Edit_ScrollCaret(hEdit)

            ;-- Replace with p_ReplaceWith
            Edit_ReplaceSel(hEdit,p_ReplaceWith)

            ;-- Count it
            l_ReplaceCount++
            }

        ;-- Enable dialog and return focus
        WinSet Enable,,ahk_id %hDialog%
        WinActivate ahk_id %hDialog%

        ;-- Display message
        if (l_ReplaceCount=0)
            $Message="%p_FindWhat%" not found.
         else
            $Message="%p_FindWhat%" replaced %l_ReplaceCount% times.

        Dlg_MessageBox(hDialog
            ,0x40   ;-- 0x0 (OK button) + 0x40 (Info icon)
            ,"Replace All"
            ,$Message)
        }

    ;-- Return to sender
    return
    }


EEGUI_Replace:
gui %$EEGUI%:Default

;-- Bounce if Find or Replace dialog is already showing
IfWinExist ahk_id %hFRDialog%
    return

;-- Where are we starting from?
Edit_GetSel(hEdit,Dummy,$EndSelectPos)
Dlg_FindFromTheTop :=($EndSelectPos=0) ? True:False

;-- Anything selected?
$Selected:=Edit_GetSelText(hEdit)
if StrLen($Selected)
    {
    ;-- Ignore if multiple lines are selected
    if not InStr($Selected,"`n")
        Dlg_FindWhat:=$Selected
    }

;-- Set Dlg_Flags
Dlg_Flags:=FR_DOWN

;-- Show Replace dialog
hFRDialog :=Dlg_ReplaceText(hEEGUI,Dlg_Flags|FR_HIDEWHOLEWORD,Dlg_FindWhat,Dlg_ReplaceWith,"EEGUI_OnReplace")
return


