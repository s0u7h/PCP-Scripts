-- Save ReaClip (selected items) and open Clips Library in Media Explorer
-- v0.1 - PCP - 14 June, 2022

-- Requires SWS, JS_ReaScriptAPI and ReaPack (specifically with Yannick repo)
-- The script expects a database in the media explorer called "Clips". If you want to call this database something elee, just change the name below in the Edgemeal script (local path = "DB: xxxxx")

--USER SETTINGS -- 

local path = "DB: ReaClips"

reaclips_dir = "ReaClips"

------------------



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
  
  
  
  
  
  
-- v2 copies entire project with 'save as' so you set the location of the ReaClip initially, then it processes the new project destructively and then auto-saves it.
--  hopefully you can then bring in a ReaClip inserted as a subproject and maintain any ARA changes made to the items
-- and hopefully this saves the tempo envelope of the original project with the ReaClip. Let's test.





function SaveReaclipAndOpenMX()
  project_dirty = reaper.IsProjectDirty(proj)
  if project_dirty == 1 then 
    SaveCurrentProject()
  end
  SaveReaclip()
  reaper.defer(open_mx_to_reaclips_db())
end



function error_exit(message)
  reaper.ShowMessageBox(message, "Error", 0)
  os.exit()
end

function retry_save()
  reaper.ShowMessageBox("ReaClip exists, try another file name", "File Exists", 0)
end

function cancel()
  reaper.ShowMessageBox("Cancelled", "Save Cancelled", 0)
  os.exit()
end



function SaveCurrentProject()
  project_name = reaper.GetProjectName(0)
  -- show ok/cancel dialog
  local ok = reaper.ShowMessageBox("Save current project first", project_name, 1)
  if not ok then -- user pressed cancel in dialog
    cancel() 
  end
  if ok==1 then
    reaper.Main_OnCommand(40026, 0) --File: Save project // saves original project
  end
end


function SaveReaclip()
-- this code adapted from paat's auto-save script, adding a user prompt and a default ReaClips subdirectory
  retval, savepath = reaper.get_config_var_string("defsavepath")
  if savepath == "" then
    error_exit("Cannot save file - no default save path")
  end
  
  filename = os.date("%Y-%m-%d-%H_%M_%S")
  local rv, rv_str = reaper.GetUserInputs("Save ReaClip as..", 1, "ReaClip Name: ,extrawidth=250", filename)
  if rv==true then
    filename = rv_str
    --reaper.ShowMessageBox(filename, "ReaClip Name", 0)
  end
  if not rv then
    cancel()
  end
  
  new_dir = savepath .. "/" .. reaclips_dir .. "/" .. filename
  new_path = new_dir .. "/" .. filename .. ".RPP"
  
 -- if reaper.file_exists(new_path) then
 --   error_exit("File already exists: \n" .. new_path)
 -- end
  if reaper.file_exists(new_path) then
   retry_save("ReaClip already exists: \n" .. new_path)
   return
  end
   
  if reaper.RecursiveCreateDirectory(new_dir, 0) == 0 then
    error_exit("Unable to create dir: \n" .. new_dir)
  end
   
   
   --open a new project tab and open this same project in it. slot 1 will be our OG project. slot 2 is where we'll resave a cropped version of the OG project as a ReaClip.
 reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS1ad9b3e745ad836bebeee40ba9e7a5279a356ea8'), 0)  -- Script: me2beats_Save active project tab, slot 1.lua
   
   
  
  
  reaper.Main_OnCommand(41929, 0)  -- New project tab (ignore default template)
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_OPENLASTPROJ'), 0)-- SWS Open last project i.e. the current project in a new tab
  
  reaper.Main_SaveProjectEx(proj, new_path, 0) --saves to Reaclips folder without copying audio files - still atlased to the original
  reaper.Main_openProject("noprompt:" .. new_path)
  -- this section crops to the selected items and gets rid of any tracks that don't directly affect those items.
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SELTRKWITEM'), 0) -- SWS: Select only track(s) with selected item(s)
  -- reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAFETIMESEL'), 0) -- SWS: Set time selection to selected items (skip if time selection exists)
  reaper.Main_OnCommand(40290, 0)-- Time selection: Set time selection to items
  reaper.Main_OnCommand(40049, 0) -- Time selection: Crop project to time selection
  --reaper.Main_OnCommand(40289, 0) --Item: Unselect (clear selection of) all items
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_BR_FOCUS_TRACKS'), 0) --SWS/BR: Focus tracks
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SELROUTED'), 0) -- SWS: Select tracks with active routing to selected track(s)  
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS07454ab62d927454fdbf507028b3e5299d3619dd'), 0) -- Script: cfillion_Select source tracks of selected tracks receives recursively.lua
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_TOGTRACKSEL'), 0) --SWS: Toggle (invert) track selection
  reaper.Main_OnCommand(40184, 0) -- Remove items/tracks/envelope points (depending on focus) - no prompting
  
  
  -- auto-save it to the reaclips folder using paat's code: (is there still a
  -- no way to set an option to save media with the file and set save path with Main_SaveProjectEx though?)


  reaper.Main_SaveProject(0, true) -- *now* the project is saved with any remaining source media.  the boolean true forces a 'save as', and user must check that 'copy media' is selected (should be default) as there's no way in REAPER to specify saving copies of source audio. the boolean true forces a 'save as'
  reaper.Main_OnCommand(42332, 0) -- File: Save project and render RPP-PROX - shouldn't prompt after last save. this will generate the preview in MX
 
  
  --reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS69cbf39bd7571feb0b5978e5f38f07ea2a0459de'), 0)  --Script: me2beats_Save active project tab, slot 2.lua
  reaper.Main_OnCommand(40860, 0)  --Close current project tab
  --reaper.Main_OnCommand(reaper.NamedCommandLookup('_RSced651a54431a1e3234ed932b2aea90f24ab999f'), 0)  -- Script: me2beats_Restore saved project tab, slot 2.lua
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_RSc4b08953457ee0ea58cc55d5ccce70175d05f0c5'), 0)  -- Script: me2beats_Restore saved project tab, slot 1.lua
end


function open_mx_to_reaclips_db()
  --Open Media Explorer to Clips database - search rpp - sort last modified (edgemeal)
  
  
  -- Show Media Explorer, set path, search and sort last modified
  -- v1.03 - Edgemeal - Mar 22, 2021
  -- Donate: https://www.paypal.me/Edgemeal
  --
  -- Tested: Win10/x64, REAPER v6.51+dev0318/x64, js_ReaScriptAPI v1.301
  -- v1.03... Wait time set in seconds, added delay before scrolling to top.
  -- v1.02.1. Scroll list to top after sort.
  -- v1.02... Make filelist global, unselect files in list before sorting.
  
  
  
  -- USER SETTINGS -- USER SETTINGS -- USER SETTINGS -- USER SETTINGS --
  local search = ".rpp"
  local wait = 0.600 -- Explorer needs time to update/populate, set Time in seconds to wait between actions.
  
  -- setup >>
  if not reaper.APIExists('JS_Window_SetTitle') then
    reaper.MB('js_ReaScriptAPI extension is required for this script.', 'Missing API', 0)
    return
  end
  -- open explorer/make visible/select it
  local explorer = reaper.OpenMediaExplorer("", false)
  if not explorer then
    reaper.Main_OnCommand(50124, 0) -- Media explorer: Show/hide media explorer
    explorer = reaper.OpenMediaExplorer("", false)
  end
  -- get search combobox, show explorer if docked and not visible
  local cbo_search = reaper.JS_Window_FindChildByID(explorer, 0x3F7)
  if not cbo_search then return end
  if not reaper.JS_Window_IsVisible(cbo_search) then reaper.Main_OnCommand(50124, 0) end
  -- get file list
  local filelist = reaper.JS_Window_FindChildByID(explorer, 0x3E9)
  -- variable for wait timer
  local init_time = reaper.time_precise()
  --<< setup
  
  function PostKey(hwnd, vk_code) -- https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
    reaper.JS_WindowMessage_Post(hwnd, "WM_KEYDOWN", vk_code, 0,0,0)
    reaper.JS_WindowMessage_Post(hwnd, "WM_KEYUP", vk_code, 0,0,0)
  end
  
  function PostText(hwnd, str) -- https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-char
    for char in string.gmatch(str, ".") do
      local ret = reaper.JS_WindowMessage_Post(hwnd, "WM_CHAR", string.byte(char),0,0,0)
      if not ret then break end
    end
  end
  
  function SetExplorerPath(hwnd, folder)
    local cbo = reaper.JS_Window_FindChildByID(hwnd, 0x3EA)
    local edit = reaper.JS_Window_FindChildByID(cbo, 0x3E9)
    if edit then
      reaper.JS_Window_SetTitle(edit, "")
      PostText(edit, folder)
      PostKey(edit, 0xD)
    end
  end
  
  function SetExplorerSearch(hwnd, text)
    local cbo = reaper.JS_Window_FindChildByID(hwnd, 0x3F7)
    local edit = reaper.JS_Window_FindChildByID(cbo, 0x3E9)
    if edit then
      reaper.JS_Window_SetTitle(edit, "")
      PostText(edit, text)
      PostKey(edit, 0xD)
    end
  end
  
  
  function SortDateModified()
    if reaper.time_precise() < init_time then
      reaper.defer(SortDateModified)
    else
      reaper.JS_Window_SetFocus(filelist) -- Set focus on Media Explorer file list.
      reaper.JS_ListView_SetItemState(filelist, -1, 0x0, 0x2) -- unselect items in file list
      reaper.JS_WindowMessage_Send(explorer, "WM_COMMAND", 42256,0,0,0) -- "sort title" list
      reaper.JS_WindowMessage_Send(explorer, "WM_COMMAND", 42085,0,0,0) -- rescan database for new files    
      reaper.JS_WindowMessage_Send(explorer, "WM_COMMAND", 42254,0,0,0) -- "sort modified file" list
      reaper.JS_WindowMessage_Send(explorer, "WM_COMMAND", 42254,0,0,0) -- "sort modified file" list
      init_time = reaper.time_precise() + wait
      ScrollToTop()
    end
  end
  
  function ScrollToTop()
    if reaper.time_precise() < init_time then
      reaper.defer(ScrollToTop)
    else
      reaper.JS_WindowMessage_Send(filelist, "WM_VSCROLL", 6,0,0,0) -- scroll list to top
    end
  end
  
  function Main() 
    SetExplorerPath(explorer, path)       -- set path field // this is by default the "DB: ReaClips" folder defined at the top of the script
    SetExplorerSearch(explorer, search)   -- set search field 
    init_time = reaper.time_precise() + wait
    SortDateModified()
  end
  
  function Initalize() 
    if reaper.time_precise() < init_time then
      reaper.defer(Initalize)
    else
      Main()
    end
  end
  
  init_time = reaper.time_precise() + wait
  Initalize()

end



reaper.defer(SaveReaclipAndOpenMX())
