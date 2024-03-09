--[[
-- PWM  ***************************************
]]--


function PWM_ItemsWrite(S, group)
local name, value

for name,item in pairs(group)
do
	if item.type == "group"
	then
		S:writeln("  submenu \"".. item.name .. "\"\n")
	elseif item.invoke ~= nil
	then
		S:writeln("  entry \"".. item.name .. "\", \"exec\", \"" .. item.invoke .. "\"\n")
	end
end
end


function PWM_SubmenusWrite(S, group)
local name, value

for name,item in pairs(group)
do
	if item.type=="group"
	then
		S:writeln("  menu \"" ..  item.name .."\", \"".. item.name.."\" {\n")
		PWM_ItemsWrite(S, item)
		S:writeln("  }\n")
	end
end
end


function PWM_MenuWrite(menu, Path)
local i, item, S

S=OpenOutputFile(Path)
if S ~= nil
then

PWM_SubmenusWrite(S, menu)
S:writeln("menu \"root_menu\", \"Applications\" {\n")
if #faves_config > 0
then
	PWM_ItemsWrite(S, faves_config)
	S:writeln("Separator {}\n")
end

PWM_ItemsWrite(S, menu)

S:writeln("entry \"Restart\", \"restart\"\n")
S:writeln("entry \"Exit\", \"exit\"\n")

S:writeln("}\n")
S:close()
end

end



