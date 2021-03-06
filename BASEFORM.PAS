
{浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
 �                                                                          �
 �     Sibyl Visual Development Environment                                 �
 �                                                                          �
 �     Copyright (C) 1995,99 SpeedSoft Germany,   All rights reserved.      �
 �                                                                          �
 藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕}

{浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
 �                                                                          �
 � Sibyl Integrated Development Environment (IDE)                           �
 � Object-oriented development system.                                      �
 �                                                                          �
 � Copyright (C) 1995,99 SpeedSoft GbR, Germany                             �
 �                                                                          �
 � This program is free software; you can redistribute it and/or modify it  �
 � under the terms of the GNU General Public License (GPL) as published by  �
 � the Free Software Foundation; either version 2 of the License, or (at    �
 � your option) any later version. This program is distributed in the hope  �
 � that it will be useful, but WITHOUT ANY WARRANTY; without even the       �
 � implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR          �
 � PURPOSE.                                                                 �
 � See the GNU General Public License for more details. You should have     �
 � received a copy of the GNU General Public License along with this        �
 � program; if not, write to the Free Software Foundation, Inc., 59 Temple  �
 � Place - Suite 330, Boston, MA 02111-1307, USA.                           �
 �                                                                          �
 � In summary the original copyright holders (SpeedSoft) grant you the      �
 � right to:                                                                �
 �                                                                          �
 � - Freely modify and publish the sources provided that your modification  �
 �   is entirely free and you also make the modified source code available  �
 �   to all for free (except a fee for disk/CD production etc).             �
 �                                                                          �
 � - Adapt the sources to other platforms and make the result available     �
 �   for free.                                                              �
 �                                                                          �
 � Under this licence you are not allowed to:                               �
 �                                                                          �
 � - Create a commercial product on whatever platform that is based on the  �
 �   whole or parts of the sources covered by the license agreement. The    �
 �   entire program or development environment must also be published       �
 �   under the GNU General Public License as entirely free.                 �
 �                                                                          �
 � - Remove any of the copyright comments in the source files.              �
 �                                                                          �
 � - Disclosure any content of the source files or use parts of the source  �
 �   files to create commercial products. You always must make available    �
 �   all source files whether modified or not.                              �
 �                                                                          �
 藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕}

UNIT BaseForm;

INTERFACE

USES Messages,Classes,Forms,Consts,Projects,Sib_Prj;


TYPE
    TSibylForm=CLASS(TForm)
      PROTECTED
         PROCEDURE CreateWnd;OVERRIDE;
         PROCEDURE SetupShow;OVERRIDE;
         PROCEDURE DestroyWnd;OVERRIDE;
         PROCEDURE Move;OVERRIDE;
         PROCEDURE Resize;OVERRIDE;
         PROCEDURE Activate;OVERRIDE;
      PUBLIC
         SibylFormId:TDesktopWinId;
         PROCEDURE Show;OVERRIDE;
         PROCEDURE StoreDesktopWindowPos;
         PROCEDURE ScanEvent(VAR Keycode:TKeyCode;RepeatCount:BYTE);OVERRIDE;
     END;


PROCEDURE HideSibylForms;
PROCEDURE ShowSibylForms;

VAR
    AddWindowListProc:PROCEDURE(LB:INTEGER;Win:TForm);
    RemoveWindowListProc:PROCEDURE(LB:INTEGER;Win:TForm);
    LastFocusedForm:TForm;


IMPLEMENTATION

PROCEDURE TSibylForm.CreateWnd;
BEGIN
     WITH IdeSettings.DesktopWindows[SibylFormId] DO SetWindowPos(X,Y,CX,CY);
     {nicht erst in SetupShow, da dort die Koordinaten ignoriert werden ???}

     Inherited CreateWnd;

     IF SELF <> Application.MainForm
     THEN OnRestore := Application.MainForm.OnRestore;
END;


PROCEDURE TSibylForm.SetupShow;
BEGIN
     IF not IdeSettings.DesktopWindows[SibylFormId].Visible
     THEN IdeSettings.Modified := TRUE;
     IdeSettings.DesktopWindows[SibylFormId].Form := SELF;
     IdeSettings.DesktopWindows[SibylFormId].Visible := TRUE;

     Inherited SetupShow;
     AddWindowListProc(3,SELF);
END;


PROCEDURE TSibylForm.DestroyWnd;
BEGIN
     IF LastFocusedForm = SELF THEN LastFocusedForm := NIL;
     IdeSettings.DesktopWindows[SibylFormId].Form := NIL;
     IF not Project.Closing THEN
     BEGIN
          IdeSettings.DesktopWindows[SibylFormId].Visible := FALSE;
          IdeSettings.Modified := TRUE;
     END;
     RemoveWindowListProc(3,SELF);

     Inherited DestroyWnd;
END;


PROCEDURE TSibylForm.Move;
BEGIN
     Inherited Move;

     StoreDesktopWindowPos;
END;


PROCEDURE TSibylForm.Resize;
BEGIN
     Inherited Resize;

     StoreDesktopWindowPos;
END;


PROCEDURE TSibylForm.StoreDesktopWindowPos;
BEGIN
     IF Project.Loading THEN exit;
     IF not Visible THEN exit;

     IF WindowState = wsNormal THEN
     BEGIN
          IF (IdeSettings.DesktopWindows[SibylFormId].X <> Left) OR
             (IdeSettings.DesktopWindows[SibylFormId].Y <> Bottom) OR
             (IdeSettings.DesktopWindows[SibylFormId].CX <> Width) OR
             (IdeSettings.DesktopWindows[SibylFormId].CY <> Height)
          THEN IdeSettings.Modified := TRUE;

          IdeSettings.DesktopWindows[SibylFormId].X := Left;
          IdeSettings.DesktopWindows[SibylFormId].Y := Bottom;
          IdeSettings.DesktopWindows[SibylFormId].CX := Width;
          IdeSettings.DesktopWindows[SibylFormId].CY := Height;
     END;
END;


PROCEDURE TSibylForm.ScanEvent(VAR Keycode:TKeyCode;RepeatCount:BYTE);
BEGIN
     Inherited ScanEvent(KeyCode,RepeatCount);

     IF KeyCode <> kbNull THEN
       IF SELF <> Application.MainForm
       THEN Application.MainForm.ScanEvent(KeyCode,RepeatCount);
     KeyCode := kbNull;
END;


PROCEDURE TSibylForm.Activate;
BEGIN
     Inherited Activate;

     IF SELF <> Application.MainForm THEN LastFocusedForm := SELF;
END;


PROCEDURE TSibylForm.Show;
VAR  p:POINTER;
BEGIN
(* Compiler Fehler
     Project.Settings.DesktopWindows[SibylFormId].Form := SELF;
*)
     p := SELF;
     IdeSettings.DesktopWindows[SibylFormId].Form := p;

     Inherited Show;
END;

////////////////////////////////////////////////////////////////////////////

PROCEDURE HideSibylForms;
VAR  i:LONGINT;
     dwi:TDesktopWinId;
     Form:TSibylForm;
     FormItem:PFormListItem;
BEGIN
     FOR dwi := dwi_MainWindow TO dwi_LastForm DO
     BEGIN
          IF dwi = dwi_MainWindow THEN continue;
          IF dwi = dwi_CodeEditor THEN continue;
          IF dwi = dwi_CPUWindow THEN continue;
          Form := IdeSettings.DesktopWindows[dwi].Form;
          IF Form IS TSibylForm THEN Form.Hide;
     END;

     FOR i := 0 TO Project.Forms.Count-1 DO
     BEGIN
          FormItem := Project.Forms.Items[i];
          Form := TSibylForm(FormItem^.Form);
          IF Form <> NIL THEN Form.Hide;
     END;
END;


PROCEDURE ShowSibylForms;
VAR  i:LONGINT;
     dwi:TDesktopWinId;
     Form:TSibylForm;
     FormItem:PFormListItem;
BEGIN
     FOR dwi := dwi_MainWindow TO dwi_LastForm DO
     BEGIN
          Form := IdeSettings.DesktopWindows[dwi].Form;
          IF Form IS TSibylForm THEN Form.Show;
     END;

     FOR i := 0 TO Project.Forms.Count-1 DO
     BEGIN
          FormItem := Project.Forms.Items[i];
          Form := TSibylForm(FormItem^.Form);
          IF Form <> NIL THEN Form.Show;
     END;

     IF CodeEditorRef.ActiveMDIChild = NIL THEN CodeEditorRef.Focus
     ELSE CodeEditorRef.ActiveMDIChild.Focus;
END;


BEGIN
     LastFocusedForm := NIL;
     ShowSibylFormsProc := ShowSibylForms;
END.
