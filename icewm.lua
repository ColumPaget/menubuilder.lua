
--[[
-- ICEWM  ***************************************
]]--

function IceWM_ItemWrite(S, icon, item)
local toks, str, exec

	if item.invoke ~=nil 
	then
		toks=strutil.TOKENIZER(item.invoke, " ")
		str=toks:next() 

		-- first token appears to be an environment variable setter, run this
		-- in a shell
		if string.find(str, "=") ~= nil
		then
			S:writeln("prog \"" .. item.name .. "\" \"" .. icon .. "\" /bin/sh -c \"" .. item.invoke.."\"\n") 
		else
			S:writeln("prog \"" .. item.name .. "\" \"" .. icon .. "\" " .. item.invoke.."\n") 
		end
	end

end

function IceWM_SubmenuWrite(S, group)
local name, value, icon

for name,item in pairs(group)
do
	if item.type=="group"
	then
		name,icon=GroupInfoFind(item)
		if icon==nil then icon="" end

		S:writeln("menu \"" .. name .. "\" \"".. icon .. "\" {\n")
		IceWM_SubmenuWrite(S, item)
		S:writeln("}\n\n")
	else
		icon=AppIconFind(item, settings.icon_path)
		if strutil.strlen(icon) == 0 then icon=item.name end	
		IceWM_ItemWrite(S, icon, item)
	end
end

end


function IceWM_MenuWrite(menu, Path)
local i, name, item, icon,  S

S=OpenOutputFile(Path)
if S ~= nil
then

if #faves_config > 0
then
	IceWM_SubmenuWrite(S, faves_config)
	S:writeln("separator\n")
end


IceWM_SubmenuWrite(S, menu)
S:close()

os.execute("icewm --restart")
end

end

