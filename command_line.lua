function DisplayHelp()

print("usage:")
print("")
print(" lua menubuilder.lua [options] [window manager] [window manager] ...")
print("")

print("options:")
print("")

print("  -c                 path to config file, if not supplied then '~/.config/menubuilder/*.conf' will be tried, followed by, '~/.config/menubuilder.conf', and '~/.menubuilder.conf/etc/menubuilder.conf'")
print("  -faves [items]     a list of program names to include above everthing else on the top menu")
print("  -icons [path]      add a colon-separated list of paths under which to search for icons")
print("  -no-icons          do not find icons for the menu")
print("  -t [app]           terminal app to use for terminal programs, defaults to 'xterm'")
print("  -term [app]        terminal app to use for terminal programs, defaults to 'xterm'")
print("  -dialogs [app]     dialog app to use for programs that need additional info. Choices are 'xdialog', 'zenity' or 'qarma'. Defaults to 'no dialogs'. If no dialog app is set then entries for apps requring dialogs will not be added to the menu.")
print("  -misc [size]       Merge any top-level menus that contain less than <size> items into a single 'miscellaneous' top-level group.")
print("  -submenu [size]    For any groups that are not top-level and which contain less than <size> items, show the items in the parent group, rather than in a submenu.")

print("")

print("supported window managers:")
print("Multiple 'window manager' arguments can be supplied and can contain the following values:")
print("")
print("   all                this will write out menu files for all supported window managers")
print("   blackbox           write to file ~/.blackbox/menu")
print("   fluxbox            write to file ~/.fluxbox/menu")
print("   openbox            write to file ~/.config/openbox/menu.xml")
print("   icewm              write to file ~/.icewm/menu")
print("   pekwm              write to file ~/.pekwm/menu")
print("   mlvwm              write to file ~/.menu.mlvwm")
print("   pwm                write to file ~/.pwm/rootmenu.conf")
print("   jwm                write to file ~/.menu.jwm")
print("   twm                write to file ~/.menu.twm")
print("   ctwm               write to file ~/.menu.ctwm")
print("   vtwm               write to file ~/.menu.vtwm")
print("   moonwm             write to file ~/.config/moonwm/favorites")
print("   xmenu              write to file ~/.menu.xmenu")
print("   ctrlmenu           write to file ~/.menu.ctrlmenu")
print(" ")
print("   stdout:blackbox    write blackbox menu to stdout")
print("   stdout:fluxbox     write fluxbox menu to stdout")
print("   stdout:openbox     write fluxbox menu to stdout")
print("   stdout:icewm       write icewm menu to stdout")
print("   stdout:pekwm       write pekwm menu to stdout")
print("   stdout:mlvwm       write mlvwm menu to stdout")
print("   stdout:pwm         write pwm menu to stdout")
print("   stdout:jwm         write jwm menu to stdout")
print("   stdout:twm         write twm menu to stdout")
print("   stdout:ctwm        write ctwm menu to stdout")
print("   stdout:vtwm        write vtwm menu to stdout")
print("   stdout:moonwm      write moonwm menu to stdout")
print("   stdout:xmenu       write xmenu menu to stdout")
print("   stdout:ctrlmenu    write ctrlmenu menu to stdout")
print("")

print("example:")
print("")
print("  MenuBuilder.lua -faves xterm,links,smplayer jwm icewm")


end



function ParseCommandLine(args)
for i,arg in ipairs(args)
do

if arg == "-c" 
then 
	settings.config=args[i+1]
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
elseif arg == "-s" or arg == "-submenu"
then
	settings.submenu_size=tonumber(args[i+1])
	if settings.submenu_size==nil then settings.submenu_size=0 end
	args[i+1]=""
elseif arg == "-m" or arg == "-misc"
then
	settings.misc_group=tonumber(args[i+1])
	if settings.misc_group==nil then settings.misc_group=0 end
	args[i+1]=""
elseif arg== "-dialogs"
then
	DialogApp(args[i+1])
	args[i+1]=""
elseif arg=="-t" or arg=="-term"
then
	settings.term=args[i+1]
	args[i+1]=""
elseif arg=="-?" or arg=="-h" or arg=="-help" or arg=="--help"
then
	DisplayHelp()
	os.exit(0)
elseif arg=="all" then settings.output="jwm,twm,vtwm,ctwm,pwm,icewm,pekwm,mlvwm,blackbox,fluxbox,openbox,moonwm,xmenu,ctrlmenu"
else settings.output=settings.output .. args[i]..","
end

end

end




