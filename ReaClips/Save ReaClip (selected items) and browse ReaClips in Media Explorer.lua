-- @description Save ReaClip (selected items) and browse ReaClips in Media Explorer
-- @author PCP
-- @version 1.0
-- @about
--   Save ReaClip (selected items) and browse ReaClips in Media Explorer
--
--   Requires SWS, JS_ReaScriptAPI and ReaPack (me2beats and cfillion repos)
--
--   The script creates a folder under the default save path called "ReaClips". If you want to call this folder something elee,  change the setting below.

---- USER SETTINGS ---- 

local path = "ReaClips"

-----------------------

-- OPTIONAL: You can change this directory name and resave the script with the new name if you want  
-- to have different ReaClip directories, e.g. path = "Synth Presets" or "Beats".
-- The script will create this subdirectory under your Default Save Path (set in Prefs) if it doesn't exist.
-- the action 'Script: Open Media Explorer to ReaClips database - search rpp - sort last modified (edgemeal).lua
-- instead of "ReaClips", i.e. "Synth Presets", or "Beats" or "Melodyned Clips"

-- Alternatively, an easier way to organise is just to keep everything in the ReaClips folder and set a custom metadata field for your ReaClips, and classify them
-- as Synth Presets or Beats or Melodies or whatever

function SaveReaClipAndOpenMX()
  project_dirty = reaper.IsProjectDirty(proj)
  if project_dirty == 1 then 
    SaveCurrentProject()
  end
  SaveReaClip()
  --aper.defer(open_mx_to_reaclips_path())
  open_mx_to_reaclips_path()
end

function error_exit(message)
  reaper.ShowMessageBox(message, "Error", 0)
  os.exit()
end

function retry_save()
  reaper.ShowMessageBox("ReaClip exists, try another file name", "File Exists", 5)
  retry = true
  if retry == true then
     SaveReaClip()
  end
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

function SaveReaClip()
-- this code adapted from paat's auto-save script, adding a user prompt and a default ReaClips subdirectory
  retval, savepath = reaper.get_config_var_string("defsavepath")
  if savepath == "" then
    error_exit("Cannot save file - no default save path")
  end
  
  filename = os.date("%Y-%m-%d-%H_%M_%S")
  local rv, rv_str = reaper.GetUserInputs("Save ReaClip as..", 1, "ReaClip Name: ,extrawidth=250", filename)
  if rv==true then
    filename = rv_str
  end
  if not rv then
    cancel()
  end
  
  new_dir = savepath .. "/" .. path .. "/" .. filename 
  new_path = new_dir .. "/" .. filename .. ".RPP"
  
  if reaper.file_exists(new_path) then
   retry_save("ReaClip already exists: \n" .. new_path)
   if retry == false then
      os.exit()
   else return
   end
  end
  
  if reaper.RecursiveCreateDirectory(new_dir, 0) == 0 then
    error_exit("Unable to create dir: \n" .. new_dir)
  end
  
  --open a new project tab and open this same project in it. slot 1 will be our OG project. slot 2 is where we'll resave a cropped version of the OG project as a ReaClip.
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS1ad9b3e745ad836bebeee40ba9e7a5279a356ea8'), 0)  -- Script: me2beats_Save active project tab, slot 1.lua
  reaper.Main_SaveProjectEx(proj, new_path, 0) --silently saves to Reaclips folder without copying audio files - still atlased to the original
  reaper.Main_OnCommand(41929, 0)   -- New project tab (ignore default template)
  reaper.Main_openProject("noprompt:" .. new_path)
  
  -- this section crops to the selected items and gets rid of any tracks that don't directly affect those items.
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SELTRKWITEM'), 0) -- SWS: Select only track(s) with selected item(s)
  -- reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAFETIMESEL'), 0) -- SWS: Set time selection to selected items (skip if time selection exists)
  reaper.Main_OnCommand(40290, 0)-- Time selection: Set time selection to items
  reaper.Main_OnCommand(40049, 0) -- Time selection: Crop project to time selection
  reaper.Main_OnCommand(40289, 0) --Item: Unselect (clear selection of) all items
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_BR_FOCUS_TRACKS'), 0) --SWS/BR: Focus tracks
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SELROUTED'), 0) -- SWS: Select tracks with active routing to selected track(s)  
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS0549eb7e7dc511aaba72563bf42874c6c5877b95'), 0)   --Script: me2beats_Save selected tracks, slot 1.lua
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS07454ab62d927454fdbf507028b3e5299d3619dd'), 0) -- Script: cfillion_Select source tracks of selected tracks receives recursively.lua
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS71c2ed15049b99550b96ca77f6b1cd396f3b56cb'), 0)  --Script: me2beats_Save selected tracks, slot 2.lua
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS51083d71f45b97fc7fc3bc03abac857476664994'), 0) --Script: me2beats_Restore selected tracks, slot 1.lua
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS442c61972c3d71aaa886a5a47d809df69645bffa'), 0) -- Script: cfillion_Select destination tracks of selected tracks sends recursively.lua
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_RSde5e5ba9a6c07884d4472bd0c76e1c4cb6603af3'), 0)   --Script: me2beats_Restore selected tracks, slots 1+2 (add to selection).lua
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_TOGTRACKSEL'), 0) --SWS: Toggle (invert) track selection
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_S&M_REMOVE_TR_GRP'), 0) --SWS/S&M: Remove track grouping for selected tracks // otherwise it could delete the tracks we want to save
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_BR_FOCUS_TRACKS'), 0) --SWS/BR: Focus tracks
  reaper.Main_OnCommand(40184, 0) -- Remove items/tracks/envelope points (depending on focus) - no prompting
  
  -- auto-save it to the reaclips folder using paat's code: 
  -- still no way to set an option to save media with the file and set save path with Main_SaveProjectEx
  reaper.Main_SaveProject(0, true) -- *now* the project is saved with any remaining source media.  the boolean true forces a 'save as', and user must check that 'copy media' is selected (should be default) as there's no way in REAPER to specify saving copies of source audio. the boolean true forces a 'save as'
  reaper.Main_OnCommand(42332, 0) -- File: Save project and render RPP-PROX - shouldn't prompt after last save. this will generate the preview in MX
  reaper.Main_OnCommand(40860, 0)  --Close current project tab
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_RSc4b08953457ee0ea58cc55d5ccce70175d05f0c5'), 0)  -- Script: me2beats_Restore saved project tab, slot 1.lua
end


function open_mx_to_reaclips_path()
  --Open Media Explorer to Reaclips path - search rpp - sort last modified (modified edgemeal)
  
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
  local reaclips_folder = savepath .. path
  
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
    SetExplorerPath(explorer, reaclips_folder)       -- set path field // this is by default the "ReaClips" folder defined at the top of the script
    SetExplorerSearch(explorer, search)   -- set search field 
    init_time = reaper.time_precise() + wait
    SortDateModified()
   -- reaper.Main_OnCommand(50124, 0)--Browser: Refresh
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

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

SaveReaClipAndOpenMX()

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

