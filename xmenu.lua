
--[[
-- X Menu  ***************************************
]]--


function XMenu_FormatItem(item, depth)
local i, icon
local str=""

	for i=1,depth,1 do str=str.."	" end
	icon=AppIconFind(item, settings.icon_path)
	if icon ~= nil then str=str .. "IMG:" .. icon .. "	" end
	str=str .. item.name
	return str
end


function XMenu_ItemsWrite(S, group, depth)
local name, item, str

for name,item in pairs(group)
do
	if item.name ~= nil and item.type ~= "group"
	then
	str=XMenu_FormatItem(item, depth)
	if item.invoke ~= nil then str=str .. "	" .. item.invoke end
	S:writeln(str .."\n")
	end
end
end


function XMenu_SubmenuWrite(S, group, depth)
local name, item

if group.name ~= "RootMenu"
then
str=XMenu_FormatItem(group, depth)
S:writeln(str .. '\n')
end

-- First go through and write out all the submenus
for name,item in pairs(group)
do
	if item.type=="group" then XMenu_SubmenuWrite(S, item, depth + 1) end
end

XMenu_ItemsWrite(S, group, depth + 1)

end



function XMenu_MenuWrite(menu, Path)
local S

S=OpenOutputFile(Path)
if S ~= nil
then
if #faves_config > 0 then XMenu_ItemsWrite(S, faves_config, -1) end
XMenu_SubmenuWrite(S, menu, -1)
S:close()
end

end



--[[
-- X Menu  ***************************************
]]--

