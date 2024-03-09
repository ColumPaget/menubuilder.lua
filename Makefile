PREFIX=/usr/local

menubuilder.lua: includes.lua globals.lua command_line.lua config_file.lua desktop_files.lua icons.lua dialogs.lua blackbox.lua fvwm.lua icewm.lua jwm.lua mlvwm.lua openbox.lua pekwm.lua pwm.lua twm.lua xmenu.lua ctrlmenu.lua main.lua 
	cat includes.lua globals.lua command_line.lua config_file.lua desktop_files.lua icons.lua dialogs.lua blackbox.lua fvwm.lua icewm.lua jwm.lua mlvwm.lua openbox.lua pekwm.lua pwm.lua twm.lua xmenu.lua main.lua > menubuilder.lua
	chmod a+x menubuilder.lua

clean:
	rm menubuilder.lua

install:
	mkdir -p ~/bin
	cp menubuilder.lua ~/bin
	mkdir -p ~/.config/menubuilder/
	cp menubuilder.conf ~/.config/menubuilder/

global-install:
	mkdir -p $(PREFIX)/bin
	cp menubuilder.lua $(PREFIX)/bin
	mkdir -p $(PREFIX)/share/man/man1
	cp menubuilder.1 $(PREFIX)/share/man/man1
	mkdir -p /etc/
	cp menubuilder.conf /etc/menubuilder/

