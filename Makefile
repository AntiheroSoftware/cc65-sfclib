all: sfclib samples

sfclib:
	/Users/lint/Dropbox/Snes/Projects/Snes_Tools/cc65/bin/ca65 -t none src/crt0.asm
	/Users/lint/Dropbox/Snes/Projects/Snes_Tools/cc65/bin/ca65 -t none src/init.asm
	/Users/lint/Dropbox/Snes/Projects/Snes_Tools/cc65/bin/ca65 -t none src/string.asm
	/Users/lint/Dropbox/Snes/Projects/Snes_Tools/cc65/bin/ca65 -t none src/debug.asm
	/Users/lint/Dropbox/Snes/Projects/Snes_Tools/cc65/bin/ca65 -t none src/pad.asm
	/Users/lint/Dropbox/Snes/Projects/Snes_Tools/cc65/bin/ca65 -t none src/event.asm
	/Users/lint/Dropbox/Snes/Projects/Snes_Tools/cc65/bin/ar65 a bin/sfc.lib src/crt0.o src/init.o src/string.o src/debug.o src/pad.o src/event.o

samples:
	@$(MAKE) -C samples $@


