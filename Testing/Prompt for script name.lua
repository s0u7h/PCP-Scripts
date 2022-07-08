  retval, savepath = reaper.get_config_var_string("defsavepath")
  if savepath == "" then
    error_exit("Cannot save file - no default save path")
  end
  
  filename = os.date("%Y-%m-%d-%H_%M_%S")
local rv, rv_str = reaper.GetUserInputs("Save ReaClip as..", 1, "ReaClip Name:", filename)
if rv==true then
filename = rv_str
  reaper.ShowMessageBox(filename, "Filename", 0)
  end
  
  new_dir = savepath .. "/" .. "ReaClips" .. "/" .. filename
   new_path = new_dir .. "/" .. filename .. ".RPP"
  
   if reaper.file_exists(new_path) then
     error_exit("File already exists: \n" .. new_path)
   end
   
   if reaper.RecursiveCreateDirectory(new_dir, 0) == 0 then
     error_exit("Unable to create dir: \n" .. new_dir)
   end
   
     reaper.Main_SaveProjectEx(proj, new_path, 0)
     reaper.Main_openProject("noprompt:" .. new_path)
   
