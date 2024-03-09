--[[
-- MLVWM  ***************************************
]]--


function MLVWM_ItemsWrite(S, group)
local conf, name, item

for name,item in pairs(group)
do
	if item.type=="group"
	then
		S:writeln("  \""..item.name.. "\" SubMenu " .. string.gsub(item.name, " ", "_").. "\n")
	elseif item.invoke ~= nil 
	then 
			S:writeln(" \"".. item.name .. "\" Action Exec \"" ..item.name .. "\" exec " .. item.invoke .. "\n")
	end
end
end


function MLVWM_SubmenuWrite(S, group)
local name, item

-- First go through and write out all the submenus
for name,item in pairs(group)
do
	if item.type=="group" then MLVWM_SubmenuWrite(S, item) end
end


S:writeln("Menu " .. string.gsub(group.name, " ", "_") .. ", Label \"" .. group.name .. "\"\n")

if group.name=="RootMenu" and #faves_config > 0
then
	MLVWM_ItemsWrite(S, faves_config)
	S:writeln("\"\" NonSelect\n")
end


MLVWM_ItemsWrite(S, group)

if group.name == "RootMenu"
then
	S:writeln("\"\" NonSelect\n")
	S:writeln("\"Restart\" Action Restart mlvwm\n")
	S:writeln("\"Exit\" Action Exit\n")
end

S:writeln("END\n\n")
end



function MLVWM_MenuWrite(menu, Path)
local i, item, S

S=OpenOutputFile(Path)
if S ~= nil
then
	MLVWM_SubmenuWrite(S, menu)
	S:close()
end

end


