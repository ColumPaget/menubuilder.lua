--[[
-- OPENBOX  ***************************************
]]--


function Openbox_ItemWrite(S, item)
local invoke

	if item.type=="group" 
	then 
		Openbox_SubmenuWrite(S, item.name, item)
	elseif item.invoke ~= nil 
	then
		icon=AppIconFind(item, settings.icon_path)
		if icon==nil then icon="" end

		-- blackbox dequotes these when running them
		invoke=string.gsub(item.invoke, "\\", "\\\\")

		--if there's arguments then it's likely that some form of shell replacement (e.g. '*') or shell variables are
		--being used, so we run this command under a shell
		if string.find(invoke, ' ') ~= nil
		then
			S:writeln("<item label=\"" .. item.name.. "\" icon=\""..icon.."\"><action name=\"Execute\"><command>/bin/sh -c \"" .. invoke.."\"</command></action></item>\n") 
		else
			S:writeln("<item label=\"" .. item.name.. "\" icon=\""..icon.."\"><action name=\"Execute\"><command>" .. invoke.."</command></action></item>\n") 
		end
	end
end
 

function Openbox_ItemsWrite(S, items)
local name, item

for name,item in pairs(items)
do
	Openbox_ItemWrite(S, item)
end
end


function Openbox_SubmenuWrite(S, title, group)
local name, icon

name,icon=GroupInfoFind(group)
if icon == nil then icon="" end

S:writeln("<menu id=\""..title.. "\" label=\""..title.."\" icon=\"" .. icon.. "\">\n")
Openbox_ItemsWrite(S, group)
S:writeln("</menu>\n")

end

function Openbox_MenuWrite(menu, Path)
local i, item, S

S=OpenOutputFile(Path)
if S ~= nil
then
	S:writeln("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n")
  S:writeln("<openbox_menu xmlns=\"http://openbox.org/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"  xsi:schemaLocation=\"http://openbox.org/ file:///usr/share/openbox/menu.xsd\">\n")
	S:writeln("<menu id=\"root-menu\" label=\"Openbox\">\n")

	if #faves_config > 0
	then
	Openbox_ItemsWrite(S, faves_config)
	S:writeln("<separator />\n")
	end


	Openbox_ItemsWrite(S, menu)
	S:writeln("<separator />\n")
	S:writeln("<item label=\"Reconfigure\"><action name=\"Reconfigure\"/></item>\n") 
	S:writeln("<item label=\"Restart\"><action name=\"Restart\"/></item>\n") 
	S:writeln("<item label=\"Exit\"><action name=\"Exit\"/></item>\n") 

	S:writeln("</menu>\n")
  S:writeln("</openbox_menu>\n")
	S:close()

	os.execute("openbox --reconfigure")
end

end


