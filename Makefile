all: sfclib samples

.PHONY: sfclib samples

sfclib:
	../cc65/bin/ca65 -t none -I include src/crt0.asm
	../cc65/bin/ca65 -t none -I include src/init.asm
	../cc65/bin/ca65 -t none -I include src/string.asm
	../cc65/bin/ca65 -t none -I include src/debug.asm
	../cc65/bin/ca65 -t none -I include src/pad.asm
	../cc65/bin/ca65 -t none -I include src/event.asm
	../cc65/bin/ca65 -t none -I include src/sprite.asm
	../cc65/bin/ar65 a bin/sfc.lib src/crt0.o src/init.o src/string.o src/debug.o src/pad.o src/event.o src/sprite.o

samples:
	@$(MAKE) -C samples


