# TF2 Chat to TTS & Soundboard Pipeline

A VBScript for Team Fortress 2 that adds native Text-to-Speech (`!tts`) and a soundboard using the game's console or chat logs.
This is not including how to play music though your mic (check out 'vb cable' for transferring sounds to TF2 mic.)

**Steam Profile:** [https://steamcommunity.com/id/admirable_but_mistaken/](http://steamcommunity.com/profiles/76561198980644010)

## Features

- Auto-scans `.wav` files and generates `effects.cfg`
- Play sounds by number or filename
- Windows SAPI Text-to-Speech.
- Male (`/m`) and Female (`/f`) voice. For Example: In TF2 chat !tts /m hi guys
- Optional `!meme` chat commands.
- `stopp` command in console to stop audio.
- Enable or disable features with simple settings.
- Adjust volume for tts and memes in the TF2 chat with /vol for example !tts /vol 60 or !memes /vol 49

## Installation

1. Download tts_bot.vbs.
2. Place `tts_bot.vbs` anywhere on your computer.
3. Create a folder for your `.wav` files.
4. Edit `tts_bot.vbs` and set:
   - `logPath` to your `console.log`
   - `soundsFolder` to your sound folder
5. Launch TF2 with:

```text
-condebug
```

## Configuration

```vbscript
enableTTS = True
enableSoundboard = True
allowChatMemeTrigger = True
```

## Usage

Start the script by running:

```text
tts_bot.vbs
```

Load the sound menu:

```text
exec effects
```

Commands:

```text
!tts Hello world
!tts /f Hello world
!tts /m Hello world
!tts /vol 50
!memes /vol 49

!meme airhorn
!meme 5

stopp
```

## Requirements

- Windows
- Team Fortress 2
- Developer Console enabled
- `-condebug` launch option

## Uninstall

- Close the running VBScript.
- Delete `tts_bot.vbs`.
- Delete your sound folder.
- (Optional) Delete `tf/cfg/effects.cfg`.

## Current Bugs
- Low volume cut off; When triggering audio clips (memes/soundboard items) through the VBScript, sounds cut off prematurely, can be caused by TF2 mic not detecting low sound to play it so it becomes quiet in voice chat.

## License

Feel free to modify and share this project.
