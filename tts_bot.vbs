' TF2 Chat to TTS & Soundboard Pipeline

' Customize your script behavior below by setting them to True or False:

Dim enableTTS, enableSoundboard, allowChatMemeTrigger
enableTTS = True             ' Set to False if you only want the soundboard.
enableSoundboard = True      ' Set to False if you only want the !tts feature.
allowChatMemeTrigger = True  ' Set to True to allow triggering sounds via chat (!meme word or the number).
' ==============================================================================

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set sapi = CreateObject("SAPI.SpVoice")

logPath = "C:\Program Files (x86)\Steam\steamapps\common\Team Fortress 2\tf\console.log"
soundsFolder = "D:\sounds" ' Folder where your .wav sound files live
cfgPath = "C:\Program Files (x86)\Steam\steamapps\common\Team Fortress 2\tf\cfg\effects.cfg"

' GENERATE EFFECTS.CFG ON STARTUP (If enabled)
If enableSoundboard And objFSO.FolderExists(soundsFolder) Then
    On Error Resume Next
    Set folder = objFSO.GetFolder(soundsFolder)
    Set fileStream = objFSO.CreateTextFile(cfgPath, True)

    fileStream.WriteLine "clear"
    fileStream.WriteLine "echo ""------------------------------------------"""
    fileStream.WriteLine "echo ""       SCANNED SOUNDBOARD MENU       """
    fileStream.WriteLine "echo ""------------------------------------------"""

    index = 1
    foundAny = False
    For Each file in folder.Files
        If LCase(objFSO.GetExtensionName(file.Name)) = "wav" Then
            displayName = Left(file.Name, Len(file.Name) - 4)
            fileStream.WriteLine "echo "" " & index & ". " & displayName & """"
            index = index + 1
            foundAny = True
        End If
    Next

    If Not foundAny Then
        fileStream.WriteLine "echo "" [!] Folder is empty or has no .wav files!"""
    End If

    fileStream.WriteLine "echo ""=========================================="""
    fileStream.Close
    On Error Goto 0
ElseIf enableSoundboard Then
    On Error Resume Next
    Set fileStream = objFSO.CreateTextFile(cfgPath, True)
    fileStream.WriteLine "clear"
    fileStream.WriteLine "echo ""=========================================="""
    fileStream.WriteLine "echo ""       AUTO-SCANNED SOUNDBOARD MENU       """
    fileStream.WriteLine "echo ""=========================================="""
    fileStream.WriteLine "echo "" [!] Folder not found: " & soundsFolder & """"
    fileStream.WriteLine "echo ""=========================================="""
    fileStream.Close
    On Error Goto 0
End If
' ---------------------------------------------------------

' --- AUDIO BASELINE CONFIGURATION ---
sapi.Volume = 100
sapi.Rate = 0

' Default to Male voice initially
On Error Resume Next
Set defaultVoices = sapi.GetVoices("Gender=Male")
If defaultVoices.Count > 0 Then
    Set sapi.Voice = defaultVoices.Item(0)
End If
On Error Goto 0
' -----------------------------------

' Wait for log file to exist
Do While Not objFSO.FileExists(logPath)
    WScript.Sleep 1000
Loop

' Open file and read lines dynamically
Do
    Set objFile = objFSO.GetFile(logPath)
    lastSize = objFile.Size

    Set objStream = objFSO.OpenTextFile(logPath, 1, False, -2)

    ' Skip current contents so it doesn't read old history
    Do While Not objStream.AtEndOfStream
        objStream.ReadLine
    Loop

    Do While objFSO.FileExists(logPath)
        Set objFile = objFSO.GetFile(logPath)
        If objFile.Size < lastSize Then
            Exit Do
        End If

        If Not objStream.AtEndOfStream Then
            line = objStream.ReadLine

            ' --- 1. TTS MODULE (Conditional) ---
            If enableTTS And InStr(line, "!tts") > 0 And InStr(line, "Say:") = 0 Then
                parts = Split(line, "!tts")
                If UBound(parts) >= 1 Then
                    ttsText = Trim(parts(1))

                    If Len(ttsText) > 0 Then
                        ' --- DYNAMIC VOICE SWITCHING (/m or /f) ---
                        On Error Resume Next
                        Dim targetVoiceToken

                        If Left(LCase(ttsText), 2) = "/m" Then
                            Set vList = sapi.GetVoices("Gender=Male")
                            If vList.Count > 0 Then Set sapi.Voice = vList.Item(0)
                            ttsText = Trim(Mid(ttsText, 3))
                        ElseIf Left(LCase(ttsText), 2) = "/f" Then
                            Set vList = sapi.GetVoices("Gender=Female")
                            If vList.Count > 0 Then Set sapi.Voice = vList.Item(0)
                            ttsText = Trim(Mid(ttsText, 3))
                        End If
                        On Error Goto 0
                        ' -----------------------------------------

                        If Len(ttsText) > 150 Then
                            ttsText = Left(ttsText, 150)
                        End If

                        If Len(ttsText) > 0 Then
                            ttsText = "<silence msec='150'/> " & ttsText
                            sapi.Speak ttsText, 1 + 2
                        End If
                    End If
                End If

            ' --- 2. CHAT MEME TRIGGER MODULE (Conditional via !meme) ---
            ElseIf enableSoundboard And allowChatMemeTrigger And InStr(line, "!meme") > 0 And InStr(line, "Say:") = 0 Then
                parts = Split(line, "!meme")
                If UBound(parts) >= 1 Then
                    typedInput = LCase(Trim(parts(1)))

                    If Len(typedInput) > 0 And objFSO.FolderExists(soundsFolder) Then
                        PlaySoundFile(typedInput)
                    End If
                End If

            ' --- 3. SOUNDBOARD & STOP MODULE (Conditional) ---
            ElseIf enableSoundboard And InStr(line, "Unknown command:") > 0 Then
                parts = Split(line, "Unknown command:")
                If UBound(parts) >= 1 Then
                    typedInput = LCase(Trim(parts(1)))

                    ' Emergency stop kill switch
                    If typedInput = "stopp" Then
                        sapi.Speak "", 2
                    ElseIf Len(typedInput) > 0 And objFSO.FolderExists(soundsFolder) Then
                        PlaySoundFile(typedInput)
                    End If
                End If
            End If

        Else
            WScript.Sleep 50
        End If
    Loop

    objStream.Close
    WScript.Sleep 1000
Loop

' --- REUSABLE SOUND PLAYBACK FUNCTION ---
Sub PlaySoundFile(targetInput)
    Set folder = objFSO.GetFolder(soundsFolder)
    currentIndex = 1

    For Each file in folder.Files
        If LCase(objFSO.GetExtensionName(file.Name)) = "wav" Then
            fileNameLower = LCase(file.Name)
            fileBaseNameLower = LCase(Left(file.Name, Len(file.Name) - 4))

            matchFound = False

            If IsNumeric(targetInput) Then
                If currentIndex = CLng(targetInput) Then matchFound = True
            Else
                If InStr(fileBaseNameLower, targetInput) > 0 Then matchFound = True
            End If

            If matchFound Then
                On Error Resume Next
                Dim fileStream
                Set fileStream = CreateObject("SAPI.SpFileStream")
                fileStream.Open file.Path, 0, False
                sapi.SpeakStream fileStream, 1
                On Error Goto 0
                Exit For
            End If

            currentIndex = currentIndex + 1
        End If
    Next
End Sub