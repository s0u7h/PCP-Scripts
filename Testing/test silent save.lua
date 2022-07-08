
  local path = "ReaClips"
  
  new_dir = savepath .. "/" .. path .. "/" .. filename 
  new_path = new_dir .. "/" .. filename .. ".RPP"
  
  reaper.Main_SaveProjectEx(proj, new_path, 0) --silently saves to Reaclips folder without copying audio files - still atlased to the original
   
  reaper.Main_OnCommand(41929, 0)  -- New project tab (ignore default template)
  reaper.Main_openProject("noprompt:" .. new_path)
