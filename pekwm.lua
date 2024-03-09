--[[
-- PEKWM  ***************************************
]]--


function PekWM_ItemsWrite(S, group)
local name, value

for name,item in pairs(group)
do
	if item.type=="group"
	then
		PekWM_SubmenuWrite(S, item)
	elseif item.invoke ~= nil 
	then 
			S:writeln("  Entry = \"".. item.name .. "\" { Actions = \"Exec " .. item.invoke .. " &\" }\n")
	end
end
end


function PekWM_SubmenuWrite(S, group)
local conf, name

S:writeln("  Submenu = \"" .. group.name .."\" {\n")
PekWM_ItemsWrite(S, group)
S:writeln("  }\n")
end



function PekWM_MenuWrite(menu, Path)
local i, item, S

S=OpenOutputFile(Path)
if S ~= nil
then
S:writeln("RootMenu = \"Applications\" {\n")
if #faves_config > 0
then
	PekWM_ItemsWrite(S, faves_config)
	S:writeln("Separator {}\n")
end

PekWM_ItemsWrite(S, menu)

S:writeln("Separator {}\n")
S:writeln("Entry=\"Reload\" { Actions = \"Reload\" }\n")
S:writeln("Entry=\"Restart\" { Actions = \"Restart\" }\n")
S:writeln("Entry=\"Exit\" { Actions = \"Exit\" }\n")

S:writeln("}\n")
S:close()
end

end


