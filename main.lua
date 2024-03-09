


function ProcessAppOverrides(app)
local name, config, item

config=overrides_config[app.name]
if config == nil then config=overrides_config[app.exec] end
if config == nil
then 
  for name,item in pairs(overrides_config)
  do
		if strutil.pmatch(name, app.name) == true
		then
			config=item
		end
  end
end


if config ~= nil 
then
	if strutil.strlen(config.group) > 0 then app.group=config.group end
	if strutil.strlen(config.icon) > 0 then app.icon=config.icon end
	if config.termapp == true then app.termapp=true end
	if config.ignore == true then app.ignore=true end
	if config.query == true then app.query=true end
end

end



function NewApp(source, name, exec)
local app={}

app.type="app"
app.name=name
app.termapp=false
app.ignore=false
app.query=false
app.fileselect=false
app.source=source
app.exec=exec

return app
end


function NewGroup(name)
if group_configs[name]==nil 
then 
	group_configs[name]={} 
	group_configs[name].ignore=false
	group_configs[name].icons=""
end

return group_configs[name]
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
if group ~= nil then table.insert(group, item) end

end


function ProcessImpliedApps(implied_apps)
local toks, item, config


toks=strutil.TOKENIZER(implied_apps, ",")
item=toks:next()
while item ~= nil
do
	config=app_configs[string.lower(item)]
	if config ~= nil and config.group ~=nil then MenuAddItem(config.group, config) end
	item=toks:next()
end

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















function OpenOutputFile(Path)
local S

-- don't try to create or rename stdout!
if Path ~= "-" 
then 
	filesys.mkdirPath(Path)
	filesys.rename(Path, Path.."-")
end

S=stream.STREAM(Path, "w")
if S==nil
then
	io.stderr:write( "ERROR: Failed to open output '"..Path.."'\n")
else
	io.stderr:write( "writing to: "..Path.."\n")
end

return(S)
end








function OutputWindowManagerFiles()
local toks, item

toks=strutil.TOKENIZER(settings.output, ",")
item=toks:next()
while item ~= nil
do
if strutil.strlen(item) > 0
then
		io.stderr:write( "output: " .. item.."\n")
		if item=="blackbox" 
		then
			Blackbox_MenuWrite(sorted, process.getenv("HOME") .. "/.blackbox/menu")
		elseif item=="fluxbox" 
		then
			Blackbox_MenuWrite(sorted, process.getenv("HOME") .. "/.fluxbox/menu")
		elseif item=="openbox"
		then
			Openbox_MenuWrite(sorted, process.getenv("HOME") .. "/.config/openbox/menu.xml")
		elseif item=="icewm" 
		then
			IceWM_MenuWrite(sorted, process.getenv("HOME").."/.icewm/menu")
		elseif item=="jwm" 
		then
			JWM_MenuWrite(sorted, process.getenv("HOME").."/.menu.jwm")
		elseif item=="fvwm" 
		then
			FVWM_MenuWrite(sorted, process.getenv("HOME").."/.fvwm/fvwm.menu")
		elseif item=="pekwm" 
		then
			PekWM_MenuWrite(sorted, process.getenv("HOME").."/.pekwm/menu")
		elseif item=="pwm" 
		then
			PWM_MenuWrite(sorted, process.getenv("HOME").."/.pwm/rootmenu.conf")
		elseif item=="mlvwm" 
		then
			MLVWM_MenuWrite(sorted, process.getenv("HOME").."/.menu.mlvwm")
		elseif item=="twm" or item=="vtwm" or item=="ctwm" or item=="mwm"
		then
			TWM_MenuWrite(sorted, process.getenv("HOME").."/.menu."..item)
		elseif item=="moonwm" 
		then
			XMenu_MenuWrite(sorted, process.getenv("HOME").."/.config/moonwm/favorites.xmenu")
		elseif item=="xmenu" 
		then
			XMenu_MenuWrite(sorted, process.getenv("HOME").."/.xmenu.menu")
		elseif item=="ctrlmenu" 
		then
			CtrlMenu_MenuWrite(sorted, process.getenv("HOME").."/.ctrlmenu.menu")
		elseif item=="stdout:blackbox" or item=="stdout:fluxbox" then Blackbox_MenuWrite(sorted, "-")
		elseif item=="stdout:icewm" then IceWM_MenuWrite(sorted, "-")
		elseif item=="stdout:pekwm" then PekWM_MenuWrite(sorted, "-")
		elseif item=="stdout:jwm" then JWM_MenuWrite(sorted, "-")
		elseif item=="stdout:fvwm" then FVWM_MenuWrite(sorted, "-")
		elseif item=="stdout:twm" then TWM_MenuWrite(sorted, "-")
		elseif item=="stdout:vtwm" then TWM_MenuWrite(sorted, "-")
		elseif item=="stdout:ctwm" then TWM_MenuWrite(sorted, "-")
		elseif item=="stdout:moonwm" then XMenu_MenuWrite(sorted, "-")
		elseif item=="stdout:xmenu" then XMenu_MenuWrite(sorted, "-")
		elseif item=="stdout:ctrlmenu" then CtrlMenu_MenuWrite(sorted, "-")
		end
end

item=toks:next()
end

end




function SelectFaves(faves)
local toks, item, name

toks=strutil.TOKENIZER(faves, ",")
item=toks:next()
while item
do
  name=string.lower(item)
	if app_configs[name] ~= nil then table.insert(faves_config, app_configs[name]) end
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
local fslist, dir
local subdirs={"128x128","64x64","48x48","32x32", "16x16"}

settings.icon_path=settings.icon_path..prefix.."/share/icons:"
settings.icon_path=settings.icon_path .. prefix.. "/share/pixmaps/:"

fslist=filesys.GLOB(prefix.."/share/icons/*")
dir=fslist:next()
while dir ~= nil
do
	if fslist:info().type == "directory"
	then						
	for i,sub in ipairs(subdirs)
	do
		settings.icon_path=settings.icon_path .. dir .. "/" .. sub .."/:"
		settings.icon_path=settings.icon_path .. dir .. "/" .. sub .."/apps/:"
		settings.icon_path=settings.icon_path .. dir .. "/" .. sub .."/places/:"
		settings.icon_path=settings.icon_path .. dir .. "/" .. sub .."/devices/:"
	end
	end
dir=fslist:next()
end

end



--scan a directory for applications
function ScanDir(dir)
local config, files, curr, name

files=filesys.GLOB(dir.."/*")
curr=files:next()
while curr ~= nil
do
	--does the application exist in the list of applications loaded from the config file?
	name=string.lower(filesys.basename(curr))
	config=app_configs[name]
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

function CopyGroup(in_group, out_group)
local name, item

for i,item in ipairs(in_group)
do
	if item.type ~= nil
	then
		table.insert(out_group, item)
	end
end

end


--parent is the group that items will be moved to if
--this group is too small. For top level items this will
--either be the 'Misc' group, or it could be nil
function PostProcessGroup(parent, group, min_size)
local name, item

	--first go through subitems of this group, possibly moving stuff out of them into this group
	for name,item in pairs(group)
	do
		if item.type=="group"
		then
			if PostProcessGroup(group, item, settings.submenu_size) == false then group[name]=nil end
		end

	end

	--if parent is nil then don't try moving/deleting this group, otherwise, if the group is too
	--small, move it into the parent
	if parent ~= nil and #group < min_size
	then
			CopyGroup(group, parent)

	-- we don't try to delete the group from the parent here,
	-- because the parent is the group we are moving things to, which
	-- is not always the real parent of the group we are considering
	-- so we return false, and let calling function delete the group
			return false
	end

	return true
end


function PostProcessItems()
local name, item, misc

-- create misc group if needed, else leave as nil
if settings.misc_group > 0 
then 
misc={} 
misc.type="group"
misc.name="Misc"
end


for name,item in pairs(menu_config)
do
	if item.type=="group"
	then
	if PostProcessGroup(misc, item, settings.misc_group) == false then menu_config[name]=nil end
	end
end

--if we created a misc group, and it has items in it, then add it to the menu
if misc ~= nil and #misc > 0 then table.insert(menu_config, misc) end
end










--[[

'main' starts here ***********************************

]]--


settings.config = process.getenv("HOME") .. "/.config/menubuilder.conf"
settings.config = settings.config .. ":" .. process.getenv("HOME") .. "/.config/menubuilder/*.conf"
settings.config = settings.config .. ":" .. process.getenv("HOME") .. "/.menubuilder.conf"
settings.config = settings.config .. ":/etc/menubuilder.conf"
settings.term="xterm"
settings.output=""
settings.find_icons=true
settings.icon_path=process.getenv("ICON_PATH")
settings.submenu_size=0
settings.misc_group=0

if settings.icon_path==nil 
then 
	settings.icon_path="" 
else
	settings.icon_path=settings.icon_path..":"
end

-- don't allow this to be nil, or we can't append to it
if settings.icon_path == nil then settings.icon_path="" end

menu_config.type="group"
menu_config.name="RootMenu"

ParseCommandLine(arg)

LoadConfig()
ScanDirectoriesInPath()
IconsLoad(settings.icon_path)

LoadDesktopFiles(process.getenv("HOME").."/.local/")
PostProcessItems()
SelectFaves(settings.faves)
sorted=SortMenu(menu_config)

if settings.output=="" 
then 
	io.stderr:write( "ERROR: no output specified.\n")
else
	OutputWindowManagerFiles()
end


