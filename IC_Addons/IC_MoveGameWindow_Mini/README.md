# MoveGameWindow_Mini
## Description:
Monitors IC for a the game being closed. Once it detects that it is open again the game window will be moved to the position defined in settings.

> **Note:** Currently only starts from BrivGemFarm.

#
## Instructions:
Instructions:
1. Place this addon's files in the ``IC_MoveGameWindow_Mini`` folder inside the script's AddOn folder.
2. Edit ``IC_MoveGameWindow_Mini_Component.ahk`` and find ``WinMove``. Edit it to the placement you want the game window to be. (See ahk WinMove docs)[https://www.autohotkey.com/docs/commands/WinMove.htm]
3. Start Script Hub
4. Enable this addon from the Script Hub Addon Manager.
5. Press the Start Gem Farm button in Briv Gem Farm.
6. This script runs hidden in the background. When it a new instance of IC it will move the game window to the desired location. Unexpected behavior could occur when running multiple instances of Idle Champions.
7. This addon will stop when the Stop Gem Farm button in is pressed in BrivGemFarm. Otherwise close the associated AutoHotkey.exe file in Task Manager.