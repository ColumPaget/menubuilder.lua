
--[[
-- BLACKBOX/FLUXBOX/HACKEDBOX  ***************************************
]]--


function Blackbox_ItemWrite(S, item)
local invoke

	if item.type=="group" 
	then 
		Blackbox_SubmenuWrite(S, item.name, item)
	elseif item.invoke ~= nil 
	then
		-- blackbox dequotes these when running them
		invoke=string.gsub(item.invoke, "\\", "\\\\")

		--if there's arguments then it's likely that some form of shell replacement (e.g. '*') or shell variables are
		--being used, so we run this command under a shell
		if string.find(invoke, ' ') ~= nil
		then
			S:writeln("[exec] (" .. item.name.. ") {/bin/sh -c \"" .. invoke.."\"}\n") 
		else
			S:writeln("[exec] (" .. item.name.. ") {" .. invoke.."}\n") 
		end
	end
end
 

function Blackbox_ItemsWrite(S, items)
local name, item

for name,item in pairs(items)
do
	Blackbox_ItemWrite(S, item)
end
end


function Blackbox_SubmenuWrite(S, title, group)

S:writeln("[submenu] ("..title..")\n")
Blackbox_ItemsWrite(S, group)
S:writeln("[end]\n")

end

function Blackbox_MenuWrite(menu, Path)
local i, item, S

S=OpenOutputFile(Path)
if S ~= nil
then
	S:writeln("[begin] (Root Menu)\n")
	if #faves_config > 0
	then
	Blackbox_ItemsWrite(S, faves_config)
	S:writeln("[nop]\n")
	end


	Blackbox_ItemsWrite(S, menu)

	S:writeln("[nop]\n")
	S:writeln("[workspaces] (workspace menu)\n")
	S:writeln("[config] (blackbox config)\n")
	S:writeln("[reconfig] (Reconfigure)\n")
	S:writeln("[restart] (Restart)\n")
	S:writeln("[exit] (Exit)\n")
	S:writeln("[end]\n")

	S:close()
end

end


