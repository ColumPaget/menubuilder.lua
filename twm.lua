function TWM_ItemsWrite(S, group)
local conf, name, item

for name,item in pairs(group)
do
	if item.type=="group"
	then
		S:writeln("  \""..item.name.. "\" f.menu \"" .. string.gsub(item.name, " ", "_").. "\"\n")
	elseif item.invoke ~= nil 
	then 
			S:writeln(" \"".. item.name .. "\" f.exec \"" .. item.invoke .. "&\"\n")
	end
end
end


function TWM_SubmenuWrite(S, group)
local name, item

-- First go through and write out all the submenus
for name,item in pairs(group)
do
	if item.type=="group" then TWM_SubmenuWrite(S, item) end
end


S:writeln("Menu \"" .. string.gsub(group.name, " ", "_") .. "\"\n{\n")

if group.name=="RootMenu" and #faves_config > 0
then
	S:writeln("\"Root Menu\"   f.title\n")
	TWM_ItemsWrite(S, faves_config)
	S:writeln("\"no-label\" f.separator\n")
end

TWM_ItemsWrite(S, group)

if group.name == "RootMenu"
then
	S:writeln("\"no-label\" f.separator\n")
	S:writeln("\"Restart\" f.restart\n")
	S:writeln("\"Exit\" f.quit\n")
end

S:writeln("}\n\n")
end



function TWM_MenuWrite(menu, Path)
local i, item, S

S=OpenOutputFile(Path)
if S ~= nil
then

TWM_SubmenuWrite(S, menu)

S:close()
end

end


