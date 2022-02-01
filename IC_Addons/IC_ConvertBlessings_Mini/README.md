# ConvertBlessings_Mini
## Description:
Monitors IC for a forced conversion blessings window. If found, closes IC, sends convert favor server call, reopens IC if not open yet.

> **Note:** Currently only starts from BrivGemFarm.

#
## Instructions:
Instructions:
1. Place this addon's files in the ``IC_ConvertBlessings_Mini`` folder inside the script's AddOn folder.
2. Edit ``IC_ConvertBlessings_Mini_Component.ahk`` and find ``convertToBlessing := 1``. Change the 1 to the value of the favor/blessing you want your favor to be converted to.
  > **Note:** Valid Target Favors: 1 (Torm), 3 (Kalemvor), 15 (Helm), 22 (Tiamat), 23 (Auril), 25 (Corellon)
3. Start Script Hub
4. Enable this addon from the Script Hub Addon Manager.
5. Press the Start Gem Farm button in Briv Gem Farm.
6. This script runs hidden in the background. When it finds a forced conversion window it will close IC, send a convert favor server call, and reopen IC if it hasn't been already reopened by the gem farm script.
7. This addon will stop when the Stop Gem Farm button in is pressed in BrivGemFarm. Otherwise close the associated AutoHotkey.exe file in Task Manager.