-- Insert ReaClip  at start (load and explode project on new tracks in current project)
-- v 1.00, PCP, 14 June 2022
-- Project / Clip should be selected in the Media Explorer before activating this script. 
-- Requires SWS, JS_ReaScriptAPI and ReaPack with the me2beats repo installed: https://github.com/me2beats/reapack/raw/master/index.xml

reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS1ad9b3e745ad836bebeee40ba9e7a5279a356ea8'), 0) -- Script: me2beats_Save active project tab, slot 1.lua

reaper.Main_OnCommand(40289, 0) -- unselect all items

me = reaper.JS_Window_Find("Media Explorer", true)
reaper.JS_WindowMessage_Send(me, "WM_COMMAND", 41001, 0, 0, 0) -- insert media on new track

reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
--reaper.Main_OnCommand(42088, 0) -- Envelope: Delete automation items, preserve points
reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAVESEL'), 0) --SWS: Save current track selection
reaper.Main_OnCommand(41816, 0) -- Item: Open associated project in new tab
reaper.Main_OnCommand(40296, 0) -- Track: Select all tracks
reaper.Main_OnCommand(40210, 0) --Track: Copy tracks
--reaper.Main_OnCommand(reaper.NamedCommandLookup('40026'), 0) --File: Save project
reaper.Main_OnCommand(40860, 0) --Close current project tab
reaper.Main_OnCommand(reaper.NamedCommandLookup('_RSc4b08953457ee0ea58cc55d5ccce70175d05f0c5'), 0) -- Script: me2beats_Restore saved project tab, slot 1.lua
reaper.Main_OnCommand(42398, 0) -- Item: Paste items/tracks
reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_RESTORESEL'), 0) --SWS: Restore saved track selection
reaper.Main_OnCommand(40005, 0) --Track: Remove tracks
