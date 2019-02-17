require("filesys")
require("stream")
require("process")
require("strutil")
require("dataparser")



settings={}
group_configs={}
app_configs={}
menu_config={}
faves_config={}
overrides_config={}
icon_cache={}


function Capitalize(str)
local retstr

retstr=string.upper(string.sub(str, 1, 1))
retstr=retstr .. string.sub(str, 2)

return retstr
end


function ProcessAppOverrides(app)
local name, config

config=overrides_config[app.exec]
if config ~= nil 
then
	if strutil.strlen(config.group) > 0 then app.group=config.group end
	if strutil.strlen(config.name) > 0 then app.name=config.name end
	if strutil.strlen(config.icon) > 0 then app.icon=config.icon end
end

end



function MenuAddGroup(group)
local conf, parent

if strutil.strlen(group) ==0 then return nil end
conf=group_configs[group]

if conf ~=nil and conf.parent ~=nil
then
	parent=MenuAddGroup(conf.parent)
else
	parent=menu_config
end

	if parent[group] == nil 
	then 
		parent[group]={} 
		parent[group].type="group"
		parent[group].name=group
--		parent[group].size=0
	end

return parent[group]
end

function MenuAddItem(menu_name, item)
local group

group=MenuAddGroup(menu_name)
table.insert(group, item)

end


function ProcessImpliedApps(implied_apps)
local toks, item, config


toks=strutil.TOKENIZER(implied_apps, ",")
item=toks:next()
while item ~= nil
do
config=app_configs[item]
if config ~= nil and config.group ~=nil then MenuAddItem(config.group, config) end
item=toks:next()
end

end



--[[
--  ICON FIND FUNCS  ***************************************************
--
]]--

function IconFind(name, path)
local extn_list={".PNG",".png",".JPG",".jpg",".JPEG",".jpeg"}
local str, i, extn

if strutil.strlen(name) < 1 then return("") end
if icon_cache[name] ~=nil then return icon_cache[name] end

for i,extn in ipairs(extn_list)
do
	str=filesys.find(name..extn, path)
	if strutil.strlen(str) > 0 
	then 
			icon_cache[name]=str
			return str 
	end

	str=filesys.find(string.lower(name)..extn, path)
	if strutil.strlen(str) > 0 
	then 
		icon_cache[name]=str
		return str 
	end
end

return nil
end	



function IconFindFromList(icon_list)
local toks, name, icon

toks=strutil.TOKENIZER(icon_list, ",")
name=toks:next()
while name ~= nil
do
	icon=IconFind(name, settings.icon_path)
	if icon ~=nil then return icon end

	name=toks:next()
end

return nil
end



function GroupInfoFind(group)
local conf, name 
local icon=nil

conf=group_configs[group.name]
if conf ~= nil 
then
	if strutil.strlen(conf.name) > 0 then name=conf.name end
	if settings.find_icons == true
	then
		if strutil.strlen(conf.icons) > 0 then conf.icon=IconFindFromList(conf.icons) end
		if conf.icon ~= nil then icon=conf.icon end
	end
end

if name == nil then name=group.name end
if icon == nil
then
	if settings.find_icons == true 
	then 
		icon=IconFindFromList("folder") 
	else
		icon=""
	end
end

return name, icon
end



function AppIconFind(app, path)
local icon, conf

if settings.find_icons == false then return nil end
if strutil.strlen(app.icon) > 0 and filesystem.exists(app.icon) then return app.icon end

icon=IconFind(app.exec, path)
if icon ~= nil then return icon end

icon=IconFind(app.name, path)
if icon ~= nil then return icon end

icon=IconFindFromList(app.icons)
if icon ~= nil then return icon end

icon=IconFindFromList(app.groups)
if icon ~= nil then return icon end

conf=group_configs[app.group]
if conf ~= nil and conf.icon ~= nil then return conf.icon end

return nil
end




--[[
--  GENERATE QUERIES USING XDIALOG, ZENITY, QARMA, etc  ***************************************************
--
]]--


function DialogApp(basename)

if basename=="xdialog"
then
	settings.query=basename.." --inputbox '$title'"
elseif basename=="zenity"
then
	settings.query=basename.." --entry --title '$title'"
	settings.fileselect=basename.." --file-selection --multiple --title '$title'"
elseif basename=="qarma"
then
	settings.query=basename.." --entry --title '$title'"
	settings.fileselect=basename.." --file-selection --multiple --title '$title' --file-filter '$filter'"
else io.stderr:write("ERROR: Dialog system '"..basename.."' unknown.")
end

end


function QueryGenerate(app)
local str
local	title=""

	if strutil.strlen(app.query_title) > 0 then title=app.query_title end
	str=string.gsub(settings.query, "%$title", title)

	return "/bin/sh -c \"".. app.invoke .. " `" .. str .. "`\""
end



function FileSelectGenerate(app) 
	local str
	local title=""
	local filter="*"

	if strutil.strlen(app.query_title) > 0 then title=app.query_title end
	str=string.gsub(settings.fileselect, "%$title", title)
	if strutil.strlen(app.query_filter) > 0 then filter=app.query_filter end
	str=string.gsub(str, "%$filter", filter)

	return "/bin/sh -c \"".. app.invoke .. " `" .. str .. "`\""
end





--[[
--  CONFIG FILE FUNCS ***************************************************
--
]]--

-- load config for an application from details found in the main config file
function LoadAppConfig(config)
local group, toks, name, value
local app={}

app.type="app"
app.name=""
app.termapp=false
app.query=false
app.fileselect=false
app.exec=config:next()

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
local name, str

name=config:next()
if group_configs[name]==nil then group_configs[name]={} end

str=config:next()
while str~=nil
do
	if string.sub(str, 1, 6)=="icons=" then group_configs[name].icons=strutil.stripQuotes(string.sub(str,7)) end
	if string.sub(str, 1, 6)=="title=" then group_configs[name].name=strutil.stripQuotes(string.sub(str,7)) end
	if string.sub(str, 1, 7)=="parent=" then group_configs[name].parent=strutil.stripQuotes(string.sub(str,8)) end
	str=config:next()
end

end



function LoadConfig()
local S, str, app, entry_type
local toks, item

toks=strutil.TOKENIZER(settings.config, ":")
if toks==nil then return end

item=toks:next()
while item ~= nil
do
	
	S=stream.STREAM(item, "r")
	if S ~= nil then break end
	io.stderr:write( "config file: '"..item.."' ... not found\n")
	item=toks:next()
end


if S ~= nil
then
	io.stderr:write( "config file: '"..item.."' ... opened successfully\n")
	str=S:readln()
	while str~= nil
	do
		str=strutil.stripTrailingWhitespace(str)
		if strutil.strlen(str) > 0
		then
			toks=strutil.TOKENIZER(str, " ", "Q")
			entry_type=toks:next()
			if entry_type=="group"
			then
				LoadGroupConfig(toks)
			elseif entry_type=="override"
			then
				app=LoadAppConfig(toks)
				if app ~= nil then overrides_config[app.exec]=app end
			elseif entry_type=="app"
			then
				app=LoadAppConfig(toks)
				if app ~= nil
				then
					if strutil.strlen(app.group) ==0 then io.stderr:write( "ERROR: No group for app: "..str.."\n") end
					app_configs[app.exec]=app
				end
			end
		end
	
		str=S:readln()
	end
S:close()
end

end



--[[
--  DESKTOP FILES  ***************************************
--
]]--


function AddFromDesktopFile(config, invoke)
local app={}
local group, toks, str

group=strutil.stripQuotes(config:value("Category"))
if strutil.strlen(group)==0
then
	str=strutil.stripQuotes(config:value("Categories"))
	if str ~= nil 
	then 
		toks=strutil.TOKENIZER(str, ",")
		group=toks:next()
	end
end

if group ~=nil
then
	app.type="app"
	app.name=strutil.stripQuotes(config:value("Name"))
	app.exec=app.name
	app.icon=strutil.stripQuotes(config:value("Icon"))

	app.invoke=invoke
	app.group=group

	ProcessAppOverrides(app)
	MenuAddItem(app.group, app)
	end
end



function LoadDesktopFile(path)
local S, str, toks, invoke, exec, config

S=stream.STREAM(path)
if S ~= nil
then
	str=S:readdoc()
	config=dataparser.PARSER("config", str)
	if config
	then
	invoke=strutil.stripQuotes(config:value("Exec"))
	toks=strutil.TOKENIZER(invoke, " ")
	exec=toks:next()

	if strutil.strlen(exec) >0
	then
	AddFromDesktopFile(config, invoke)
	end

	end

	S:close()
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



function OpenOutputFile(Path)
local S

-- don't try to rename stdout!
if Path ~= "-" then filesys.rename(Path, Path.."-") end


S=stream.STREAM(Path, "w")
if S==nil
then
	io.stderr:write( "ERROR: Failed to open output '"..Path.."'\n")
else
	io.stderr:write( "writing to: "..Path.."\n")
end

return(S)
end



--[[
-- BLACKBOX/FLUXBOX/OPENBOX/HACKEDBOX  ***************************************
--
]]--


function Blackbox_ItemWrite(S, item)

	if item.type=="group" 
	then 
		Blackbox_SubmenuWrite(S, item.name, item)
	elseif item.invoke ~= nil then S:writeln("[exec] (" .. item.name.. ") {" .. item.invoke.."}\n") 
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
	S:writeln("[begin] (Blackbox_)\n")
	if #faves_config > 0
	then
	Blackbox_ItemsWrite(S, faves_config)
	S:writeln("[separator]\n")
	end


	Blackbox_ItemsWrite(S, menu)

	S:writeln("[separator]\n")
	S:writeln("[reconfig] (Reconfigure)\n")
	S:writeln("[restart] (Restart)\n")
	S:writeln("[exit] (Exit)\n")
	S:writeln("[end]\n")

	S:close()
end

end





--[[
-- ICEWM  ***************************************
--
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

filesys.mkdirPath(Path)
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
end

end





--[[
-- JWM  ***************************************
--
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
end

end




--[[
-- PEKWM  ***************************************
--
]]--


function PekWM_ItemsWrite(S, group)
local name, value, icon

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
local conf, name,icon

S:writeln("  Submenu = \"" .. group.name .."\" {\n")
PekWM_ItemsWrite(S, group)
S:writeln("  }\n")
end



function PekWM_MenuWrite(menu, Path)
local i, item, S

S=OpenOutputFile(Path)
if S ~= nil
then

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

S:close()
end

end



--[[
-- MLVWM  ***************************************
--
]]--


function MLVWM_ItemsWrite(S, group)
local conf, name, item

for name,item in pairs(group)
do
	if item.type=="group"
	then
		S:writeln("  \""..item.name.. "\" SubMenu " .. string.gsub(item.name, " ", "_").. "\n")
	elseif item.invoke ~= nil 
	then 
			S:writeln(" \"".. item.name .. "\" Action Exec \"" ..item.name .. "\" exec " .. item.invoke .. "\n")
	end
end
end


function MLVWM_SubmenuWrite(S, group)
local name, item

-- First go through and write out all the submenus
for name,item in pairs(group)
do
	if item.type=="group" then MLVWM_SubmenuWrite(S, item) end
end


S:writeln("Menu " .. string.gsub(group.name, " ", "_") .. ", Label \"" .. group.name .. "\"\n")

if group.name=="RootMenu" and #faves_config > 0
then
	MLVWM_ItemsWrite(S, faves_config)
	S:writeln("\"\" NonSelect\n")
end


MLVWM_ItemsWrite(S, group)

if group.name == "RootMenu"
then
	S:writeln("\"\" NonSelect\n")
	S:writeln("\"Restart\" Action Restart mlvwm\n")
	S:writeln("\"Exit\" Action Exit\n")
end

S:writeln("END\n\n")
end



function MLVWM_MenuWrite(menu, Path)
local i, item, S

S=OpenOutputFile(Path)
if S ~= nil
then
	MLVWM_SubmenuWrite(S, menu)
	S:close()
end

end


--[[
-- MWM (Motif Window Manager) ***************************************
--
]]--


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



function OutputWindowManagerFiles()
local toks, item

toks=strutil.TOKENIZER(settings.output, ",")
item=toks:next()
while item ~= nil
do
io.stderr:write( "output: " .. item.."\n")
		if item=="blackbox" 
		then
			Blackbox_MenuWrite(sorted, process.getenv("HOME") .. "/.blackbox/menu")
		elseif item=="fluxbox" 
		then
			Blackbox_MenuWrite(sorted, process.getenv("HOME") .. "/.fluxbox/menu")
		elseif item=="icewm" 
		then
			IceWM_MenuWrite(sorted, process.getenv("HOME").."/.icewm/menu")
		elseif item=="jwm" 
		then
			JWM_MenuWrite(sorted, process.getenv("HOME").."/.menu.jwm")
		elseif item=="pekwm" 
		then
			PekWM_MenuWrite(sorted, process.getenv("HOME").."/.pekwm/menu")
		elseif item=="mlvwm" 
		then
			MLVWM_MenuWrite(sorted, process.getenv("HOME").."/.menu.mlvwm")
		elseif item=="twm" or item=="vtwm" or item=="ctwm"
		then
			TWM_MenuWrite(sorted, process.getenv("HOME").."/.menu."..item)
		elseif item=="stdout:blackbox" or item=="stdout:fluxbox" then Blackbox_MenuWrite(sorted, "-")
		elseif item=="stdout:icewm" then IceWM_MenuWrite(sorted, "-")
		elseif item=="stdout:pekwm" then PekWM_MenuWrite(sorted, "-")
		elseif item=="stdout:jwm" then JWM_MenuWrite(sorted, "-")
		elseif item=="stdout:twm" then TWM_MenuWrite(sorted, "-")
		elseif item=="stdout:vtwm" then TWM_MenuWrite(sorted, "-")
		elseif item=="stdout:ctwm" then TWM_MenuWrite(sorted, "-")
		end

item=toks:next()
end

end




function SelectFaves(faves)
local toks, item

toks=strutil.TOKENIZER(faves, ",")
item=toks:next()
while item
do
	if app_configs[item] ~= nil then table.insert(faves_config, app_configs[item]) end
	item=toks:next()
end

end


function SortMenuCompare(m1, m2)
if m1.type=="group" and m2.type=="app" then return true end
if m1.type=="app" and m2.type=="group" then return false end

return m1.name < m2.name
end


function SortMenu(unsorted)
local sorted={}
local name, item

if unsorted.type==nil then return unsorted end

sorted.name=unsorted.name
sorted.type=unsorted.type
for name,item in pairs(unsorted)
do
	if item.type ~= nil
	then
		if item.type=="group" 
		then 
			item=SortMenu(item) 
		end
		table.insert(sorted, item)
	end
end

table.sort(sorted, SortMenuCompare)
return sorted
end




function IconPathAdd(prefix)
subdirs={"64x64","48x48","32x32"}

settings.icon_path=settings.icon_path..prefix.."/share/icons:"
for i,sub in ipairs(subdirs)
do
settings.icon_path=settings.icon_path .. prefix.. "/share/icons/hicolor/" ..sub .."/apps/:"
settings.icon_path=settings.icon_path .. prefix.. "/share/icons/hicolor/" ..sub .."/places/:"
settings.icon_path=settings.icon_path .. prefix.. "/share/icons/hicolor/" ..sub .."/devices/:"
end

end



--scan a directory for applications
function ScanDir(dir)
local config, files, curr

files=filesys.GLOB(dir.."/*")
curr=files:next()
while curr ~= nil
do
	--does the application exist in the list of applications loaded from the config file?
	config=app_configs[filesys.basename(curr)]
	if config ~= nil and config.group ~=nil
	then
		-- is it a dialog app, like XDialog, Zenity or Qarma? If so then add it to the dialog_apps table
		if config.group == "DialogApp"
		then
			--do nothing for now, one day we hope to automagically find qarma, zenity, xdialog etc
		else
			--it's a normal app, so add it to it's menu group
		MenuAddItem(config.group, config)
		if config.implies ~= nil then ProcessImpliedApps(config.implies) end
		end
	end

	curr=files:next()
end

end


function ScanDirectoriesInPath()
local toks, dir, prefix, PATH

PATH=process.getenv("PATH")
toks=strutil.TOKENIZER(PATH,":")
dir=toks:next()
while dir ~= nil
do
	ScanDir(dir)
	prefix=string.gsub(dir, "/bin$", "")
	LoadDesktopFiles(prefix)
	IconPathAdd(prefix)

	dir=toks:next()
end
end


function ParseCommandLine(args)
for i,arg in ipairs(args)
do

if arg == "-c" 
then 
	settings.config_path=args[i+1]
	args[i+1]=""
elseif arg == "-faves" 
then 
	settings.faves=args[i+1]
	args[i+1]=""
elseif arg == "-icons" 
then
	settings.icon_path=settings.icon_path .. args[i+1] .. ":"
	args[i+1]=""
elseif arg == "-no-icons" 
then
	settings.find_icons=false
elseif arg== "-dialogs"
then
	DialogApp(args[i+1])
	args[i+1]=""
elseif arg=="-t" or arg=="-term"
then
	settings.term=args[i+1]
	args[i+1]=""
elseif arg=="all" then settings.output="jwm,twm,icewm,pekwm,mlvwm,blackbox,fluxbox"
else settings.output=settings.output .. args[i]
end

end

end








--[[

'main' starts here ***********************************

]]--


settings.config=process.getenv("HOME").."/.menubuilder.conf:/etc/menubuilder.conf"
settings.term="xterm"
settings.output=""
settings.find_icons=true
settings.icon_path=process.getenv("ICON_PATH")..":"

-- don't allow this to be nil, or we can't append to it
if settings.icon_path == nil then settings.icon_path="" end

menu_config.type="group"
menu_config.name="RootMenu"

ParseCommandLine(arg)

LoadConfig()
ScanDirectoriesInPath()

LoadDesktopFiles(process.getenv("HOME").."/.local/")
SelectFaves(settings.faves)
sorted=SortMenu(menu_config)

if settings.output=="" 
then 
	io.stderr:write( "ERROR: no output specified.\n")
else
	OutputWindowManagerFiles()
end


