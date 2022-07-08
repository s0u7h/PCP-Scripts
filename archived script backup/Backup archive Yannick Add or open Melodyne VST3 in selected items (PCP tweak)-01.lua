--edited slightly by PCP to open in chain, to enable docking

-- @description Yannick_Add or open Melodyne VST3 in selected items
-- @author Yannick
-- @version 1.10
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + fixed bug with MIDI and AUDIO items
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  -- USER SETTINGS --
  
  docked_in_chain = true
  
  
  -------------------
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAVETIME5'), 0) -- save time selection slot 5 - PCP add
  reaper.Main_OnCommand(40290, 0) -- Time selection: Set time selection to items - PCP add - this makes melodyne open on the relevant bit
  
 
    function Zoom()
      if docked_in_chain == true then
         reaper.Main_OnCommand(41622, 0) --toggle zoom to selected items
      end
    end
    
    function Unzoom()
      if docked_in_chain == true then
      reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAVESEL'), 0) -- save current track selection
      reaper.Main_OnCommand(40296, 0) -- select all tracks
      reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_VZOOMFIT'), 0) -- vertical zoom to selected tracks
      reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_RESTORESEL'), 0) -- restore saved track selection
      end
    end
    
    
  function DockAllItemFX()
    ---- whicHDock -1=not found, 0=bottom, 1=left, 2=top, 3=right, 4=floating 
    local number, list = reaper.JS_Window_ListFind("FX: Item", false)
    if number > 0 then
      for address in list:gmatch("[^,]+") do
        local FX_win = reaper.JS_Window_HandleFromAddress(address)
        local title = reaper.JS_Window_GetTitle(FX_win)
        
        local cwd = reaper.GetConfigWantsDock(tostring(title)) -- the dock id that the fx window will dock to
        reaper.ShowMessageBox(tostring(cwd), "cwd", 0)
        --melhwnd = reaper.TakeFX_GetFloatingWindow(title, 1)
        --rval, isFloatingDocker = reaper.DockIsChildOfDock(melhwnd)
       -- reaper.ShowMessageBox(tostring(FX_win), "FX_win", 0)
       -- reaper.ShowMessageBox(tostring(title), "title", 0)
       
        --reaper.ShowMessageBox(tostring(isFloatingDocker), "isFloatingDocker", 0)
        --reaper.Dock_UpdateDockID(title, 2)
        --reaper.DockWindowRefresh()
     end 
     end
    end
  --reaper.defer(function() end)      
        
  
  function bla() end
  function nothing() reaper.defer(bla)end
  
  if reaper.CountSelectedMediaItems(0) == 0 then
    nothing() return
  end
  
  if not reaper.MIDIEditor_EnumTakes then
    reaper.MB("Please update REAPER to version 6.37 or higher", "Error", 0)
    nothing() return
  end
  
  local path = reaper.GetResourcePath() .. "/reaper-vstplugins64.ini"
  if reaper.file_exists(path) == false then
    reaper.MB("You don't have the following file - 'reaper-vstplugins64.ini\n\n" ..
    "Install third party VST plugins and open FX Browser to generate these file", "Error", 0)
    nothing() return
  end
  
  ---FIND MELODYNE USER NAME-------------------------------------------------------
  local user_name_melodyne = nil
  local file = io.open(path, 'r')
  for l in file:lines() do
    if l:find("{5653544D6C70676D656C6F64796E6520,") -- VST3 Melodyne hash
    or l:find("Melodyne.vst3=") --- VST3 Melodyne name
    then
      user_name_melodyne = l:match("[^,]+,[^,]+,(.+)")
      break
    end
  end
  io.close(file)
  if user_name_melodyne == nil then
    reaper.MB('The Melodyne (Celemony) plugin was not found!\n\n' 
    .. 'Perhaps the plugin is not installed, or you have changed the original name '
    .. 'of the .vst3 file of the Melodyne (Celemony) plugin to another name then please return the original name!', 
    'Error', 0)
    nothing() return
  end
  ---------------------------------------------------------------------------------
  
  function find_melodyne_number_in_item(take, number_melodyne)
    for i=0, reaper.TakeFX_GetCount(take) - 1 do
      local retval, buf = reaper.TakeFX_GetNamedConfigParm( take, i, 'fx_ident' )
      if buf:find("{5653544D6C70676D656C6F64796E6520") then
        number_melodyne = i
      end
    end
    if number_melodyne == nil then
      number_melodyne = 'no number'
    end
    return number_melodyne
  end
  
  local count_sel_items = reaper.CountSelectedMediaItems(0)
  
  for i=0, count_sel_items-1 do
    local item = reaper.GetSelectedMediaItem(0,i)
    local take = reaper.GetActiveTake(item)
    if reaper.TakeIsMIDI(take) == true then
      reaper.MB('Please select only audio items', 'Error', 0)
      nothing() return
    end
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local t_open_melodyne = {}
  local t_sel_tracks = {}

  for i=0, count_sel_items-1 do
    local number_melodyne = 'no number'
    local item = reaper.GetSelectedMediaItem(0,i)
    local take = reaper.GetActiveTake(item)
    local number_melodyne = find_melodyne_number_in_item(take, number_melodyne)
    if number_melodyne == 'no number' then
      reaper.TakeFX_AddByName( take, user_name_melodyne, -1)
      number_melodyne = find_melodyne_number_in_item(take, number_melodyne)
    end
    

    local tr_it_1 = reaper.GetMediaItem_Track(item)
    if i < count_sel_items-1 then
      local item_2 = reaper.GetSelectedMediaItem(0,i+1)
      local tr_it_2 = reaper.GetMediaItem_Track(item_2)
      if tr_it_1 ~= tr_it_2 then
        t_sel_tracks[#t_sel_tracks+1] = tr_it_1
      end
    else
      t_sel_tracks[#t_sel_tracks+1] = tr_it_1
    end
    last_item = item
    last_number_melodyne = number_melodyne
  end

  reaper.Main_OnCommand(40297,0) -- unselect all tracks

  for i=1, #t_sel_tracks do
    reaper.SetTrackSelected(t_sel_tracks[i], true)
  end
  -- pcp tweak, check if take FX window is open and, if so, close it. 

if reaper.TakeFX_GetOpen( reaper.GetActiveTake(last_item), last_number_melodyne, 1) == true then -- if Melodyne is open for current item then
        reaper.TakeFX_Show( reaper.GetActiveTake(last_item), last_number_melodyne, 0) -- close it i.e. hide FX chain
        Unzoom()
        
       --reaper.Main_OnCommand(41622, 0) --toggle zoom to selected items
        --if zoomed_to_items == 1 then -- and if we've previously zoomed in to the selected item then
                        --reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_UNDOZOOM'), 0) -- SWS: Undo zoom
                        --reaper.Main_OnCommand(41622, 0) --toggle zoom to selected items
        --  reaper.Main_OnCommand(40848, 0)--View: Restore previous zoom/scroll position, and then set:
        --  zoomed_to_items = 0
        --return
        --end
        
    else if docked_in_chain == true then -- -- i.e. if Melodyne UI is not visible, then if the user pref is to dock Melodyne then...
            
            --DockAllItemFX()
            
            --if dockedfx .. tostring(take) == false then
            reaper.TakeFX_Show( reaper.GetActiveTake(last_item), last_number_melodyne, 0) -- show item fx floating 
            reaper.Main_OnCommand(41172, 0) -- dock/undock currently focused window
            --dockedfx + tostring(take) = true -- then set a flag so that on subsequent launches it opens in the dock
            --end
           -- if dockedfx .. tostring(take) == true then
           -- reaper.TakeFX_Show( reaper.GetActiveTake(last_item), last_number_melodyne, 1) -- show item fx in chain
           -- end    
                
            --local hwnd = reaper.JS_Window_Find("FX Item", false)
           --hwnd = reaper.TakeFX_GetFloatingWindow(0, -1)
            --retval, isFloatingDocker = reaper.DockIsChildOfDock( hwnd )
            --reaper.Main_OnCommand(41172, 0) -- dock/undock currently focused window
          --  fx_index = reaper.TakeFX_GetChainVisible(0)
           --melo_hwnd = reaper.TakeFX_GetFloatingWindow(reaper.GetActiveTake(last_item), 0) -- get the melodyne fx chain's hwnd
           --dock_indes, isFloatingDocker = reaper.DockIsChildOfDock(melo_hwnd)
           -- reaper.ShowMessageBox(tostring(melo_hwnd), "melo_hwnd", 0)
          --  reaper.ShowMessageBox(tostring(isFloatingDocker), "isFloatingDocker", 0)
          --reaper.ShowMessageBox(tostring(last_number_melodyne), "last_number_melodyne", 0)
          --reaper.ShowMessageBox(tostring(hwnd), "hwnd", 0)
          --reaper.ShowMessageBox(tostring(isFloatingDocker), "isFloatingDocker", 0)
          --fxchain:take
            --if isFloatingDocker == true then
            --  reaper.DockWindowAddEx(melo_hwnd, 0, 0, true)
         --     reaper.DockWindowActivate(melo_hwnd)
             --reaper.ShowMessageBox(tostring(isFloatingDocker), "isFloatingDocker", 0)
            --end
            
            --reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_ITEMZOOMMIN_NO_ENV'), 0) -- SWS: Zoom to selected items, minimize others (ignore last track's envelope lanes)
            --zoomed_to_items = 1
            
            
                        --reaper.Main_OnCommand(41622, 0) --toggle zoom to selected items
                        --reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_ITEMZOOM_NO_ENV'), 0) -- SWS: Zoom to selected items (ignore last track's envelope lanes)
           
          else  
            reaper.TakeFX_Show( reaper.GetActiveTake(last_item), last_number_melodyne, 3) -- else as a floating window
          end
          Zoom()
end

 reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_RESTTIME5'), 0) -- restore time selection slot 5 

 -- end pcp tweak
  
  
  
  reaper.Undo_EndBlock('Add or open Melodyne VST3 in selected items', -1)
  reaper.PreventUIRefresh(-1)
