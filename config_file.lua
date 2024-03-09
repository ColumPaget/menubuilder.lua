--[[
--  CONFIG FILE FUNCS ***************************************************
]]--




function Capitalize(str)
local retstr

retstr=string.upper(string.sub(str, 1, 1))
retstr=retstr .. string.sub(str, 2)

return retstr
end


-- load config for an application from details found in the main config file
function LoadAppConfig(config)
local group, toks, name, value, app

app=NewApp("menubuilder", "", config:next())
str=config:next()
while str ~= nil
do
str=strutil.stripTrailingWhitespace(str)
toks=strutil.TOKENIZER(str, "=")
name=toks:next()
value=toks:remaining()

if name=="term" then app.termapp=true
elseif name=="termapp" then app.termapp=true
elseif name=="fileapp" then app.fileselect=true
elseif name=="query" then app.query=true
elseif name=="group" then app.groups=strutil.stripQuotes(value)
elseif name=="icon" then app.icons=strutil.stripQuotes(value)
elseif name=="title" then app.name=strutil.stripQuotes(value)
elseif name=="invoke" then app.invoke=strutil.stripQuotes(value)
elseif name=="implies" then app.implies=strutil.stripQuotes(value)
elseif name=="ignore" then app.ignore=true
elseif name=="query:title" then app.query_title=strutil.stripQuotes(value)
elseif name=="query:filter" then app.query_filter=strutil.stripQuotes(value)
end

str=config:next()
end

if strutil.strlen(app.name) ==0 then app.name=Capitalize(app.exec) end
if strutil.strlen(app.invoke) ==0 then app.invoke=app.exec end


if app.query == true 
then 
	-- if we don't have qarma or zenity to do queries with, then don't include this app
	if strutil.strlen(settings.query) == 0 then return nil end
	app.invoke=QueryGenerate(app) 
end

if app.fileselect == true 
then 
	-- if we don't have qarma or zenity to do queries with, then don't include this app
	if strutil.strlen(settings.fileselect) == 0 then return nil end

	app.invoke=FileSelectGenerate(app) 
end


if app.termapp == true then app.invoke=settings.term.. " -e "..app.invoke end


if strutil.strlen(app.invoke) ~= 0 
then 
toks=strutil.TOKENIZER(app.groups,",")
group=toks:next()
while group ~=nil
do
	if group=="faves"
	then
		table.insert(faves_config, app)
	else
		app.group=group
	end
group=toks:next()
end
end

ProcessAppOverrides(app)
return app
end


function LoadGroupConfig(config)
local name, str, group

name=config:next()
group=NewGroup(name)
str=config:next()
while str ~= nil
do
	if string.sub(str, 1, 6)=="icons=" then group_configs[name].icons=strutil.stripQuotes(string.sub(str,7)) 
	elseif string.sub(str, 1, 6)=="title=" then group_configs[name].name=strutil.stripQuotes(string.sub(str,7)) 
	elseif string.sub(str, 1, 7)=="parent=" then group_configs[name].parent=strutil.stripQuotes(string.sub(str,8))
	elseif str=="ignore" then group.ignore=true
	end

	str=config:next()
end

end


function LoadIgnoreGroups(groups)
local toks, name, group

toks=strutil.TOKENIZER(groups, ",")
name=toks:next()
while name ~= nil
do
	group=NewGroup(name)
	group.ignore=true
	name=toks:next()
end
end


function LoadIgnoreApps(apps)
local toks, name, group

toks=strutil.TOKENIZER(apps, ",")
name=toks:next()
while name ~= nil
do
	if overrides_config[name]==nil then overrides_config[name]={} end
	overrides_config[name].ignore=true
	name=toks:next()
end
end


function LoadOverrides(app_config)
local app, toks

	app=LoadAppConfig(app_config)
	if app ~= nil 
	then 
		--Overrides have one difference from normal app configs, that multiple app names
		--can be specified seperated by commas. Thus we can apply the same override to many apps
		toks=strutil.TOKENIZER(app.exec, ",")
		str=toks:next()
		while str ~= nil
		do
		overrides_config[str]=app 
		str=toks:next()
		end

	end
end


function AppAdd(app)
local name, config

	name=string.lower(app.exec)
	if strutil.strlen(app.group) ==0 then io.stderr:write( "ERROR: No group for app: "..str.."\n") end

	config=app_configs[name]
	if config == nil
	then
		app_configs[name]=app
	end
end


function ConfigFileRead(path)
local S, str, toks, entry_type, app
local result=false

S=stream.STREAM(path, "r")
if S ~= nil
then
	io.stderr:write( "config file: '".. path .."' ... opened successfully\n")
	str=S:readln()
	while str~= nil
	do
		result=true
		str=strutil.stripTrailingWhitespace(str)
		if strutil.strlen(str) > 0
		then
			toks=strutil.TOKENIZER(str, " ", "Q")
			entry_type=toks:next()
			if entry_type=="group"
			then
				LoadGroupConfig(toks)
			elseif entry_type=="ignore-groups"
			then
				LoadIgnoreGroups(toks:remaining())
			elseif entry_type=="ignore-apps"
			then
				LoadIgnoreApps(toks:remaining())
			elseif entry_type=="override"
			then
				LoadOverrides(toks)
			elseif entry_type=="app"
			then
				app=LoadAppConfig(toks)
				if app ~= nil then AppAdd(app) end
			end
		end
	
		str=S:readln()
	end
S:close()
end

return result
end



function LoadConfig()
local toks, item, files, i, path
local result=false

toks=strutil.TOKENIZER(settings.config, ":")
if toks==nil then return end

item=toks:next()
while item ~= nil
do
	files=filesys.GLOB(item)
	path=files:next()
	while path ~= nil
	do
	result=ConfigFileRead(path)
	path=files:next()
	end
	
	if result==true then break
  else io.stderr:write( "config file: '"..item.."' ... not found\n")
	end

	item=toks:next()
end

end


