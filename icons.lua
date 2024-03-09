--[[
--  ICON FIND FUNCS  ***************************************************
]]--

function IconFind(srcname, path)
local str, i, extn, name

if settings.find_icons == false then return end
if strutil.strlen(srcname) < 1 then return(nil) end

name=string.lower(srcname)
if icon_cache[name] ~=nil 
then
	return icon_cache[name] 
end

return nil
end	



function IconFindFromList(icon_list)
local toks, name, icon


if settings.find_icons == false then return end
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


function IconsLoad(path)
local toks, dir

if settings.find_icons == false then return end

toks=strutil.TOKENIZER(path, ":")
dir=toks:next()
while dir ~= nil
do
	files=filesys.GLOB(dir.."*.[jJpP]*[gG]")
	file=files:next()
	while file ~= nil
	do
		extn=string.lower(filesys.extn(file))
		if extn==".jpg" or extn==".jpeg" or extn==".png"
		then
			name=filesys.basename(file)
			name=string.sub(name, 1, string.len(name)-string.len(extn))
			name=string.lower(name)
			if icon_cache[name] == nil then icon_cache[name]=file end
		end
		file=files:next()
	end
	dir=toks:next()
end

end


function AppIconFind(app, path)
local icon, conf

if settings.find_icons == false then return nil end
if strutil.strlen(app.icon) > 0 and filesys.exists(app.icon) == true then return app.icon end

icon=IconFind(app.icon, path)
if icon ~= nil then return icon end

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



