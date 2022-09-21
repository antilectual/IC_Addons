# Imports and Pointers Help - FAQ

  - [What are "Pointers" in IC Script Hub?](#what-are-pointers-in-ic-script-hub)
  - [What are "Offsets"?](#what-are-offsets)
  - [What are "Imports" in IC Script Hub](#what-are-imports-in-ic-script-hub)
  - [How do I find "Pointers"?](#how-do-i-find-pointers)

## What are "Pointers" in IC Script Hub?  
  
 "Pointers" in IC Script Hub are memory address locations of the main memory structures that the script reads from to work. There are currently 5 memory structures that IC Script Hub requires pointers to for full functionality. They point to the locations the game stores the classes ``CrusadersGameDataSet``, ``DialogManager``, ``EngineSettings``, ``GameSettings``, and most importantly ``IdleGameManager``. "Pointers" occasionally change with updates, but rarely. 

## What are "Offsets"?

 "Offsets" are chains of values that combine with pointers to describe a memory locations, typically where field values are stored. In Script Hub, the Imports build these chains.

## What are "Imports" in IC Script Hub

 "Imports" in IC Script Hub are AHK Scripts that IC Script Hub uses to build upon the pointers to create structures that mirrors the memory structures used in the game. These structures change often with game updates. Due to the rapid changes, a system was created to nearly automatically build these Imports. See https://github.com/antilectual/ScriptHub-AutomaticOffsets for more information.

## How do I find "Pointers"?

 The process of finding pointers that work consistently is tedious and generally needs to be done by hand. IC Script Hub contains some PDF instructions that should help figure this process out (``Pointers.pdf`` and ``GameSettingsStaticInstructions.pdf``)