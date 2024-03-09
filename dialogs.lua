
--[[
--  GENERATE QUERIES USING XDIALOG, ZENITY, QARMA, etc  ***************************************************
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



