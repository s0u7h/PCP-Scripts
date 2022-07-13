retval, savepath = reaper.get_config_var_string("defsavepath")

--local filename = "test melodyne removed" -- name of a file under default save path for purposes of this test script
local filename = "no melo test" 
--local filename = "test melodyne" -- bp not false

dofile(reaper.GetResourcePath() .. "/" .. "Scripts" .. "/" .. "ReaTeam Scripts" .. "/" .. "Development" .. "/" .. "RPP-Parser" .. "/" .. "Reateam_RPP-Parser.lua")

local path = savepath .. "/" .. filename .. ".rpp"
local root = ReadRPP(path)



files, file_cnt = {}, 0
local registry = {}
local tracks = root:findAllChunksByName("TRACK")

for tr = 1, #tracks do
  local items = tracks[tr]:findAllChunksByName("ITEM")
  for i = 1, #items do
    local sources = items[i]:findAllChunksByName("TAKEFX")
    for s = 1, #sources do
      local a = sources[s]:findAllNodesByName("VST")
      local bp = sources[s]:findAllNodesByName("BYPASS")
      if bp == nil then
      reaper.ShowConsoleMsg("000")
      else    reaper.ShowConsoleMsg("bp not false")
      end
      local name = a[1].line:match('%S+ "(.+)"')
      
      
      if not registry[name] then
        registry[name] = true
        file_cnt = file_cnt+ 1
        files[file_cnt] = name
      end
    end
  end
end

reaper.ShowConsoleMsg('Referenced vsts in project "' .. path .. '" :\n\n')
for f = 1, file_cnt do

  reaper.ShowConsoleMsg(string.format("  %03i) %s\n", f, files[f]))
end












local ara = root:findFirstChunkByName("VST") -- does it have the ARASRC chunk header? If it does that means that the project has had ARA at some point
--local takefx = ara:getTokens()

--"VST3: Melodyne (Celemony)" Melodyne.vst3 0 ""


local melooo = root:findFirstChunkByName(VST)
--count_melo = ara:getToken(0)
--takefx:findAllNodesByFilter("Melodyne", start_index, end_index)
local takestring = StringifyRPPNode(ara)
reaper.ShowMessageBox(tostring(takestring), "count_melo", 0)

--ox.exit

--local melodyne_vst =takefx:findFirstNodeByName("Melodyne")
reaper.ShowMessageBox(tostring(melodyne_vst), "ARA chunk", 0)
if ara == false then 
reaper.ShowMessageBox("No ARA", "Does u has ARA?", 0)
else
reaper.ShowMessageBox("YesARA", "Does u has ARA?", 0)
end





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
    end
    
local number_melodyne = find_melodyne_number_in_item(take, number_melodyne)
reaper.ShowMessageBox(tostring(number_melodyne), "number_melodyne", 0)

--files, file_cnt = {}, 0
--local registry = {}

--local node = sources[s]:findFirstNodeByName("ara") -- there is only one node which interest us here
--local name = node:getToken(2):getString() -- we get the second token, and we convert it to string as it is an object by default

-- alternative
--local name = node:getToken(2).token -

--reaper.ShowConsoleMsg('Referenced ARA files in project "' .. path .. '" :\n\n')
--for f = 1, file_cnt do
  --reaper.ShowConsoleMsg(string.format("  %03i) %s\n", f, name[f]))
--end
