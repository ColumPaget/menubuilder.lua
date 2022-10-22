MenuBuilder.lua - root menu generation for window managers
----------------------------------------------------------

MenuBuilder can scan for installed applications and build root menus for a number of X11 window managers.  Icons are supported under jwm and icewm and MenuBuilder will use a number of heuristics to search for them. A special group 'faves' can be populated with will create a number of application options at the top of the menu. Terminal apps can be added to the list, with a specifiable terminal emulator to run them, and a dialog app like xdialog, zenity or qarma can be specified to add text or file select queries to applications that expect to be told a url or a list of files on startup.

MenuBuilder is specifically designed for indexing older applications that lack a .desktop file that describes them. However, it also uses .desktop files and is compatible with my 'Sommelier' app (https://github.com/ColumPaget/Sommelier) which installs windows apps for use with wine, and creates .desktop files for them. 
In addition to .desktop files, MenuBuilder uses a list of appplications from a supplied config file, 'MenuBuilder.conf'. This file is far from exhaustive, but it covers a lot of apps that I personally use. If you add to it, you could send the diff to colums.projects@gmail.com, and I'll add it to the distributed file. This file should either be installed as /etc/MenuBuilder.conf or in one's home directory as ~/.MenuBuilder.conf


Supported Window Managers
-------------------------

blackbox  https://github.com/bradleythughes/blackbox/
fluxbox   http://fluxbox.org/
openbox   http://openbox.org/
icewm     https://ice-wm.org/
pekwm     http://www.pekwm.org/
mlvwm     http://www2u.biglobe.ne.jp/~y-miyata/mlvwm.html
jwm       http://joewing.net/projects/jwm/
fvwm      https://www.fvwm.org/
pwm       https://tuomov.iki.fi/software/  https://github.com/Cougar/pwm
vtwm      http://www.vtwm.org/
ctwm      https://www.ctwm.org/index.html
moonwm    https://github.com/jzbor/moonwm
xmenu     https://github.com/phillbush/xmenu
ctrlmenu  https://github.com/phillbush/ctrlmenu
twm       


Requirements
------------

MenuBuilder.lua requires lua, libUseful (https://github.com/ColumPaget/libUseful) version 4.13 and above, and libUseful-lua (https://github.com/ColumPaget/libUseful-lua) version 2.9 and above to have been installed. Building libUseful-lua requires SWIG.

Installation
------------

an example config file is included that should be copied to "/etc/menubuilder.conf" or "~/.config/menubuilder.conf" or "~/.menubuilder.conf". menubuilder can then be run as a lua script with just "lua menubuilder.lua all". On linux the 'binfmt_misc' feature can be used to automatically run menubuilder without specifying the lua interpreter.

Usage
-----

```
	lua menubuilder.lua [options] [window manager] [window manager] ...
```

Options
-------

```
	-c                 path to config file, if not supplied then ~/.config/menubuilder.conf will be tried, followed by ~/.menubuilder.conf and finally /etc/menubuilder.conf
	-faves [items]     a list of program names to include above everthing else on the top menu 
	-icons [path]      add a colon-separated list of paths under which to search for icons
	-no-icons          do not find icons for the menu
	-t [app]           terminal app to use for terminal programs, defaults to 'xterm'
	-term [app]        terminal app to use for terminal programs, defaults to 'xterm'
	-dialogs [app]     dialog app to use for programs that need additional info. Choices are 'xdialog', 'zenity' or 'qarma'. Defaults to 'no dialogs'. If no dialog app is set then entries for apps requring dialogs will not be added to the menu.
	-misc [size]       Merge any top-level menus that contain less than <size> items into a single 'miscellaneous' top-level group.
	-submenu [size]    For any groups that are not top-level and which contain less than <size> items, show the items in the parent group, rather than in a submenu.

```
Multiple 'window manager' arguments can be supplied and can contain the following values:

```
	all                this will write out menu files for all supported window managers
	blackbox           write to file ~/.blackbox/menu
	fluxbox            write to file ~/.fluxbox/menu
	openbox            write to file ~/.config/openbox/menu.xml
	icewm              write to file ~/.icewm/menu
	pekwm              write to file ~/.pekwm/menu
	pwm                write to file ~/.pwm/rootmenu.conf
	jwm                write to file ~/.menu.jwm
	mlvwm              write to file ~/.menu.mlvwm
	twm                write to file ~/.menu.twm
	ctwm               write to file ~/.menu.ctwm
	vtwm               write to file ~/.menu.vtwm
	moonwm             write to file ~/.config/moonwm/favorites.xmenu
	xmenu              write to file ~/.menu.xmenu
	ctrlmenu           write to file ~/.menu.ctrlmenu
	
	stdout:blackbox    write blackbox menu to stdout
	stdout:fluxbox     write fluxbox menu to stdout
	stdout:openbox     write fluxbox menu to stdout
	stdout:icewm       write icewm menu to stdout
	stdout:pekwm       write pekwm menu to stdout
	stdout:pwm         write pwm menu to stdout
	stdout:jwm         write jwm menu to stdout
	stdout:mlvwm       write mlvwm menu to stdout
	stdout:twm         write twm menu to stdout
	stdout:moonwm      write moonwm menu to stdout
	stdout:ctwm        write ctwm menu to stdout
	stdout:vtwm        write vtwm menu to stdout
	stdout:xmenu       write xmenu menu to stdout
	stdout:ctrlmenu    write ctrlmenu menu to stdout
```


Example
-------

```
	menubuilder.lua -faves xterm,links,smplayer jwm icewm
```

Including the menus
-------------------

For icewm, blackbox, fluxbox and pekwm the menu should immediately become active. For the other window managers you'll need to include a path to the menu file in the window manager config.

Paths that start with '/root/' indicate that you need to supply the actual path to your home directory. The 'root' user (with home directory '/root/') is just used as an example in these cases.

For JWM add the line

```
	<Include>/root/.menu.jwm</Include>
```

to your .menu.jwm file


For fvwm add the line

```
	read /root/.fvwm/fvwm.menu
```

to your ~/.fvwm/config file


For mlvwm add the line

```
	Read .menu.mlvwm
```

to your .mlvrc file, and also add the 'RootMenu' menu to your menubar, like this:

```
	# Definition MenuBar
	MenuBar default
	RootMenu
	def-File
	def-Edit
	def-View
	def-Label
	def-Window
	END
```



For twm add the line

```
	sinclude(`/root/.menu.twm')
```

to your .twmrc




For ctwm add the line

```
	sinclude(`/root/.menu.ctwm')
```

to your .ctwmrc



For vtwm add the line

```
	sinclude(`/root/.menu.vtwm')
```

to your .vtwmrc AND RUN VTWM AS 'vtwm -m'


For pwm add the line
```
	include rootmenu.conf
```

to your .pwm/pwm.conf. You may also need to delete or rename any existing rootmenu definition, say in default-menus.conf

For xmenu you have to bind the following command to a keystroke or a mouse click somehow

```
	cat ~/.menu.xmenu | xmenu | sh
```

or you can build the menu on-the-fly with

```
	menubuilder.lua ctrlmenu:stdout | ctrlmenu
```

For ctrlmenu you have to bind the following command to a keystroke or a mouse click somehow

```
	cat ~/.menu.ctrlmenu | ctrlmenu
```

or you can build the menu on-the-fly with

```
	menubuilder.lua ctrlmenu:stdout | ctrlmenu
```

Note that the current version of ctrlmenu has a README.md file that appears to detail a different version of the program that has different command-line args.


Icon Search System
------------------

The program builds up a search path for icons by concatenating:

the environment variable "ICON_PATH"
any paths passed on the command-line with the "-icons" argument
for each 'bin' directory in path look for an directory above it called "share/icons" and for "share/icons/hicolor/64x64",  "share/icons/hicolor/48x48", and "share/icons/hicolor/32x32".

In all these directories it looks for icons using information in this order:

the names suggested in the config file
the name/filename of the application
the group the application belongs to

Icons are currently supported for the Openbox, JWM and IceWM window managers and the xmenu and ctrlmenu menu systems. Icons can be turned off altogether with the '-no-icons' command-line option.


Window Manager Update
---------------------

The jwm, openbox and icewm window managers support auto-update, so that when menubuilder creates a new menu for them, it signals them to reload their menus. This allows menubuilder to be launched by an inotify or other filesystem notification service sees new files created. Menus can thus be automatically updated and the window-manager told to reload.


Config File
-----------

The config file has the following types of entry

1) app entries
App entries describe programs that lack .desktop files. They have the form:

```
	app [name] group=[group] icons=[icon names] title=[title] invoke=[invocation]
```

'name' will be the filename on disk for this program.

'group' is the application group, or submenu that this item belongs in. 'title' is the name that will be displayed in the menu. 'icons' is a comma-separated list of icon names that could be used as an icon for this app (menubuilder will search for files matching [icon name].png, [icon name].jpg etc). 'invocation' is the full command-line used to run the app. The icons, title and invoke arguments are optional.

For example:

```
	app xterm group=TerminalEmulator icons=xterm,terminal title="Xterm"
	app links group=WebBrowser icons=links,links-browser invoke="links -g www.google.com"
```

if an app needs to be run in a terminal, then add the 'termapp' modifier, like so:

```
	app lynx termapp group=WebBrowser icons=browser invoke="lynx www.google.com"
```

if an app needs to be passed a text-argument, like a url for instance, then use the 'query' modifier:

```
	app rdesktop query group=Utility icons=vnc title="RDesktop (RDP)" query:title="host to connect to?"
```

if an app needs to be passed a list of files on startup, then use the 'fileapp' modifier, like so:

```
	app mpg123 termapp fileapp group=Audio icons=audio,mixer query:title="mpg123: Select Files to Play" query:filter="*.mp3 *.mpg3 *.mpeg3"
```

(please note, the 'query:filter' feature is only supported for qarma at this time, not zenity or xdialog)


An app can 'imply' multiple entries. These are usually instances of the app run with different arguments.

```
	app cxine implies=podcast-sn,podcast-twis
  app podcast-sn title="Security Now Podcast" group=Podcasts invoke="cxine -podcast https://feeds.twit.tv/sn_video_hd.xml"
  app podcast-twis title="This Week In Space Podcast" group=Podcasts invoke="cxine -podcast https://feeds.twit.tv/twis.xml"
```


2) override entries

Override entries are app entries that mostly apply to apps discovered via .desktop files, and which override the settings of those .desktop files, changing the group, icon to display title of the app. For example:

```
	override DesktopDungeons group=Roguelike icons=skull,sword,goblin
```

Override entries have a special feature where multiple apps can be specified as a comma-separated list, and the same config applied to them, like so:

```
override Helm,PHASEX,IanniX,QMidiArp,Qtractor,drumkv1,samplv1,padthv1,synthv1,amsynth group=Music
```

Overrides also support shell-style pattern matches, although this has some issues with libUseful versions earlier than v4.74. For example:

```
	override *Fight* group=FightingGames icons=fist
```



3) group entries

group entries apply settings to a menu subgroup, for example:

```
	group BoardGame title="Board Games" parent=Game icons=application-board?game,BoardGame,Pawn,Knight,Chess
```

The 'parent' option specifies that this is not a top-level group, but is a subgroup of the group 'games'

Some groups are discovered from the "Categories" entry in .desktop files. Such entries are normally a list of groups seperated by semi-colons. menubuilder.lua picks the first of these groups, but this is not always useful. You can ignore groups with the 'ignore' qualifier:

```
group KDE ignore
```

This will have the effect that this group will not be added to the menu, and that applications belonging to this group will be booked against the first group in their "Categories" entry that isn't ignored.

4) 'ignore' entries

'ignore-groups' and 'ignore-apps' can be used to more conviniently list items to be ignored, like so:

```
ignore-groups GTK,Gtk,Qt,Application,ConsoleOnly,GNOME,SDL
```
