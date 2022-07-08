-- Save ReaClip (selected items)
-- v0.1 - PCP - 14 June, 2022

-- Requires SWS, JS_ReaScriptAPI and ReaPack (specifically with Yannick repo)
-- The script expects a database in the media explorer called "ReaClips". If you want to call this database something elee, just change the name below in the Edgemeal script (local path = "DB: xxxxx")

--USER SETTINGS -- 

local path = "DB: ReaClips"

--reaclips_dir = "ReaClips"

-- OPTIONAL: You can change this directory name and resave the script with the new name if you want  
-- to have different ReaClip directories, e.g. reaclips_dir = "Synth Presets" or "Beats".
-- The script will create this subdirectory under your Default Save Path (set in Prefs) if it doesn't exist.
-- You then need to create a database from that folder and save a new version of 
-- the action 'Script: Open Media Explorer to ReaClips database - search rpp - sort last modified (edgemeal).lua
-- Change the local DB in that script's settings to your new database name
-- instead of "DB: ReaClips", i.e. DB: Synth Presets, or DB: Beats

-- Alternatively, an easier way to organise is just to keep everything in the ReaClips folder and set a custom metadata field for your ReaClips, and classify them
-- as Synth Presets or Beats or Melodies or whatever

-- check if reaclips_dir exists, and if not, create it.

--  retval, savepath = reaper.get_config_var_string("defsavepath")

--reaclips_dir = savepath .. "/" .. reaclips_dir
--  if reaclips_dir == "" then
--    error_exit("Cannot save file - no ReaClips directory")
--  end


--  filename = os.date("%Y-%m-%d-%H_%M_%S")
  --new_dir = reaclips_dir .. "/" .. filename
 -- new_path = new_dir .. "/" .. filename .. ".RPP"
-- new_path = reaclips_dir .. "/" .. filename .. ".RPP"
  
--  if reaper.file_exists(new_path) then
--    error_exit("File already exists: \n" .. new_path)
--  end
  
  
 -- if reaper.RecursiveCreateDirectory(new_dir, 0) == 0 then
--    error_exit("Unable to create dir: \n" .. new_dir)
--  end
  
  

reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAVESEL'), 0) -- SWS: Save current track selection'), 0)

reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SELTRKWITEM'), 0) -- SWS: Select only track(s) with selected item(s)

reaper.Main_OnCommand(reaper.NamedCommandLookup('_S&M_COPYSNDRCV1'), 0) -- SWS/S&M: Copy selected tracks (with routing)

reaper.Main_OnCommand(40210, 0) -- Track: Copy tracks
reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS5f85e6b658cc44cdd5d05bef93d39ee908ccb998'), 0) -- Script: Yannick_Save (copy) all tempo markers from the project.lua
reaper.Main_OnCommand(41929, 0) -- New project tab (ignore default template)
reaper.Main_OnCommand(reaper.NamedCommandLookup('_RSd857f551824b63f45518b8714f5417a548fbfa7e'), 0) -- Script: Yannick_Restore (paste) tempo markers to the project by replacing the old ones.lua
reaper.Main_OnCommand(42398, 0) -- Item: Paste items/tracks
reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAFETIMESEL'), 0) -- SWS: Set time selection to selected items (skip if time selection exists)
reaper.Main_OnCommand(40049, 0) -- Time selection: Crop project to time selection

-- auto-save it to the reaclips folder using paat's code: (is there still 
-- no way to set an option to save media with the file and set save path with Main_SaveProjectEx though?)

--reaper.Main_SaveProjectEx(proj, new_path, 0)
--reaper.Main_openProject("noprompt:" .. new_path)
reaper.Main_SaveProject(0, true)
-- and then save a proxy file so it'll be previewable in the MX (is there a way to call this from script instead of resaving via the action?
reaper.Main_OnCommand(42332, 0) -- File: Save project and render RPP-PROX
reaper.Main_OnCommand(40860, 0) --Close current project tab

reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_RESTORESEL'), 0) --SWS: Restore saved track selection


