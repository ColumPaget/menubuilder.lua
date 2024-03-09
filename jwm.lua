--[[
-- JWM  ***************************************
]]--


function JWM_ItemsWrite(S, group)
local name, value, icon

for name,item in pairs(group)
do
	if item.type=="group"
	then
		JWM_SubmenuWrite(S, item)
	elseif item.invoke ~= nil 
	then 
		icon=AppIconFind(item, settings.icon_path)
		if icon ~=nil
		then
			S:writeln("  <Program label=\"".. item.name .. "\" icon=\""..icon.."\">" .. item.invoke .. "</Program>\n")
		else
			S:writeln("  <Program label=\"".. item.name .. "\">" .. item.invoke .. "</Program>\n")
		end
	end
end
end


function JWM_SubmenuWrite(S, group)
local conf, name,icon

name,icon=GroupInfoFind(group)
if icon ~= nil
then
	S:writeln("  <Menu icon=\""..icon.."\" label=\"" .. name .."\">\n")
else
	S:writeln("  <Menu label=\"" .. name .."\">\n")
end

JWM_ItemsWrite(S, group)

S:writeln("  </Menu>\n")
end



function JWM_MenuWrite(menu, Path)
local i, item, S

S=OpenOutputFile(Path)
if S ~= nil
then

S:writeln("<?xml version=\"1.0\"?>\n")
S:writeln("<JWM>\n")
S:writeln("<RootMenu>\n")

if #faves_config > 0
then
JWM_ItemsWrite(S, faves_config)
S:writeln("<Separator/>\n")
end

JWM_ItemsWrite(S, menu)

S:writeln("<Separator/>\n")
S:writeln("<Restart label=\"Restart\" icon=\"restart.png\"/>\n")
S:writeln("<Exit label=\"Exit\" confirm=\"true\" icon=\"quit.png\"/>\n")
S:writeln("</RootMenu>\n")
S:writeln("</JWM>\n")


S:close()

os.execute("jwm -reload")
end

end

