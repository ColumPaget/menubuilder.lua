--[[
-- FVWM  ***************************************
]]--


function FVWM_ItemsWrite(S, group)
local name, value, icon, str

for name,item in pairs(group)
do
	if item.invoke ~= nil 
	then 
		str="+ \"" .. string.gsub(item.name, " ", "&");
		icon=AppIconFind(item, settings.icon_path)
--		if icon ~=nil then str=str.."%"..icon.."%" end
		str=str.."\" Exec "..item.invoke

		S:writeln(str .. "\n")
	end
end

for name,item in pairs(group)
do
	if item.type=="group"
	then
		FVWM_SubmenuWrite(S, item)
	end
end

end



function FVWM_MenuOutput(S, name, icon, items, top_items)
local item, subname

str="\nDestroyMenu " .. string.gsub(name, " ", "_") .. "\n"
str=str .."AddToMenu " .. string.gsub(name, " ", "_") .. " \"" .. name .."\" Title\n" 
S:writeln(str)

if top_items ~= nil 
then 
FVWM_ItemsWrite(S, top_items) 
if #top_items > 0 then S:writeln("+ \"\" Nop\n") end
end

for i,item in ipairs(items)
do
	if item.type=="group" then 
	subname=GroupInfoFind(item)
	S:writeln("+ \""..item.name.."\" Popup " .. string.gsub(subname, " ", "_") .. "\n") 
	end
end

end



function FVWM_SubmenuWrite(S, group)
local name,icon

name,icon=GroupInfoFind(group)
FVWM_MenuOutput(S, name, icon, group)
FVWM_ItemsWrite(S, group)
end



function FVWM_MenuWrite(menu, Path)
local i, item, S

S=OpenOutputFile(Path)
if S ~= nil
then

FVWM_MenuOutput(S, "MenuFvwmRoot", "", menu, faves_config)
S:writeln("+ \"\" Nop\n")
S:writeln("+ \"Refresh\" Refresh\n")
S:writeln("+ \"Restart\" Restart\n")
S:writeln("+ \"Quit\" Module FvwmScript FvwmScript-ConfirmQuit\n")


FVWM_ItemsWrite(S, menu)


S:close()

end

end


