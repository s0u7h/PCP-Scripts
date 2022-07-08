-- Save ReaClip (selected items) and open Clips Library in Media Explorer
-- v0.1 - PCP - 14 June, 2022

-- Requires SWS, JS_ReaScriptAPI and ReaPack (specifically for the two cfillion scripts selecting send and receive tracks of selected tracks)
-- The script expects a database in the media explorer called "Clips". If you want to call this database something elee, just change the name below in the Edgemeal script (local path = "DB: xxxxx")

--USER SETTINGS -- 

reaclips_dir = "ReaClips"

-- You can change this directory name and resave the script with the new name if you want the option 
-- to have different ReaClip directories, e.g. reaclips_dir = "Synth Presets" or "Beats".
-- The script will create this subdirectory under your Default Save Path (set in Prefs) if it doesn't exist.
-- You should then create a database from that folder and save a new version of 
-- the action 'Script: Open Media Explorer to ReaClips database - search rpp - sort last modified (edgemeal).lua
-- Change the local DB in that script's settings to your database name too, i.e. DB: Synth Presets, or DB: Beats
-- Alternatively, an easier way is just to create a custom metadata field for your ReaClips, and classify them
-- as Synth Presets or Beats or Melodies or whatever

-- check if reaclips_dir exists, and if not, create it.

  retval, savepath = reaper.get_config_var_string("defsavepath")

reaclips_dir = savepath .. "/" .. reaclips_dir
  if reaclips_dir == "" then
    error_exit("Cannot save file - no ReaClips directory")
  end


  filename = os.date("%Y-%m-%d-%H_%M_%S")
  new_dir = reaclips_dir .. "/" .. filename
  new_path = new_dir .. "/" .. filename .. ".RPP"
  
  if reaper.file_exists(new_path) then
    error_exit("File already exists: \n" .. new_path)
  end
  
  
  if reaper.RecursiveCreateDirectory(new_dir, 0) == 0 then
    error_exit("Unable to create dir: \n" .. new_dir)
  end
  
  

reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAVESEL'), 0) -- SWS: Save current track selection'), 0)

reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SELTRKWITEM'), 0) -- SWS: Select only track(s) with selected item(s)

reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS07454ab62d927454fdbf507028b3e5299d3619dd'), 0) -- Script: cfillion_Select source tracks of selected tracks receives recursively.lua
reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS442c61972c3d71aaa886a5a47d809df69645bffa'), 0) -- Script: cfillion_Select destination tracks of selected tracks sends recursively.lua

reaper.Main_OnCommand(40210, 0) -- Track: Copy tracks
reaper.Main_OnCommand(41929, 0) -- New project tab (ignore default template)
reaper.Main_OnCommand(42398, 0) -- Item: Paste items/tracks
reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAFETIMESEL'), 0) -- SWS: Set time selection to selected items (skip if time selection exists)
reaper.Main_OnCommand(40049, 0) -- Time selection: Crop project to time selection

-- auto-save it to the reaclips folder using paat's code:
reaper.Main_SaveProjectEx(proj, new_path, 0)
reaper.Main_openProject("noprompt:" .. new_path)

-- and then save a proxy file so it'll be previewable in the MX (is there a way to call this from script instead of resaving via the action?

reaper.Main_OnCommand(42332, 0) -- File: Save project and render RPP-PROX
reaper.Main_OnCommand(40860, 0) --Close current project tab


--Open Media Explorer to Clips database - search rpp - sort last modified (edgemeal)


-- Show Media Explorer, set path, search and sort last modified
-- v1.03 - Edgemeal - Mar 22, 2021
-- Donate: https://www.paypal.me/Edgemeal
--
-- Tested: Win10/x64, REAPER v6.51+dev0318/x64, js_ReaScriptAPI v1.301
-- v1.03... Wait time set in seconds, added delay before scrolling to top.
-- v1.02.1. Scroll list to top after sort.
-- v1.02... Make filelist global, unselect files in list before sorting.




local path = "DB: " .. reaclips_dir
local search = ".rpp"

-- USER SETTINGS -- USER SETTINGS -- USER SETTINGS -- USER SETTINGS --
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
  SetExplorerPath(explorer, path)       -- set path field
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

--
--------------------------------------------------





-- Re-scan media explorer databases from main

init_time = reaper.time_precise() + wait
Initalize()


local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

reaper.PreventUIRefresh(1)

--reaper.Main_OnCommand(reaper.NamedCommandLookup"40289", 1) -- unselect all items

me = reaper.JS_Window_Find("Media Explorer", true)
reaper.JS_WindowMessage_Send(me, "WM_COMMAND", 42085, 0, 0, 0) -- Scan all databases for new files
--reaper.JS_WindowMessage_Send(me, "WM_COMMAND", 42255, 0, 0, 0) -- Sort file list by column: 'File Type'
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)

reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_RESTORESEL'), 0) --SWS: Restore saved track selection
