MenuBuilder.lua - root menu generation for window managers
----------------------------------------------------------

MenuBuilder can scan for installed applications and build root menus for a number of X11 window managers.  Icons are supported under jwm and icewm and MenuBuilder will use a number of heuristics to search for them. A special group 'faves' can be populated with will create a number of application options at the top of the menu. Terminal apps can be added to the list, with a specifiable terminal emulator to run them, and a dialog app like xdialog, zenity or qarma can be specified to add text or file select queries to applications that expect to be told a url or a list of files on startup.

MenuBuilder is specifically designed for indexing older applications that lack a .desktop file that describes them. However, it also uses .desktop files and is compatible with my 'Sommelier' app (https://github.com/ColumPaget/Sommelier) which installs windows apps for use with wine, and creates .desktop files for them. 
In addition to .desktop files, MenuBuilder uses a list of appplications from a supplied config file, 'MenuBuilder.conf'. This file is far from exhaustive, but it covers a lot of apps that I personally use. If you add to it, you could send the diff to colums.projects@gmail.com, and I'll add it to the distributed file. This file should either be installed as /etc/MenuBuilder.conf or in one's home directory as ~/.MenuBuilder.conf


Supported Window Managers
-------------------------

blackbox 
fluxbox
icewm
pekwm
mlvwm
jwm
twm 
vtwm 
ctwm


Requirements
------------

MenuBuilder.lua requires lua, libUseful (https://github.com/ColumPaget/libUseful) version 4.1 and above, and libUseful-lua (https://github.com/ColumPaget/libUseful-lua) version 2.0 and above to have been installed. Building libUseful-lua requires SWIG.

Installation
------------

an example config file is included that should be copied to "/etc/menubuilder.conf" or "~/.menubuilder.conf". menubuilder can then be run as a lua script with just "lua menubuilder.lua all". On linux the 'binfmt_misc' feature can be used to automatically run menubuilder without specifying the lua interpreter.

Usage
-----

```
	lua menubuilder.lua [options] [window manager] [window manager] ...
```

Options
-------

```
	-c                 path to config file, if not supplied then ~/.menubuilder.conf will be tried, followed by /etc/menubuilder.conf
	-faves [items]     a list of program names to include above everthing else on the top menu 
	-icons [path]      add a colon-separated list of paths under which to search for icons
	-no-icons          do not find icons for the menu
	-t [app]           terminal app to use for terminal programs, defaults to 'xterm'
	-term [app]        terminal app to use for terminal programs, defaults to 'xterm'
	-dialogs [app]     dialog app to use for programs that need additional info. Choices are 'xdialog', 'zenity' or 'qarma'. Defaults to 'no dialogs'. If no dialog app is set then entries for apps requring dialogs will not be added to the menu.

```
Multiple 'window manager' arguements can be supplied and can contain the following values:

```
	all                this will write out menu files for all supported window managers
	blackbox           write to file ~/.blackbox/menu
	fluxbox            write to file ~/.fluxbox/menu
	icewm              write to file ~/.icewm/menu
	pekwm              write to file ~/.pekwm/menu
	jwm                write to file ~/.menu.jwm
	mlvwm              write to file ~/.menu.mlvwm
	twm                write to file ~/.menu.twm
	ctwm               write to file ~/.menu.ctwm
	vtwm               write to file ~/.menu.vtwm
	
	stdout:blackbox    write blackbox menu to stdout
	stdout:fluxbox     write fluxbox menu to stdout
	stdout:icewm       write icewm menu to stdout
	stdout:pekwm       write pekwm menu to stdout
	stdout:jwm         write jwm menu to stdout
	stdout:mlvwm       write mlvwm menu to stdout
	stdout:twm         write twm menu to stdout
	stdout:ctwm        write ctwm menu to stdout
	stdout:vtwm        write vtwm menu to stdout
```


Example
-------

	MenuBuilder.lua -faves xterm,links,smplayer jwm icewm

Including the menus
-------------------

For icewm, blackbox, fluxbox and pekwm the menu should immediately become active. For the other window managers you'll need to include a path to the menu file in the window manager config.


For JWM add the line

```
	<Include>/root/.menu.jwm</Include>
```

to your .menu.jwm file



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

Icons are only currently supported for the JWM and IceWM window managers. Icons can be turned off altogether with the '-no-icons' command-line option.



Config File
-----------

The config file has three types of entry

1) app entries
App entries describe programs that can be added to menus. They have the form:

```
	app [programfile] group=[group] icons=[icon names] title=[title] invoke=[invocation]
```

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


2) override entries

Override entries are app entries that mostly apply to apps discovered via .desktop files, and which override the settings of those .desktop files, changing the group, icon to display title of the app. For example:

```
	override DesktopDungeons group=Roguelike icons=skull,sword,goblin
```

3) group entries

group entries apply settings to a menu subgroup, for example:

```
	group BoardGame title="Board Games" parent=Game icons=application-board?game,BoardGame,Pawn,Knight,Chess
```

The 'parent' option specifies that this is not a top-level group, but is a subgroup of the group 'games'
