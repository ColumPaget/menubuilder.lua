

function CtrlMenu_ItemsWrite(S, group, depth)
local name, item, str, icon

for name,item in pairs(group)
do
	if item.name ~= nil and item.type ~= "group"
	then
	str=item.name
	icon=AppIconFind(item, settings.icon_path)
--	if icon ~= nil then str=str.. " [#"..icon.."] " end
	if item.invoke ~= nil then str=str .. "	-- " .. item.invoke end
	S:writeln(str .."\n")
	end
end
end


function CtrlMenu_SubmenuWrite(S, group, depth)
local name, item

if group.name ~= "RootMenu"
then
S:writeln(group.name.. " {\n")
end

-- First go through and write out all the submenus
for name,item in pairs(group)
do
	if item.type=="group" then CtrlMenu_SubmenuWrite(S, item, depth + 1) end
end

CtrlMenu_ItemsWrite(S, group, depth + 1)

if group.name ~= "RootMenu"
then
S:writeln("\n}\n")
end


end



function CtrlMenu_MenuWrite(menu, Path)
local S

S=OpenOutputFile(Path)
if S ~= nil
then
if #faves_config > 0 then CtrlMenu_ItemsWrite(S, faves_config, -1) end
CtrlMenu_SubmenuWrite(S, menu, -1)
S:close()
end

end

