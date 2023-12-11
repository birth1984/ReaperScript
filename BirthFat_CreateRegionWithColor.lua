local colorR = 247
local colorG = 198
local colorB = 166

--================================== FUNCTION ======================================================================
console = true -- true/false: display debug messages in the console
-- Display a message in the console for debugging
function MsgConsole(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--================================== FUNCTION ======================================================================


-- =================================  Insert markers at grid lines in time selection ===========================
measure_color = 1
measure_r = 0
measure_g = 128
measure_b = 0

beat_color = 1
beat_r = 128
beat_g = 0
beat_b = 128
-- Round at two decimal
-- By Igor Skoric
function round( val, num )
  local mult = 10^(num or 0)
  if val >= 0 then return math.floor(val * mult + 0.5) / mult
  else return math.ceil(val*mult-0.5) / mult end
end

function BFInsertMarkersAtGridLinesInTimeSelection()
  last_time = ts_start

  if measure_color ~= 0 then
    measure_color = reaper.ColorToNative( measure_r, measure_g, measure_b )|0x1000000
  end
  if beat_color ~= 0 then
    beat_color = reaper.ColorToNative( beat_r, beat_g, beat_b )|0x1000000
  end

  time = reaper.BR_GetClosestGridDivision( last_time )
  if time == ts_start then
  local color = 0
  local retval, measures, cml, fullbeats, cdenom = reaper.TimeMap2_timeToBeats( proj, time )
  if beat_color ~=0 then
   color = beat_color
  end

  if measure_color ~= 0 and round(retval, 10) % cml == 0 then
   color = measure_color
  end
  reaper.AddProjectMarker2(0, false, time, 0, "", -1, color)
  end

  -- INITIALIZE loop through selected items
  repeat

    local time = reaper.BR_GetNextGridDivision( last_time )
    local color = 0
    local retval, measures, cml, fullbeats, cdenom = reaper.TimeMap2_timeToBeats( proj, time )

    if beat_color ~=0 then
  color = beat_color
    end

    if measure_color ~= 0 and round(retval, 10) % cml == 0 then
  color = measure_color
    end

    if time <= ts_end then
  reaper.AddProjectMarker2(0, false, time, 0, "", -1, color)
    end
    last_time = time

  until last_time > ts_end -- ENDLOOP through selected items

end

-- =================================  Insert markers at grid lines in time selection ===========================

-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems ()
  for i = 0, count_sel_items - 1 do
    local entry = {}
    entry.item = reaper.GetSelectedMediaItem(0,i)
    entry.pos_start = reaper.GetMediaItemInfo_Value(entry.item, "D_POSITION")
    entry.pos_end = entry.pos_start + reaper.GetMediaItemInfo_Value(entry.item, "D_LENGTH")
    local take = reaper.GetActiveTake( entry.item )
    retval, entry.name = reaper.GetSetMediaItemInfo_String( entry.item, 'P_NOTES', '', false )
    if take then
      entry.color = reaper.GetDisplayedMediaItemColor2( entry.item, take )
    else
      entry.color = reaper.GetDisplayedMediaItemColor( entry.item )
    end
    table.insert(init_sel_items, entry)
  end
end

--------------------------------------------------------- END OF UTILITIES


-- Function Start =================================  Caculate Color ===========================

-- From https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
hue = math.random( 360 ) / 360
saturation = 0.5
luminosity = 0.5

function hue2rgb(p, q, t)
  if t < 0   then t = t + 1 end
  if t > 1   then t = t - 1 end
  if t < 1/6 then return p + (q - p) * 6 * t end
  if t < 1/2 then return q end
  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
  return p
end

--[[
 * Converts an RGB color value to HSL. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and l in the set [0, 1].
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSL representation
]]
function rgbToHsl(r, g, b, a)
  r, g, b = r / 255, g / 255, b / 255

  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l

  l = (max + min) / 2

  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, l, a or 255
end

--hue = math.random( 360 ) / 360

function hslToRgb(h, s, l, a)
  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else

    local q
    
    if l < tonumber(0.5) then 
      q = l * (1 + s) 
    else 
      q = l + s - l * s 
    end
    
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end
  
  r = math.floor((r * 255) + 0.5)
  g = math.floor((g * 255) + 0.5)
  b = math.floor((b * 255) + 0.5)
  
  return r, g, b, a * 255
  
end

function RGB2INT ( R, G, B )
  local color = (R + 256 * G + 65536 * B)|16777216
  return color
end

function GetRandomColor()
  hue = hue + 137 / 360
  if hue > 1 then hue = hue - 1 end
  local R, G, B, A = hslToRgb( hue, saturation, luminosity, 1 )
  Msg("\nR = " .. R .. "\nG = " .. G ..  "\nB = " .. B)
  local color_int = RGB2INT( R, G, B )
  return color_int
end

-- Function End =================================  Caculate Color ===========================


--FUNCTION Start:=============================== Create regions from selected items notes and color ===========================

function BFCreatRegionsFromSelectedItemsNotesAndColor()

  tempPosStart = 999999 
  tempPosEnd = 0 
  --tempColor = GetRandomColor()
  tempColor = RGB2INT(colorR,colorG,colorB)
  
  for  j, item in ipairs( init_sel_items ) do
    if item.pos_start < tempPosStart then
      tempPosStart = item.pos_start
    end
    if item.pos_end > tempPosEnd then
      tempPosEnd = item.pos_end
    end
  end
  count_markers_regions, count_markersOut, count_regionsOut = reaper.CountProjectMarkers(0)
  
  reaper.AddProjectMarker2( 0, true, tempPosStart, tempPosEnd, " ??? " , count_regionsOut, tempColor )
end




--FUNCTION END:================================= Create regions from selected items notes and color ===========================

--================================== Main ========================================================================

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  reaper.ClearConsole()

  init_sel_items =  {}
  SaveSelectedItems(init_sel_items)

  BFCreatRegionsFromSelectedItemsNotesAndColor()

  reaper.Undo_EndBlock("Create regions from selected items notes and color", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end

--================================== Main ========================================================================
