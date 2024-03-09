--[[
--  DESKTOP FILES  ***************************************
]]--

function AppChooseGroup(name, groups)
local str
local toks

if app_configs[name] ~= nil 
then
	if strutil.strlen(app_configs[name].group) > 0 then return app_configs[name].group end
end

if groups==nil then return nil end

toks=strutil.TOKENIZER(groups, ";")
str=toks:next()
while str ~= nil
do
	if group_configs[str] == nil then return str end
	if group_configs[str].ignore == false then return str end

str=toks:next()
end

return nil
end






function LoadDesktopFile(path)
local S, str, toks, invoke, exec, run_dir, app, categories

S=stream.STREAM(path, "r")
if S ~= nil
then
	app=NewApp("desktop", "", "")
	str=S:readln()

	while str ~= nil
	do
	toks=strutil.TOKENIZER(strutil.stripTrailingWhitespace(str), "=")
	key=toks:next()
	value=strutil.stripQuotes(toks:remaining())

	strutil.trim(key)
	strutil.trim(value)
	if key=="Name" then app.name=value
	elseif key=="Icon" then app.icon=value
	elseif key=="Path" then run_dir=value
	elseif key=="Exec" then exec=value
	elseif key=="Categories" then categories=value
	end

	str=S:readln()
	end
	S:close()


	if strutil.strlen(exec) < 1 then return end


	--desktop files can specify a 'filename' argument using %f. As we are building menus for window managers
	--that don't understand this, we pass an empty string for this value to get rid of it
	app.exec=string.gsub(exec, "%%f","")
	
	app.group=AppChooseGroup(app.name, categories)

	--once both app.name, app.group and app.exec are sorted, we can check overrides	
	ProcessAppOverrides(app)

	--if app has ignore set, then do nothing
	if app.ignore==true then return end
	if app_configs[exec] ~= nil and app_configs[exec].ignore == true then return end


	value=string.lower(app.name)
	if app_configs[value] == nil 
	then
		app_configs[value]=app
	else
		if app_configs[value].ignore == true then return end
	end


	if strutil.strlen(run_dir) > 0
	then
		app.invoke="cd '" .. run_dir .. "'; " .. app.exec
	else
			app.invoke=app.exec
	end

	MenuAddItem(app.group, app)

end

end



function LoadDesktopFiles(path)
local files, item, str

str=path.."/share/applications/*.desktop"
files=filesys.GLOB(str)
item=files:next()
while item ~= nil
do
LoadDesktopFile(item)
item=files:next()
end

end


